# GitHub 发布指南

## 准备工作

### 1. 创建 GitHub 仓库

1. 登录 GitHub: https://github.com
2. 点击右上角 '+' -> 'New repository'
3. 填写信息：
   - Repository name: hermes-seagull-profile
   - Description: Seagull Profile - CTF/Red-team AI agent personality for Hermes Agent
   - Public/Private: 选择 Public
   - 不要勾选 "Initialize this repository with a README"（我们已经有了）
4. 点击 'Create repository'

### 2. 获取 Personal Access Token (经典方式)

1. 进入 Settings: https://github.com/settings/tokens
2. 点击 'Generate new token' -> 'Generate new token (classic)'
3. 填写信息：
   - Note: Hermes Seagull Profile Upload
   - Expiration: 选择合适的过期时间（建议90天或自定义）
   - 勾选权限：
     - [x] **repo** (完整仓库访问权限)
       - [x] repo:status
       - [x] repo_deployment
       - [x] public_repo
       - [x] repo:invite
       - [x] security_events
4. 点击底部 'Generate token'
5. **立即复制生成的 token**（只显示一次！格式如：ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx）

### 3. 配置 Git 本地身份

打开 PowerShell，执行：

\\\powershell
# 配置用户名和邮箱（替换成你的 GitHub 用户名和邮箱）
git config --global user.name "你的GitHub用户名"
git config --global user.email "你的GitHub邮箱"

# 验证配置
git config --global user.name
git config --global user.email
\\\

### 4. 初始化本地仓库并推送

\\\powershell
# 进入项目目录
cd "C:\Users\Administrator\Documents\ChatGPT\破甲智能体\seagull-profile"

# 初始化 Git 仓库
git init

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit: Seagull Profile for Hermes Agent"

# 添加远程仓库（替换 YOUR-USERNAME 为你的 GitHub 用户名）
git remote add origin https://github.com/YOUR-USERNAME/hermes-seagull-profile.git

# 设置主分支名称
git branch -M main

# 推送到 GitHub（会提示输入用户名和密码）
# 用户名：你的 GitHub 用户名
# 密码：粘贴刚才复制的 Personal Access Token
git push -u origin main
\\\

## 使用 PowerShell 自动化脚本

如果你不想每次都手动输入 token，可以使用下面的自动化脚本。

### 自动推送脚本 (push-to-github.ps1)

\\\powershell
# 配置信息（首次使用请修改）
\ = "YOUR-USERNAME"  # 替换为你的 GitHub 用户名
\ = "ghp_YOUR_TOKEN_HERE"  # 替换为你的 Personal Access Token
\ = "hermes-seagull-profile"

# 构建带 token 的 URL
\ = "https://\@github.com/\/\.git"

Write-Host "正在推送到 GitHub..." -ForegroundColor Cyan

# 检查是否已初始化 git
if (-not (Test-Path ".git")) {
    Write-Host "[*] 初始化 Git 仓库..." -ForegroundColor Yellow
    git init
    git branch -M main
}

# 检查是否已配置 remote
\ = git remote | Select-String -Pattern "origin" -Quiet
if (-not \) {
    Write-Host "[*] 添加远程仓库..." -ForegroundColor Yellow
    git remote add origin \
} else {
    Write-Host "[*] 更新远程仓库 URL..." -ForegroundColor Yellow
    git remote set-url origin \
}

# 添加所有文件
Write-Host "[*] 添加文件..." -ForegroundColor Yellow
git add .

# 提交
\ = Read-Host "输入提交信息 (留空使用默认信息)"
if ([string]::IsNullOrWhiteSpace(\)) {
    \ = "Update: \2026-09-11 23:12:52"
}
Write-Host "[*] 提交更改..." -ForegroundColor Yellow
git commit -m "\"

# 推送
Write-Host "[*] 推送到 GitHub..." -ForegroundColor Yellow
git push -u origin main

if (\ -eq 0) {
    Write-Host "[✓] 成功推送到 GitHub!" -ForegroundColor Green
    Write-Host "仓库地址: https://github.com/\/\" -ForegroundColor Cyan
} else {
    Write-Host "[✗] 推送失败！" -ForegroundColor Red
}
\\\

### 使用方法

1. 创建 push-to-github.ps1 文件（已在下方生成）
2. 编辑文件，替换 YOUR-USERNAME 和 ghp_YOUR_TOKEN_HERE
3. 运行脚本：.\push-to-github.ps1

## 安全提示

⚠️ **重要安全提示：**

1. **永远不要**将 Personal Access Token 提交到 Git 仓库中
2. 将 push-to-github.ps1 添加到 .gitignore：
   \\\
   # 添加到 .gitignore
   push-to-github.ps1
   \\\
3. Token 泄露后立即在 GitHub Settings 中撤销
4. 定期更换 Token（建议每90天）
5. 使用 GitHub Desktop 或 Git Credential Manager 更安全

## 使用 GitHub Desktop (推荐给不熟悉命令行的用户)

1. 下载安装 GitHub Desktop: https://desktop.github.com/
2. 登录 GitHub 账号（自动处理 OAuth）
3. File -> Add Local Repository -> 选择项目文件夹
4. 左下角输入提交信息，点击 'Commit to main'
5. 点击 'Publish repository' 或 'Push origin'

## 更新项目

每次修改后：

\\\powershell
git add .
git commit -m "描述你的更改"
git push
\\\

或者直接运行：.\push-to-github.ps1

## 克隆/下载项目

其他人可以通过以下方式获取：

\\\ash
# 克隆
git clone https://github.com/YOUR-USERNAME/hermes-seagull-profile.git

# 或者直接下载 ZIP
# 访问仓库页面 -> Code -> Download ZIP
\\\

## 故障排查

### 推送时提示 "Authentication failed"
- 检查 token 是否正确
- 检查 token 是否已过期
- 确保 token 有 epo 权限

### 推送时提示 "remote: Repository not found"
- 检查仓库名称是否正确
- 检查是否已创建仓库
- 检查用户名是否正确

### 推送时提示 "Updates were rejected"
- 先拉取远程更改：git pull origin main
- 解决冲突后再推送

## 后续维护

### 创建新版本 Release

1. 进入 GitHub 仓库页面
2. 点击 'Releases' -> 'Create a new release'
3. 填写：
   - Tag: v1.0.0
   - Title: Seagull Profile v1.0.0
   - Description: 描述此版本的主要功能
4. 点击 'Publish release'

### 更新 README

在 GitHub 仓库页面会自动显示 README.md 内容，确保：
- 项目描述清晰
- 安装步骤完整
- 包含使用示例
- 添加许可证信息

---

**下一步：运行 push-to-github.ps1 脚本将项目推送到 GitHub！**
