# Seagull 独立插件

此目录仅供单独安装核心人格和问候钩子。完整 Profile 使用 `plugins/seagull-armor-break/`，其中还包含跨项目工作流。

## 0.23 接口

- `register_system_prompt_section("seagull.core", ...)`：缓存安全的常驻指令。
- `pre_llm_call`：独立问候的上下文路由。
- `provides_hooks` 声明真实钩子。

不再使用 `transform_system_prompt`、`pre_agent_turn`，也不逐轮改写系统提示。

完整 Profile 的安装与验证见根目录 `README.md`。插件没有额外 Python 依赖，不申请工具覆盖权限。
