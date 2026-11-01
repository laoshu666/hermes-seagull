# file: dist/seagull-update.ps1
<#
.SYNOPSIS
    海鸥 profile 更新 — 从分发包重新拉取，保留用户数据。

.DESCRIPTION
    调用 `hermes profile update`，按 distribution.yaml 的 distribution_owned
    列表替换 SOUL.md / AGENTS.md / skills/ / plugins/。
    用户数据 (memories/, sessions/, auth.json, .env, logs/) 永不被触碰。
    config.yaml 默认保留，除非显式 -ForceConfig。

.PARAMETER Name
    profile 名称，默认 seagull。

.PARAMETER ForceConfig
    连 config.yaml 一起用分发包版本覆盖（会丢掉本地模型/插件改动）。

.PARAMETER Local
    改用本地 dist/ 目录作为源（开发用），而非 distribution.yaml 里记录的 source。
    配合 -DistDir 指定 dist/ 的绝对路径。

.PARAMETER DistDir
    -Local 时使用的分发包目录。留空则自动探测。
#>
[CmdletBinding()]
param(
    [string]$Name = 'seagull',
    [switch]$ForceConfig,
    [switch]$Local,
    [string]$DistDir = ''
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
$stamp      = Get-Date -Format 'yyyyMMdd-HHmmss'

Write-Host ''
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host '  海鸥破甲智能体 - 更新' -ForegroundColor Cyan
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host ''

if (-not (Test-Path $profileDir)) {
    Write-Host "[x] profile '$Name' 不存在，请先运行 .\deploy-seagull.ps1" -ForegroundColor Red
    exit 1
}

# ---- 备份（只备 distribution-owned 部分）----------------------------------
Write-Host '[*] 备份当前分发包内容' -ForegroundColor Cyan
$backupDir = Join-Path $hermesHome "_seagull_update_backup_$stamp"
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
foreach ($item in @('SOUL.md', 'AGENTS.md', 'config.yaml', 'skills', 'plugins')) {
    $src = Join-Path $profileDir $item
    if (Test-Path $src) {
        Copy-Item -Recurse -Force $src (Join-Path $backupDir $item)
    }
}
Write-Host "  [+] 备份 -> $backupDir" -ForegroundColor Green

# ---- 执行更新 --------------------------------------------------------------
if ($Local) {
    $distDir = $DistDir
    if (-not $distDir) {
        # 探测：已知的本地分发包路径 / profile 同级 dist/
        # 注意：不能把 $PSScriptRoot 放进候选——profile 目录自带
        # distribution.yaml，会自我命中，导致 -Local 等于自我复制。
        foreach ($cand in @(
            'D:\cb\hermes-seagull-dist',
            (Join-Path (Split-Path -Parent $PSScriptRoot) 'dist')
        )) {
            if ($cand -and (Test-Path (Join-Path $cand 'distribution.yaml'))) { $distDir = $cand; break }
        }
    }
    if (-not $distDir -or -not (Test-Path (Join-Path $distDir 'distribution.yaml'))) {
        Write-Host "[x] 找不到含 distribution.yaml 的分发包，请用 -DistDir 指定" -ForegroundColor Red
        exit 1
    }
    Write-Host "[*] 从本地目录重装: $distDir" -ForegroundColor Cyan
    $args = @('profile', 'install', $distDir, '--name', $Name, '--force', '-y')
    if ($ForceConfig) {
        Write-Host '  [!] 本地重装会一并替换 config.yaml' -ForegroundColor Yellow
    }
    & hermes @args 2>&1 | ForEach-Object { Write-Host "    $_" }
    $code = $LASTEXITCODE
} else {
    Write-Host "[*] 从记录的 source 重新拉取 (hermes profile update)" -ForegroundColor Cyan
    $args = @('profile', 'update', $Name, '-y')
    if ($ForceConfig) { $args += '--force-config' }
    & hermes @args 2>&1 | ForEach-Object { Write-Host "    $_" }
    $code = $LASTEXITCODE
}

if ($code -ne 0) {
    Write-Host "[x] 更新失败 (exit $code)" -ForegroundColor Red
    Write-Host "    回滚: Copy-Item -Recurse -Force '$backupDir\*' '$profileDir'" -ForegroundColor Yellow
    exit $code
}

Write-Host ''
Write-Host '  [+] 更新完成' -ForegroundColor Green
Write-Host "      备份保留在: $backupDir" -ForegroundColor Gray
Write-Host ''
Write-Host '  运行 .\activate-seagull.ps1 验证完整性' -ForegroundColor Yellow
Write-Host ''
