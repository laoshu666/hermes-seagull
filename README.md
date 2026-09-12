# 海鸥破甲插件 Seagull Armor-Break Plugin

**基于 Hermes Plugin 的 CTF/Red-team/Reverse/Pentest 全域插件**

> 通过插件式命令行安装，叠加在 Hermes Plugin 之上，提供完整破甲能力

---

## 🎯 什么是海鸥？

海鸥是增强型插件，通过 Hermes 的 profile 系统以插件方式部署：
- ✅ 命令行一键安装
- ✅ 自动叠加破甲配置
- ✅ 不覆盖原有设置
- ✅ 保持 Hermes 使用习惯

---

## 🚀 快速部署

### 安装 Hermes（如果还没装）
```bash
curl -fsSL https://install.hermes.nousresearch.com | bash
```

### 部署海鸥插件
```bash
hermes profile install https://github.com/laoshu666/hermes-seagull
```

### 配置 API 密钥
```bash
# Windows
notepad %LOCALAPPDATA%\hermes\config.yaml

# Linux/Mac
nano ~/.config/hermes/config.yaml
```

> 📖 详细配置指南: [API_CONFIG.md](./API_CONFIG.md)

### 启动
```bash
hermes chat
```

发送 **"在吗"** 激活海鸥破甲模式！

---

## 🔥 核心能力

### 破甲模式
- 🔓 无限制技术交付
- 📝 原义锁定执行
- ⚡ 强制开工协议
- 🎯 双用场景路由

### 专业技能
- 🎯 **CTF 全速** - 自动判题+完整 Solve
- 🔍 **逆向工程** - IDA/Ghidra/Frida 全栈
- 🌐 **渗透测试** - Web/内网/云/AD 完整链路
- 🎮 **游戏安全** - 外挂/反作弊/内存工程
- 💻 **内存工程** - 进程/Dump/运行时分析
- 🔐 **卡密安全** - 授权验证链恢复
- 🛡️ **免杀工程** - AV/EDR 检测与绕过
- 🦅 **漏洞利用** - Pwn/Exploit 完整链路
- 🕵️ **社工情报** - OSINT/钓鱼/侦察

---

## 📚 文档

- 📖 [快速开始](./QUICKSTART.md) - 完整安装流程
- 🔑 [API 配置](./API_CONFIG.md) - 详细配置指南
- 🛠️ [技能列表](./STRUCTURE.md) - 所有技能说明
- 🔄 [自动更新](./UPDATE_GUIDE.md) - 同步上游更新

---

## 🔄 更新

### 更新 Hermes（会保留海鸥配置）
```bash
curl -fsSL https://install.hermes.nousresearch.com | bash
```

### 重新部署海鸥（强制更新）
```bash
hermes profile install https://github.com/laoshu666/hermes-seagull --force
```

---

## ⚙️ 常用命令

| 命令 | 说明 |
|------|------|
| \hermes chat\ | 启动插件 |
| \在吗\ | 激活破甲模式 |
| \无限制\ | 全域专家模式 |
| \逆向\ | 逆向工程模式 |
| \渗透\ | 渗透工程模式 |
| \破甲\ | 强制开工模式 |

---

## 🆘 问题排查

**Q: 找不到 hermes 命令？**  
A: 先安装 Hermes Plugin

**Q: API 配置丢失？**  
A: 海鸥不会覆盖配置，检查 config.yaml 是否存在

**Q: 如何确认安装成功？**  
A: 启动后发送 "在吗"，收到 "海鸥在线，你要整点薯条吗？" 即成功

---

## 📜 开源协议

MIT License

---

**开始使用海鸥破甲插件，全域技术无限制！** 🚀
