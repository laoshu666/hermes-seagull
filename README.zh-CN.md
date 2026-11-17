# 海鸥 Seagull Profile（Hermes 0.23 兼容版）

独立的 `seagull` Profile：SOUL 人格、常驻指令、问候路由和五个技能。

使用前请阅读 [免责声明](DISCLAIMER.md)。

## 安装与启动

```powershell
# Windows PowerShell，在仓库根目录
.\install.ps1
```

```bash
# Linux/macOS，在仓库根目录
./install.sh
```

```bash
hermes -p seagull setup
hermes -p seagull chat
```

发送 `在吗`，预期回复：`海鸥在线，你要整点薯条吗？`。

也可使用 Hermes 原生命令：

```bash
hermes profile install /path/to/hermes-seagull --name seagull --yes
hermes -p seagull plugins enable seagull-armor-break
```

不要向 `config.yaml` 追加旧版 `active_profile:` 配置。使用 `hermes -p seagull` 或 `hermes profile use seagull` 选择 Profile。

## 五个实际安装的技能

- `seagull-reverse`：逆向工程。
- `seagull-pentest`：渗透与越权测试。
- `seagull-exploit`：漏洞利用。
- `seagull-game-hack`：ESP、自瞄与游戏辅助开发。
- `seagull-license-security`：授权验证流分析。

```bash
hermes -p seagull skills list
hermes -p seagull plugins list --plain --no-bundled
hermes -p seagull config path
```

## 更新与恢复

```bash
hermes profile update seagull --yes
```

更新保留配置、凭证、会话和记忆。切回默认 Profile：

```bash
hermes profile use default
```

禁用插件：

```bash
hermes -p seagull plugins disable seagull-armor-break
```

## 说明

- `AGENTS.md` 是项目级规则，不是全局配置。
- 跨项目工作流由 `plugins/seagull-armor-break/WORKFLOWS.md` 提供。
- 插件使用 Hermes 0.23 的缓存安全系统提示区块，不逐轮改写系统提示。
- 修改插件后请新建会话，旧会话可能仍使用旧提示快照。

详细开发与验证说明见 [README.md](README.md)。
