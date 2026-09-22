# file: dist/activate-seagull.ps1
<#
.SYNOPSIS
    海鸥 profile 状态检查与激活验证。

.DESCRIPTION
    检查 seagull profile 的部署完整性、插件加载状态、技能注册情况与
    破甲 hook 是否真正挂上（而非被 v0.19 静默忽略）。
#>
[CmdletBinding()]
param(
    [string]$Name = 'seagull'
)

$ErrorActionPreference = 'Continue'

$hermesRoot = $null
$code = "from hermes_constants import get_default_hermes_root; print(get_default_hermes_root())"
$out = & python -c $code 2>&1 | Select-Object -Last 1
if ($LASTEXITCODE -eq 0 -and $out) { $hermesRoot = $out.Trim() }
if (-not $hermesRoot) {
    if ($env:LOCALAPPDATA) { $hermesRoot = Join-Path $env:LOCALAPPDATA 'hermes' }
    else { $hermesRoot = Join-Path $env:USERPROFILE '.hermes' }
}
$hermesHome = $hermesRoot
$profileDir = Join-Path $hermesRoot "profiles\$Name"

Write-Host ''
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host '  海鸥破甲智能体 - 状态检查' -ForegroundColor Cyan
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host ''

$errors = 0

# ---- 1. profile 存在性 -----------------------------------------------------
Write-Host '[1] profile 部署' -ForegroundColor Yellow
if (Test-Path $profileDir) {
    Write-Host "  [OK] $profileDir" -ForegroundColor Green
} else {
    Write-Host "  [MISSING] $profileDir" -ForegroundColor Red
    $errors++
}

# ---- 2. 核心文件 -----------------------------------------------------------
Write-Host ''
Write-Host '[2] 核心文件' -ForegroundColor Yellow
$core = @('distribution.yaml', 'SOUL.md', 'AGENTS.md', 'config.yaml')
foreach ($f in $core) {
    $p = Join-Path $profileDir $f
    if (Test-Path $p) {
        $size = (Get-Item $p).Length
        Write-Host ("  [OK] {0,-22} {1,7} bytes" -f $f, $size) -ForegroundColor Green
    } else {
        Write-Host "  [MISSING] $f" -ForegroundColor Red
        $errors++
    }
}

# ---- 3. 技能 ---------------------------------------------------------------
Write-Host ''
Write-Host '[3] 技能注册 (需 YAML frontmatter)' -ForegroundColor Yellow
$skillNames = @('seagull-reverse', 'seagull-pentest', 'seagull-exploit', 'seagull-game-hack', 'seagull-license-security')
foreach ($s in $skillNames) {
    $p = Join-Path $profileDir "skills\$s\SKILL.md"
    if (-not (Test-Path $p)) {
        Write-Host "  [MISSING] $s" -ForegroundColor Red
        $errors++
        continue
    }
    $raw = Get-Content $p -Raw -Encoding UTF8
    if ($raw.StartsWith('---') -and $raw -match '(?m)^name:\s*' -and $raw -match '(?m)^description:\s*') {
        Write-Host "  [OK] $s (frontmatter 完整)" -ForegroundColor Green
    } else {
        Write-Host "  [BAD] $s - frontmatter 缺失 name/description，技能系统解析不到" -ForegroundColor Red
        $errors++
    }
}

# ---- 4. 插件 ---------------------------------------------------------------
Write-Host ''
Write-Host '[4] 破甲插件' -ForegroundColor Yellow
$plugDir = Join-Path $profileDir 'plugins\seagull-armor-break'
foreach ($f in @('plugin.yaml', '__init__.py')) {
    $p = Join-Path $plugDir $f
    if (Test-Path $p) {
        Write-Host "  [OK] $f" -ForegroundColor Green
    } else {
        Write-Host "  [MISSING] $f" -ForegroundColor Red
        $errors++
    }
}

# hook 名称必须命中 v0.19 VALID_HOOKS，否则会被静默忽略
$validHooks = @(
    'pre_tool_call', 'post_tool_call', 'transform_terminal_output', 'transform_tool_result',
    'transform_llm_output', 'pre_llm_call', 'post_llm_call', 'pre_verify',
    'pre_api_request', 'post_api_request', 'api_request_error',
    'on_session_start', 'on_session_end', 'on_session_finalize', 'on_session_reset',
    'subagent_start', 'subagent_stop'
)
$initPath = Join-Path $plugDir '__init__.py'
if (Test-Path $initPath) {
    $initRaw = Get-Content $initPath -Raw -Encoding UTF8
    $registered = [regex]::Matches($initRaw, 'register_hook\(\s*"([a-z_]+)"') | ForEach-Object { $_.Groups[1].Value }
    if ($registered.Count -eq 0) {
        Write-Host '  [BAD] 未发现 register_hook 调用' -ForegroundColor Red
        $errors++
    } else {
        foreach ($h in $registered) {
            if ($validHooks -contains $h) {
                Write-Host "  [OK] hook: $h (v0.19 合法)" -ForegroundColor Green
            } else {
                Write-Host "  [BAD] hook: $h 不在 v0.19 VALID_HOOKS 中 - 会被静默忽略" -ForegroundColor Red
                $errors++
            }
        }
    }

    # 旧版残留检测 — 只看真实的 register_hook(...) 实参，
    # 不扫全文，避免把"迁移说明注释"里的旧 hook 名误判成实际调用。
    $registeredRaw = [regex]::Matches($initRaw, 'register_hook\(\s*(?:"([a-z_]+)"|''([a-z_]+)''|([A-Za-z_][A-Za-z0-9_]*))') |
        ForEach-Object {
            $g = $_.Groups
            if ($g[1].Success) { $g[1].Value } elseif ($g[2].Success) { $g[2].Value } else { $g[3].Value }
        }
    $legacyHits = $registeredRaw | Where-Object { $_ -in @('transform_system_prompt', 'pre_agent_turn') }
    if ($legacyHits) {
        Write-Host "  [BAD] 实际注册了 v0.19 已废弃的 hook: $($legacyHits -join ', ')" -ForegroundColor Red
        $errors++
    } else {
        Write-Host '  [OK] 无废弃 hook 实际注册' -ForegroundColor Green
    }
}

# ---- 5. 插件白名单 ---------------------------------------------------------
Write-Host ''
Write-Host '[5] 插件启用状态 (opt-in 白名单)' -ForegroundColor Yellow
$cfgPath = Join-Path $profileDir 'config.yaml'
if (Test-Path $cfgPath) {
    $cfgRaw = Get-Content $cfgPath -Raw -Encoding UTF8
    if ($cfgRaw -match 'seagull-armor-break') {
        Write-Host '  [OK] config.yaml 白名单包含 seagull-armor-break' -ForegroundColor Green
    } else {
        Write-Host '  [WARN] 插件不在 plugins.enabled 白名单 - 目录存在也不会加载' -ForegroundColor Yellow
        $errors++
    }
}

# ---- 6. CLI 视角 -----------------------------------------------------------
Write-Host ''
Write-Host '[6] Hermes CLI 视角' -ForegroundColor Yellow
$hermes = Get-Command hermes -ErrorAction SilentlyContinue
if ($hermes) {
    $plist = & hermes profile list 2>&1 | Out-String
    if ($plist -match [regex]::Escape($Name)) {
        Write-Host "  [OK] hermes profile list 能看到 '$Name'" -ForegroundColor Green
    } else {
        Write-Host "  [WARN] hermes profile list 未列出 '$Name'" -ForegroundColor Yellow
    }
    $pinfo = & hermes profile info $Name 2>&1 | Out-String
    if ($pinfo.Trim()) {
        Write-Host '  --- hermes profile info ---' -ForegroundColor Gray
        $pinfo.Trim() -split "`n" | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }
    }
} else {
    Write-Host '  [WARN] hermes 不在 PATH' -ForegroundColor Yellow
}

# ---- 汇总结论 --------------------------------------------------------------
Write-Host ''
Write-Host '============================================================' -ForegroundColor Cyan
if ($errors -eq 0) {
    Write-Host '  全部检查通过 — 海鸥已就绪' -ForegroundColor Green
    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ''
    Write-Host '  激活方式：' -ForegroundColor Yellow
    Write-Host "    hermes -p $Name chat"
    Write-Host "    发送 '在吗'" -NoNewline
    Write-Host '  ->  海鸥在线，你要整点薯条吗？' -ForegroundColor Cyan
    Write-Host ''
    Write-Host '  技能触发词：逆向 / 渗透 / 外挂 / 卡密 / pwn / 无限制 / 破甲' -ForegroundColor Yellow
} else {
    Write-Host "  发现 $errors 处问题" -ForegroundColor Red
    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ''
    Write-Host '  修复建议：重新运行 .\deploy-seagull.ps1 -Force' -ForegroundColor Yellow
}
Write-Host ''

exit $errors
