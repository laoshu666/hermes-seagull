# Seagull Armor-Break Plugin

Hermes 0.23 兼容的 Seagull 常驻指令插件。

## 安装

推荐运行仓库根目录的安装器，安装本插件、SOUL.md 和五个技能：

```powershell
.\install.ps1
```

```bash
./install.sh
```

也可直接安装为 Profile：

```bash
hermes profile install /path/to/hermes-seagull --name seagull --yes
hermes -p seagull plugins enable seagull-armor-break
hermes -p seagull chat
```

已有 Profile 更新：

```bash
hermes profile update seagull --yes
```

## 0.23 接口

- `register_system_prompt_section("seagull.core", ...)`：缓存安全的常驻指令。
- `pre_llm_call`：识别独立问候消息并返回固定问候上下文。
- Profile 版注册 `seagull.workflows`，从 `WORKFLOWS.md` 加载完整工作流。
- 使用 `provides_hooks` 声明真实钩子；不再使用 `transform_system_prompt`、`pre_agent_turn` 或无声明效果的 `hooks` 清单。
- 不逐轮改写系统提示，避免破坏 prompt cache。

## 验证与禁用

```bash
hermes -p seagull plugins validate /path/to/hermes-seagull/plugins/seagull-armor-break
hermes -p seagull plugins list --plain --no-bundled
hermes -p seagull skills list
hermes -p seagull plugins disable seagull-armor-break
```

插件没有额外 Python 依赖，不申请内置工具覆盖权限。更新后请新建会话，已有会话可能仍使用旧提示快照。

