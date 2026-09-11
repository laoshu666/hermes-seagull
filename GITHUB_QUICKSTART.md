# 🚀 GitHub 发布完全指南

## 📋 文件清单

已为你准备好以下文件：

- ✅ **GITHUB_GUIDE.md** - 详细的 GitHub 发布教程
- ✅ **setup-github.ps1** - 交互式配置向导（推荐！）
- ✅ **push-to-github.ps1** - 模板脚本（需手动配置）
- ✅ **.gitignore** - Git 忽略配置（保护敏感信息）

---

## 🎯 快速开始（推荐方式）

### 方法一：使用配置向导（最简单）

1. **运行配置向导**
   \\\powershell
   .\setup-github.ps1
   \\\

2. **按提示操作**
   - 检查 Git 安装
   - 配置用户名和邮箱
   - 输入 Personal Access Token
   - 设置仓库名称
   - 自动生成配置好的推送脚本

3. **在 GitHub 创建仓库**
   - 访问: https://github.com/new
   - Repository name: hermes-seagull-profile（或你设置的名称）
   - 选择 Public
   - **不要**勾选 "Initialize this repository with README"
   - 点击 "Create repository"

4. **推送代码**
   \\\powershell
   .\push-to-github.ps1
   \\\

✅ **完成！你的项目已发布到 GitHub！**

---

### 方法二：手动配置

如果你想手动控制每一步：

1. **获取 Personal Access Token**
   - 访问: https://github.com/settings/tokens
   - 点击 "Generate new token (classic)"
   - 勾选 epo 权限
   - 复制生成的 token（格式：ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx）

2. **编辑 push-to-github.ps1**
   \\\powershell
   notepad push-to-github.ps1
   \\\
   修改以下内容：
   - GITHUB_USERNAME: 你的 GitHub 用户名
   - GITHUB_TOKEN: 刚才复制的 token
   - REPO_NAME: hermes-seagull-profile

3. **配置 Git 用户信息**
   \\\powershell
   git config --global user.name "你的GitHub用户名"
   git config --global user.email "你的GitHub邮箱"
   \\\

4. **创建 GitHub 仓库**（同方法一步骤3）

5. **运行推送脚本**
   \\\powershell
   .\push-to-github.ps1
   \\\

---

## 🛡️ 安全须知

⚠️ **重要：Token 安全**

1. **push-to-github.ps1 包含你的 Token，绝对不能提交到 Git！**
2. 已自动添加到 .gitignore，但请务必确认
3. Token 泄露后立即在 GitHub 撤销
4. 建议每 90 天更换一次 Token

🔒 **已保护的文件：**
- push-to-github.ps1 → 包含 Token，已在 .gitignore 中

---

## 📚 后续操作

### 更新代码

每次修改后推送：
\\\powershell
.\push-to-github.ps1
\\\

### 克隆项目

其他人可以这样获取：
\\\ash
git clone https://github.com/你的用户名/hermes-seagull-profile.git
\\\

### 创建 Release

1. 进入 GitHub 仓库页面
2. 点击 "Releases" → "Create a new release"
3. 填写版本信息（如 v1.0.0）
4. 发布

---

## ❓ 常见问题

### Q: 推送时提示 "Authentication failed"
A: 检查 Token 是否正确、未过期，且有 epo 权限

### Q: 提示 "Repository not found"
A: 确认已在 GitHub 创建仓库，且仓库名、用户名正确

### Q: 提示 "Updates were rejected"
A: 先拉取：git pull origin main，解决冲突后再推送

### Q: 不想用命令行
A: 下载 [GitHub Desktop](https://desktop.github.com/)，图形化操作更简单

---

## 📖 详细文档

更多详细信息请查看：
- **GITHUB_GUIDE.md** - 完整教程和故障排查
- **README.md** - 项目使用说明

---

## 🎉 完成后

你的项目将发布在：
**https://github.com/你的用户名/hermes-seagull-profile**

别人可以通过以下方式安装：

**Windows:**
\\\powershell
git clone https://github.com/你的用户名/hermes-seagull-profile.git
cd hermes-seagull-profile
.\install.ps1
\\\

**Linux/macOS:**
\\\ash
git clone https://github.com/你的用户名/hermes-seagull-profile.git
cd hermes-seagull-profile
./install.sh
\\\

---

**准备好了？运行配置向导开始吧：**
\\\powershell
.\setup-github.ps1
\\\

🎯 三步完成发布：**向导配置** → **创建仓库** → **推送代码**
