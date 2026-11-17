# Seagull 快速开始（Hermes 0.23）

## 安装

在仓库根目录运行：

```powershell
# Windows PowerShell
.\install.ps1
```

```bash
# Linux/macOS
./install.sh
```

启动并配置：

```bash
hermes -p seagull setup
hermes -p seagull chat
```

发送 `在吗`，预期回复：`海鸥在线，你要整点薯条吗？`。

## 验证

```bash
hermes -p seagull config path
hermes -p seagull plugins list --plain --no-bundled
hermes -p seagull skills list
```

插件应显示 `enabled`，并安装 5 个 Seagull 技能。配置应位于该 Profile 的 home 下，而不是默认 Profile 的根 `config.yaml`。

## 更新

```bash
hermes profile update seagull --yes
```

更新保留配置、凭证、会话和记忆。插件或 SOUL 更新后，请新建会话。

## 说明

- 不要写入旧版 `active_profile:` YAML 配置。
- `AGENTS.md` 只作用于所在项目，跨项目工作流由 Profile 插件提供。
- `requirements.txt` 中的安全研究工具按需安装，插件本身没有额外 Python 依赖。

完整安装、技能与开发验证说明见 [README.md](README.md)。使用前请阅读 [DISCLAIMER.md](DISCLAIMER.md)。

