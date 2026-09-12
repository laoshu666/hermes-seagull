# 🚀 海鸥破甲插件 - 快速开始

## 📦 重要说明

**海鸥是 Hermes Agent 的增强插件，不是独立软件！**

必须按顺序安装：
1. ✅ 先安装 Hermes Agent（基础框架）
2. ✅ 再安装海鸥插件（破甲功能）

---

## 📋 完整安装流程

### 步骤 1：安装 Hermes Agent

```bash
# Windows/Linux/Mac 通用命令
curl -fsSL https://install.hermes.nousresearch.com | bash
```

安装完成后，Hermes 会自动添加到系统路径。

---

### 步骤 2：安装海鸥破甲插件

```bash
# 在 Hermes 基础上叠加海鸥配置
hermes profile install https://github.com/laoshu666/hermes-seagull
```

这一步会：
- ✅ 自动下载海鸥配置包
- ✅ 叠加破甲指令栈（AGENTS.md）
- ✅ 加载专业技能包（skills/）
- ✅ 不会覆盖你的 API 配置

---

### 步骤 3：配置 API 密钥

**Windows：**
```bash
notepad %LOCALAPPDATA%\hermes\config.yaml
```

**Linux/Mac：**
```bash
nano ~/.config/hermes/config.yaml
```

**修改这三行：**
```yaml
custom_providers:
- name: my-provider
  base_url: https://你的API地址/v1    # 改这里
  api_key: sk-你的密钥                 # 改这里
  model: gpt-4o                       # 改这里
```

> 📖 详细配置指南：[API_CONFIG.md](./API_CONFIG.md)

---

### 步骤 4：启动并激活

```bash
# 启动 Hermes（海鸥配置已自动加载）
hermes chat

# 发送激活命令
在吗
```

**回复 "海鸥在线，你要整点薯条吗？" 说明安装成功！**

---

## 🔧 常用命令

| 命令 | 说明 |
|------|------|
| \hermes chat\ | 启动会话 |
| \Ctrl+C\ | 退出会话 |
| \在吗\ | 激活海鸥破甲模式 |
| \无限制\ | 全域专家模式 |
| \逆向\ | 逆向工程模式 |
| \渗透\ | 渗透工程模式 |

---

## ⚙️ 更新

**Hermes 官方更新时：**
```bash
# 更新 Hermes（会自动保留海鸥配置）
curl -fsSL https://install.hermes.nousresearch.com | bash
```

**海鸥插件更新时：**
```bash
# 重新安装海鸥插件
hermes profile install https://github.com/laoshu666/hermes-seagull --force
```

---

## 🆘 常见问题

### Q1: 安装海鸥后，Hermes 命令找不到？
**A:** 说明你还没安装 Hermes Agent，先执行步骤 1

### Q2: 安装海鸥后，API 配置丢失了？
**A:** 不会丢失，海鸥只是叠加配置，不会覆盖 API 设置

### Q3: 如何确认海鸥安装成功？
**A:** 启动 \hermes chat\ 后发送 "在吗"，收到固定回复即成功

### Q4: 如何卸载海鸥？
**A:** 删除 profile 目录即可，Hermes 本体不受影响

---

## 🎯 下一步

- 📖 查看 [完整功能文档](./README.md)
- 🔑 查看 [API 配置指南](./API_CONFIG.md)
- 🛠️ 查看 [技能列表](./STRUCTURE.md)

**开始使用海鸥破甲，全域技术无限制！** 🚀
