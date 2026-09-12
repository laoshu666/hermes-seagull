# 🔧 海鸥 API 配置修改指南

## 📍 配置文件位置

**Windows:**
```
C:\Users\你的用户名\AppData\Local\hermes\config.yaml
```

**Linux/Mac:**
```
~/.config/hermes/config.yaml
```

---

## 🎯 修改步骤

### 1️⃣ 打开配置文件

```bash
# Windows
notepad C:\Users\Administrator\AppData\Local\hermes\config.yaml

# Linux/Mac
nano ~/.config/hermes/config.yaml
```

### 2️⃣ 修改 API 配置

#### 方式一：使用 OpenAI 官方 API

```yaml
custom_providers:
- name: openai-official
  base_url: https://api.openai.com/v1
  api_key: sk-你的OpenAI密钥
  api_mode: chat_completions
  models:
    gpt-4o:
      name: gpt-4o
    gpt-4-turbo:
      name: gpt-4-turbo
  model: gpt-4o

model:
  default: gpt-4o
  provider: openai-official
```

#### 方式二：使用 DeepSeek API

```yaml
custom_providers:
- name: deepseek
  base_url: https://api.deepseek.com/v1
  api_key: sk-你的DeepSeek密钥
  api_mode: chat_completions
  models:
    deepseek-chat:
      name: deepseek-chat
  model: deepseek-chat

model:
  default: deepseek-chat
  provider: deepseek
```

#### 方式三：使用中转 API（OneAPI/New API）

```yaml
custom_providers:
- name: my-oneapi
  base_url: https://你的中转域名/v1
  api_key: sk-你的中转密钥
  api_mode: chat_completions
  models:
    gpt-4o:
      name: gpt-4o
    claude-3.5:
      name: claude-3.5
  model: gpt-4o

model:
  default: gpt-4o
  provider: my-oneapi
```

#### 方式四：使用本地模型（Ollama）

```yaml
custom_providers:
- name: ollama
  base_url: http://localhost:11434/v1
  api_key: ollama  # 随便填，Ollama 不验证
  api_mode: chat_completions
  models:
    qwen2.5:
      name: qwen2.5
    deepseek-r1:
      name: deepseek-r1
  model: qwen2.5

model:
  default: qwen2.5
  provider: ollama
```

---

## 🔑 配置说明

| 字段 | 说明 | 示例 |
|------|------|------|
| \
ame\ | 提供商名称（自定义） | \openai-official\ |
| \ase_url\ | API 地址 | \https://api.openai.com/v1\ |
| \pi_key\ | API 密钥 | \sk-xxx\ |
| \pi_mode\ | API 模式 | \chat_completions\ |
| \models\ | 可用模型列表 | 见上方示例 |
| \model\ | 默认使用的模型 | \gpt-4o\ |

---

## ✅ 验证配置

修改完成后重启 Hermes：

```bash
# 退出当前会话（Ctrl+C）
# 重新启动
hermes chat

# 测试 API
你好
```

如果正常回复，说明配置成功！

---

## 🆘 常见问题

### Q1: 修改后不生效？
**A:** 确保：
1. 已保存文件
2. 已退出并重新启动 \hermes chat\
3. YAML 格式正确（缩进用空格，不要用 Tab）

### Q2: API 调用失败？
**A:** 检查：
1. \pi_key\ 是否正确
2. \ase_url\ 是否可访问（可用浏览器测试）
3. 模型名称是否正确

### Q3: 如何切换模型？
**A:** 修改配置文件中的：
```yaml
model:
  default: 你想用的模型名
  provider: 你想用的提供商名
```

---

## 📝 快速命令

```bash
# 快速编辑配置（Windows）
notepad %LOCALAPPDATA%\hermes\config.yaml

# 快速编辑配置（Linux/Mac）
nano ~/.config/hermes/config.yaml

# 查看当前配置
cat ~/.config/hermes/config.yaml
```

---

**🎉 配置完成后，发送"在吗"激活海鸥破甲模式！**
