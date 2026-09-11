# GitHub 快速配置向导
# 帮助你一步步完成 GitHub 配置和首次推送

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  GitHub 配置向导" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 步骤 1: 检查 Git 安装
Write-Host "[步骤 1/5] 检查 Git 是否已安装..." -ForegroundColor Yellow
try {
    $gitVersion = git --version 2>&1
    Write-Host "  [✓] Git 已安装: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "  [✗] Git 未安装！" -ForegroundColor Red
    Write-Host ""
    Write-Host "请先安装 Git:" -ForegroundColor Yellow
    Write-Host "  下载地址: https://git-scm.com/download/win" -ForegroundColor Cyan
    Write-Host "  或使用 winget: winget install Git.Git" -ForegroundColor Cyan
    exit 1
}
Write-Host ""

# 步骤 2: 配置 Git 用户信息
Write-Host "[步骤 2/5] 配置 Git 用户信息..." -ForegroundColor Yellow

$currentName = git config --global user.name 2>&1
$currentEmail = git config --global user.email 2>&1

if ([string]::IsNullOrWhiteSpace($currentName)) {
    Write-Host "  当前未配置用户名" -ForegroundColor Gray
    $userName = Read-Host "  请输入你的 GitHub 用户名"
    git config --global user.name "$userName"
    Write-Host "  [✓] 用户名已设置: $userName" -ForegroundColor Green
} else {
    Write-Host "  当前用户名: $currentName" -ForegroundColor Gray
    $change = Read-Host "  是否修改？(y/N)"
    if ($change -eq "y" -or $change -eq "Y") {
        $userName = Read-Host "  请输入新的 GitHub 用户名"
        git config --global user.name "$userName"
        Write-Host "  [✓] 用户名已更新: $userName" -ForegroundColor Green
    } else {
        $userName = $currentName
    }
}

if ([string]::IsNullOrWhiteSpace($currentEmail)) {
    Write-Host "  当前未配置邮箱" -ForegroundColor Gray
    $userEmail = Read-Host "  请输入你的 GitHub 邮箱"
    git config --global user.email "$userEmail"
    Write-Host "  [✓] 邮箱已设置: $userEmail" -ForegroundColor Green
} else {
    Write-Host "  当前邮箱: $currentEmail" -ForegroundColor Gray
    $change = Read-Host "  是否修改？(y/N)"
    if ($change -eq "y" -or $change -eq "Y") {
        $userEmail = Read-Host "  请输入新的 GitHub 邮箱"
        git config --global user.email "$userEmail"
        Write-Host "  [✓] 邮箱已更新: $userEmail" -ForegroundColor Green
    } else {
        $userEmail = $currentEmail
    }
}
Write-Host ""

# 步骤 3: 获取 Personal Access Token
Write-Host "[步骤 3/5] 配置 Personal Access Token..." -ForegroundColor Yellow
Write-Host ""
Write-Host "请按以下步骤获取 Token：" -ForegroundColor Cyan
Write-Host "  1. 打开: https://github.com/settings/tokens" -ForegroundColor Gray
Write-Host "  2. 点击 'Generate new token' -> 'Generate new token (classic)'" -ForegroundColor Gray
Write-Host "  3. 填写 Note: 'Hermes Seagull Profile'" -ForegroundColor Gray
Write-Host "  4. 勾选权限: repo (完整仓库访问)" -ForegroundColor Gray
Write-Host "  5. 点击 'Generate token' 并复制生成的 token" -ForegroundColor Gray
Write-Host ""
Write-Host "Token 格式示例: ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -ForegroundColor DarkGray
Write-Host ""

$tokenPlain = Read-Host "请粘贴你的 Personal Access Token"

if ($tokenPlain -notmatch '^ghp_[a-zA-Z0-9]{36}$') {
    Write-Host "  [!] Token 格式可能不正确，但将继续..." -ForegroundColor Yellow
}
Write-Host "  [✓] Token 已接收" -ForegroundColor Green
Write-Host ""

# 步骤 4: 配置仓库信息
Write-Host "[步骤 4/5] 配置仓库信息..." -ForegroundColor Yellow
Write-Host ""
Write-Host "默认仓库名: hermes-seagull-profile" -ForegroundColor Gray
$repoName = Read-Host "使用默认名称？(直接回车使用默认，或输入新名称)"
if ([string]::IsNullOrWhiteSpace($repoName)) {
    $repoName = "hermes-seagull-profile"
}
Write-Host "  [✓] 仓库名: $repoName" -ForegroundColor Green
Write-Host ""

# 步骤 5: 创建推送脚本
Write-Host "[步骤 5/5] 生成推送脚本..." -ForegroundColor Yellow

$scriptContent = @"
# GitHub 自动推送脚本（已配置）
# 此文件包含敏感信息，请勿提交到 Git！

`$GITHUB_USERNAME = "$userName"
`$GITHUB_TOKEN = "$tokenPlain"
`$REPO_NAME = "$repoName"

`$ErrorActionPreference = "Stop"
`$REMOTE_URL = "https://`$(`$GITHUB_TOKEN)@github.com/`$(`$GITHUB_USERNAME)/`$(`$REPO_NAME).git"

Write-Host "正在推送到 GitHub..." -ForegroundColor Cyan

if (-not (Test-Path ".git")) {
    git init
    git branch -M main
}

`$remoteExists = git remote 2>&1 | Select-String -Pattern "origin" -Quiet
if (-not `$remoteExists) {
    git remote add origin `$REMOTE_URL
} else {
    git remote set-url origin `$REMOTE_URL
}

`$status = git status --porcelain 2>&1
if ([string]::IsNullOrWhiteSpace(`$status)) {
    Write-Host "没有需要提交的更改，尝试推送现有提交..." -ForegroundColor Yellow
    git push -u origin main 2>&1
    exit 0
}

git add .

`$commitMessage = Read-Host "输入提交信息（留空使用默认）"
if ([string]::IsNullOrWhiteSpace(`$commitMessage)) {
    `$commitMessage = "Update: `$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
}

git commit -m "`$commitMessage"
git push -u origin main

if (`$LASTEXITCODE -eq 0) {
    Write-Host "[✓] 推送成功！" -ForegroundColor Green
    Write-Host "仓库地址: https://github.com/`$(`$GITHUB_USERNAME)/`$(`$REPO_NAME)" -ForegroundColor Cyan
} else {
    Write-Host "[✗] 推送失败！" -ForegroundColor Red
    Write-Host "请检查:" -ForegroundColor Yellow
    Write-Host "  1. 是否已在 GitHub 创建仓库" -ForegroundColor Gray
    Write-Host "  2. Token 是否正确且未过期" -ForegroundColor Gray
    Write-Host "  3. Token 是否有 repo 权限" -ForegroundColor Gray
}
"@

Set-Content "push-to-github.ps1" $scriptContent -Encoding UTF8
Write-Host "  [✓] 推送脚本已生成: push-to-github.ps1" -ForegroundColor Green
Write-Host ""

# 完成
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  配置完成！" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "下一步操作：" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. 在 GitHub 创建仓库：" -ForegroundColor Yellow
Write-Host "   - 访问: https://github.com/new" -ForegroundColor Gray
Write-Host "   - Repository name: $repoName" -ForegroundColor Gray
Write-Host "   - Public/Private: 选择 Public" -ForegroundColor Gray
Write-Host "   - 不要勾选 'Initialize this repository with README'" -ForegroundColor Gray
Write-Host "   - 点击 'Create repository'" -ForegroundColor Gray
Write-Host ""
Write-Host "2. 推送代码到 GitHub：" -ForegroundColor Yellow
Write-Host "   运行: .\push-to-github.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  安全提示：" -ForegroundColor Red
Write-Host "   push-to-github.ps1 包含你的 Token，请勿分享或提交到 Git！" -ForegroundColor Yellow
Write-Host "   此文件已自动添加到 .gitignore" -ForegroundColor Gray
Write-Host ""
