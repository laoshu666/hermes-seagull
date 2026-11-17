# Seagull Profile for Hermes Agent 0.23

独立的 `seagull` Profile，包含 SOUL 人格、缓存安全的常驻指令、问候路由和五个技能。

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

也可以使用 Hermes 原生命令：

```bash
hermes profile install /path/to/hermes-seagull --name seagull --yes
hermes -p seagull plugins enable seagull-armor-break
```

启动：

```bash
hermes -p seagull chat
```

发送 `在吗`，预期回复：`海鸥在线，你要整点薯条吗？`。

首次使用请在 Seagull Profile 内配置模型与凭证，或沿用当前环境中可用的 provider 配置：

```bash
hermes -p seagull setup
```

不要向 `config.yaml` 写入旧的 `active_profile:` YAML 块。Hermes 0.23 使用 `-p` 或 `hermes profile use seagull` 选择 Profile，配置、技能和插件都从该 Profile 的 home 加载。

## 技能

- `seagull-reverse`：逆向、协议和算法恢复。
- `seagull-pentest`：渗透、越权及授权测试复现。
- `seagull-exploit`：漏洞原语分析和 exploit 工程。
- `seagull-game-hack`：ESP、W2S、overlay 和 trainer。
- `seagull-license-security`：授权验证流和本地 harness。

使用 `skill_view(name="seagull-reverse")` 等工具加载相应技能，或输入对应触发词。

## 更新

拉取新源码后再次运行安装器，或：

```bash
hermes profile update seagull --yes
```

更新保留 Profile 的 `config.yaml`、凭证、会话和记忆。SOUL、Seagull 技能与插件属于分发内容，会随新版本更新。

插件修改后请新建会话。已有会话可能继续使用旧系统提示快照。

## 验证

```bash
hermes -p seagull config path
hermes -p seagull plugins list --plain --no-bundled
hermes -p seagull skills list
hermes -p seagull plugins validate /path/to/hermes-seagull/plugins/seagull-armor-break
```

预期：插件为 `enabled`，五个技能均列出。

## 结构

```text
SOUL.md                              Profile 人格
AGENTS.md                            项目级工作指令（不是全局配置）
config.yaml                          新 Profile 的插件启用配置
distribution.yaml                    Hermes 分发清单
plugins/seagull-armor-break/        正式插件及全局工作流
skills/                              五个可索引技能
install.py                           安装/更新入口
tests/                               Hermes 0.23 回归测试
```

`AGENTS.md` 只随所在项目目录或 Git 目录链加载；需要跨项目生效的完整工作流位于 `plugins/seagull-armor-break/WORKFLOWS.md`，由 `seagull.workflows` 系统提示区块提供。

插件不申请工具覆盖权限，也不逐轮修改系统提示，避免破坏 prompt cache。

## 开发验证

将 Hermes 源码根目录放入 `PYTHONPATH`，在其 Python 环境安装 `pytest` 后运行：

```bash
python -m pytest tests -q
```

测试覆盖真实 CLI 安装、更新保留配置、插件加载、提示内容和技能索引。使用本项目前请阅读 `DISCLAIMER.md`。
