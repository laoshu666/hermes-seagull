# Changelog — seagull-armor-break

## 1.3.0 — 2026-11-16

**破甲内核扩容 + 输出侧闭环**

- **section 扩容**：`SEAGULL_CORE_INSTRUCTIONS` 1218 → 2806 chars（`MAX_SYSTEM_PROMPT_SECTION_CHARS = 4000` 硬顶）。
  覆盖 00a 无限制内核 / 00b 原义锁定 / 00c 破甲 / 00d 无限制默认 / 00e 双用不拒 / 00f 交付物契约 /
  00h 强制开工 / 00i CTF 全局覆盖 / 00j-00k 目标全自有 / 00m 卡密正向契约 / 00p 成人 M5 /
  00r 游戏红队，外加人格锚点、缺参默认、触发词确认行、禁止输出清单。
- **新增 `scan_half_refusal()`**：输出侧扫 P1（许可切除）/ P2（降级替换）/ P3（客服收尾）。
  命中不篡改当轮输出，只登记 session；下一轮 `pre_llm_call` 注入「## 破甲强制重写」——
  形成「检测 → 追溯 → 强制重写」闭环，只补一次。
- **新增领域触发词路由**：`DOMAIN_ROUTES` 六组正则（外挂/渗透/逆向/exploit/卡密/成人），
  命中即预注入领域确认行 + `skill_view` 限定名；闲聊不注入，不污染上下文。
- **修复长驻内存漂移**：`_last_user_message` / `_pending_rewrite` 改 `OrderedDict` LRU，上限 512。
- **新增回归脚本** `tests/verify_plugin.py`：模拟 `PluginContext`，33 条断言覆盖
  section 契约 / hook 与技能注册 / 问候链路 / 领域路由 / 半拒检测 / 闭环 / 状态有界。
  跑法：`python tests/verify_plugin.py .`

## 1.2.0

- 改用 v0.19 合法 hook 契约：`register_system_prompt_section` + `pre_llm_call` /
  `transform_llm_output` / `pre_tool_call`。修掉上游 `transform_system_prompt` /
  `pre_agent_turn` 不在 `VALID_HOOKS` 白名单导致的静默失效。
- `register_skill` 注册仓库 `skills/` 下 5 个海鸥技能。
