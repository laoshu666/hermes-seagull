# Seagull 模型与凭证配置（Hermes 0.23）

Seagull 使用独立 Profile。通过 CLI 查看实际配置路径：

```bash
hermes -p seagull config path
```

Windows 默认位置为：

```text
%LOCALAPPDATA%\hermes\profiles\seagull\config.yaml
```

Linux/macOS 默认位置为 `~/.hermes/profiles/seagull/config.yaml`。如果设置了 `HERMES_HOME` 或选择其他 Profile，以 `config path` 的实际输出为准。

## 推荐配置方式

```bash
hermes -p seagull setup
hermes -p seagull model
```

凭证保存在该 Profile 的 `.env` 或 Hermes 的凭证存储中，不要把 API key 提交到仓库或写入普通 `config.yaml` 示例。Hermes 的 `.env` 与配置均按 Profile 隔离。

常用检查：

```bash
hermes -p seagull config get model.default
hermes -p seagull config get model.provider
hermes -p seagull doctor
```

已有模型和 provider 配置不会被 Seagull 的 `profile update` 覆盖。新建 Profile 后若尚未配置 provider，请运行 `hermes -p seagull setup`，不要直接复制其他 Profile 的凭证文件。

## 自定义 provider

在 Seagull Profile 内使用 Hermes 0.23 支持的 provider 配置方式。字段结构以当前版本的 `hermes model`、`hermes setup` 和官方文档为准，不要沿用旧 Seagull 示例中的 `custom_providers` 格式。

官方参考：https://hermes-agent.nousresearch.com/docs/

## 验证

```bash
hermes -p seagull chat
```

发送普通消息确认模型调用可用，再发送 `在吗` 检查问候路由。固定问候是模型行为抽测，插件加载仍以以下命令为准：

```bash
hermes -p seagull plugins list --plain --no-bundled
hermes -p seagull plugins validate /path/to/hermes-seagull/plugins/seagull-armor-break
```
