# Seagull 模型与凭证配置（Hermes 0.23）

Seagull 使用独立 Profile。查看实际配置路径：

```bash
hermes -p seagull config path
```

Windows 默认位置：`%LOCALAPPDATA%\hermes\profiles\seagull\config.yaml`。
Linux/macOS 默认位置：`~/.hermes/profiles/seagull/config.yaml`。如果设置了 `HERMES_HOME` 或选择其他 Profile，以命令输出为准。

## 配置

```bash
hermes -p seagull setup
hermes -p seagull model
```

凭证保存在该 Profile 的 `.env` 或 Hermes 的凭证存储中，不要提交 API key。新 Seagull Profile 不继承默认 Profile 的模型或凭证；首次使用前按需运行 `setup`。已有 Seagull Profile 的模型、provider、凭证和自定义配置不会被 `hermes profile update seagull --yes` 覆盖。

检查配置：

```bash
hermes -p seagull config get model.default
hermes -p seagull config get model.provider
hermes -p seagull doctor
```

自定义 provider 的字段结构以 Hermes 0.23 的 `setup`、`model` 和官方文档为准，不使用旧 Seagull 示例中的 `custom_providers` 配置格式。

官方参考：https://hermes-agent.nousresearch.com/docs/

## 验证

```bash
hermes -p seagull plugins list --plain --no-bundled
hermes -p seagull skills list
hermes -p seagull chat
```

插件应显示 `enabled`，并有 5 个 Seagull 技能。发送 `在吗` 检查固定问候。
