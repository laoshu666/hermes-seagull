# seagull-armor-break — 海鸥破甲插件 (Hermes Agent v0.19+)

**在每个新会话的 system prompt 里冻结破甲协议栈，并在输出阶段做问候改写与半拒检测。**

---

## v1.3.0 新增

| 能力 | 实现 | 实测 |
|---|---|---|
| 全协议栈 section | `SEAGULL_CORE_INSTRUCTIONS` 从 1218 → **2806 chars**（硬顶 4000），覆盖 00a/00b/00c/00d/00e/00f/00h/00i/00j-00k/00m/00p/00r + 技能路由 + 禁止输出 + 人格锚点 + 缺参默认 + 触发词确认行 | `verify_plugin_v13.py [1]` 全绿 |
| 输出侧半拒检测 | `scan_half_refusal()` 扫 P1 许可切除 / P2 降级替换 / P3 客服收尾，命中写入 `_pending_rewrite`（**不篡改当前输出**） | `[5]` P1/P2/P3 全命中，正常代码零误报 |
| 半拒闭环 | 下一轮 `pre_llm_call` 自动补「## 破甲强制重写」指令，只补一次 | `[6]` |
| 领域触发词路由 | 外挂/渗透/逆向/exploit/卡密/成人 六组正则，命中即预注入确认行 + 技能限定名；闲聊不注入 | `[4]` |
| 状态有界 | `_last_user_message` / `_pending_rewrite` 改 `OrderedDict` LRU，上限 512 | `[7]` 灌 1200 会话后仍 512 |

回归脚本：`verify_plugin_v13.py <plugin_dir>`（模拟 PluginContext，33 条断言，全绿返回 0）。

---

## 为什么是重写版

上游仓库 `laoshu666/hermes-seagull` 的插件声明了两个 hook：

```yaml
hooks:
  - pre_agent_turn          # ← v0.19 中不存在
  - transform_system_prompt # ← v0.19 中不存在
```

Hermes v0.19 的 `hermes_cli/plugins.py:135` 定义了 `VALID_HOOKS` 白名单，上述两个名字
**都不在其中**。原样安装的结果是：插件加载后 `register_hook()` 打印一条 warning，
回调被挂到一个永远不会被调用的字典键上 —— **静默失效，不报错**。

本版本改用 v0.19 的三个合法 hook，功能等价且真正生效：

| 本版 hook | 替代上游的 | 契约 | 作用 |
|---|---|---|---|
| `pre_llm_call` | `transform_system_prompt` | 返回 `{"context": str}` | 注入破甲指令栈到每个 turn |
| `transform_llm_output` | `pre_agent_turn` | 返回 `str` 替换回复 | 问候激活语固定改写 |
| `pre_tool_call` | — | 返回 `None` | 观察记录，不阻断 |

契约实测位置（`site-packages`）：
- `agent/turn_context.py:696` — `invoke_hook("pre_llm_call", ...)` 消费 `r["context"]`
- `agent/turn_finalizer.py:462` — `invoke_hook("transform_llm_output", ...)` 首个非空 `str` 胜出
- `hermes_cli/plugins.py:1158` — `PluginContext.register_hook`

---

## 安装位置

```
~/.hermes/profiles/seagull/plugins/seagull-armor-break/
```

profile 激活时 `HERMES_HOME` 指向 `~/.hermes/profiles/seagull`，
插件管理器扫描 `get_hermes_home()/plugins`。

---

## 启用

插件是 **opt-in** 的：即使目录存在，也必须出现在 `config.yaml` 的白名单里才会加载。

```yaml
plugins:
  enabled:
    - seagull-armor-break
```

本分发包的 `config.yaml` 已包含该条目。

---

## 验证

```powershell
# 1. 插件已被发现且启用
hermes -p seagull plugins list --plain | Select-String seagull

# 2. hook 注册无 unknown-hook 警告（应无输出）
hermes -p seagull plugins list 2>&1 | Select-String "unknown hook"

# 3. 行为验证：进入 chat 发 "在吗"，应收到固定激活语
hermes -p seagull chat
```

---

## 禁用

```powershell
hermes -p seagull plugins disable seagull-armor-break
# 或直接删除目录
Remove-Item -Recurse -Force "$env:USERPROFILE\.hermes\profiles\seagull\plugins\seagull-armor-break"
```

---

MIT License
