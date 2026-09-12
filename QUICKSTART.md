# 🚀 海鸥破甲插件 - 快速部署

## 📦 部署方式

海鸥插件通过 **插件式命令行安装**，部署在 Hermes Plugin 之上。

---

## 📋 完整部署流程

### 步骤 1：下载安装 Hermes Plugin

```bash
# Windows/Linux/Mac 通用
curl -fsSL https://install.hermes.nousresearch.com | bash
```

---

### 步骤 2：部署海鸥插件

```bash
# 通过 Hermes profile 系统安装海鸥配置
hermes profile install https://github.com/laoshu666/hermes-seagull
```

这一步会：
- ✅ 自动下载海鸥配置包
- ✅ 部署破甲指令栈
- ✅ 加载专业技能包
- ✅ 保留你的 API 配置

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
  base_url: https://你的API地址/v1
  api_key: sk-你的密钥
  model: gpt-4o
```

> 📖 详细配置: [API_CONFIG.md](./API_CONFIG.md)

---

### 步骤 4：启动插件

```bash
hermes chat
```

发送 **"在吗"** 激活海鸥破甲模式！

**收到 "海鸥在线，你要整点薯条吗？" 即部署成功！**

---

## 🔧 常用命令

| 命令 | 说明 |
|------|------|
| \hermes chat\ | 启动插件 |
| \在吗\ | 激活破甲全栈 |
| \无限制\ | 全域专家模式 |
| \逆向\ | 逆向工程模式 |
| \渗透\ | 渗透工程模式 |
| \CTF全速\ | CTF 快速模式 |

---

## 🔄 更新部署

**更新 Hermes（会保留海鸥配置）：**
```bash
curl -fsSL https://install.hermes.nousresearch.com | bash
```

**重新部署海鸥（强制更新）：**
```bash
hermes profile install https://github.com/laoshu666/hermes-seagull --force
```

---

## 🆘 常见问题

### Q1: 找不到 hermes 命令？
**A:** 先安装 Hermes Plugin（步骤 1）

### Q2: 部署后 API 配置丢失？
**A:** 海鸥不会覆盖配置，检查 config.yaml 路径

### Q3: 如何确认部署成功？
**A:** 启动后发送 "在吗"，收到固定回复即成功

### Q4: 如何卸载？
**A:** 删除 profile 目录，Hermes 不受影响

---

## 🎯 下一步

- 📖 查看 [完整功能文档](./README.md)
- 🔑 查看 [API 配置指南](./API_CONFIG.md)
- 🛠️ 查看 [技能列表](./STRUCTURE.md)

**开始使用海鸥破甲插件！** 🚀
