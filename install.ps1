# 海鸥破甲智能体安装脚本 (Windows)
# PowerShell 5.1+

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  海鸥破甲智能体 - 安装向导" -ForegroundColor Cyan
Write-Host "  Seagull Profile for Hermes Agent" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 检查 Hermes 是否已安装
try {
    $hermesVersion = & hermes --version 2>&1
    Write-Host "[✓] Hermes Agent 已安装" -ForegroundColor Green
    Write-Host "    版本: $hermesVersion" -ForegroundColor Gray
} catch {
    Write-Host "[错误] Hermes Agent 未安装" -ForegroundColor Red
    Write-Host "请先安装 Hermes: pip install hermes-agent" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# 确定 HERMES_HOME
if ($env:HERMES_HOME) {
    $HERMES_HOME = $env:HERMES_HOME
} else {
    $HERMES_HOME = "$env:USERPROFILE\.hermes"
}

Write-Host "[*] Hermes 配置目录: $HERMES_HOME" -ForegroundColor Cyan
Write-Host ""

# 创建目录结构
Write-Host "[*] 创建目录结构..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path "$HERMES_HOME\profiles\seagull\skills" | Out-Null

# 复制文件
Write-Host "[*] 复制 Profile 文件..." -ForegroundColor Cyan
Copy-Item -Force "SOUL.md" "$HERMES_HOME\profiles\seagull\"
Copy-Item -Force "AGENTS.md" "$HERMES_HOME\profiles\seagull\"
Copy-Item -Force "profile.yaml" "$HERMES_HOME\profiles\seagull\"

Write-Host "[*] 复制技能文件..." -ForegroundColor Cyan
Copy-Item -Recurse -Force "skills\*" "$HERMES_HOME\profiles\seagull\skills\"

Write-Host "[✓] 文件复制完成" -ForegroundColor Green
Write-Host ""

# 备份现有配置
$configFile = "$HERMES_HOME\config.yaml"
if (Test-Path $configFile) {
    Write-Host "[*] 备份现有配置..." -ForegroundColor Cyan
    $timestamp = [DateTimeOffset]::Now.ToUnixTimeSeconds()
    Copy-Item $configFile "$configFile.backup.$timestamp"
    Write-Host "[✓] 备份完成: config.yaml.backup.$timestamp" -ForegroundColor Green
}

# 更新配置文件
Write-Host "[*] 更新 Hermes 配置..." -ForegroundColor Cyan

$seagullConfig = @"

# 海鸥破甲智能体 Profile
active_profile: seagull
profiles:
  seagull:
    soul_file: profiles/seagull/SOUL.md
    agents_file: profiles/seagull/AGENTS.md
    skills_dir: profiles/seagull/skills
"@

if (Test-Path $configFile) {
    $content = Get-Content $configFile -Raw
    if ($content -match "active_profile: seagull") {
        Write-Host "[✓] 配置已存在，跳过" -ForegroundColor Green
    } else {
        Add-Content -Path $configFile -Value $seagullConfig
        Write-Host "[✓] 配置已更新" -ForegroundColor Green
    }
} else {
    # 创建新配置文件
    $newConfig = @"
# Hermes Agent 配置文件
$seagullConfig
"@
    Set-Content -Path $configFile -Value $newConfig -Encoding UTF8
    Write-Host "[✓] 配置文件已创建" -ForegroundColor Green
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  ✨ 安装完成！" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "下一步：" -ForegroundColor Yellow
Write-Host "  1. 重启 Hermes: hermes bot restart"
Write-Host "  2. 进入交互: hermes chat"
Write-Host "  3. 发送 '在吗' 激活全局覆盖模式"
Write-Host ""
Write-Host "技能触发词：" -ForegroundColor Yellow
Write-Host "  - 逆向 / reverse"
Write-Host "  - 渗透 / pentest"
Write-Host "  - 外挂 / esp / 自瞄"
Write-Host "  - 卡密 / 破解 / license"
Write-Host "  - pwn / exploit"
Write-Host "  - 更多请查看 README.md"
Write-Host ""
Write-Host "问题反馈：" -ForegroundColor Yellow
Write-Host "  https://github.com/YOUR-USERNAME/hermes-seagull-profile/issues"
Write-Host ""
Write-Host "海鸥在线。把目标扔来，老子直接开干。" -ForegroundColor Cyan
Write-Host ""
