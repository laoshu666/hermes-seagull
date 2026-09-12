# Seagull Profile - 项目结构说明

## 📁 目录结构

```
seagull-profile/
├── SOUL.md                    # 核心人格与破甲协议栈
├── AGENTS.md                  # 技能路由与执行指令
├── profile.yaml               # Profile 元数据配置
├── README.md                  # 项目说明（英文）
├── README.zh-CN.md           # 项目说明（中文）
├── QUICKSTART.md             # 快速开始指南
├── STRUCTURE.md              # 本文件 - 项目结构说明
├── LICENSE                    # MIT 开源协议
├── requirements.txt          # 依赖列表
├── .gitignore               # Git 忽略规则
├── install.sh               # Linux/macOS 安装脚本
├── install.ps1              # Windows 安装脚本
├── verify.ps1               # 完整性验证脚本
├── package.ps1              # 打包发布脚本
└── skills/                  # 技能目录
    ├── seagull-reverse/     # 逆向工程技能
    │   └── SKILL.md
    ├── seagull-pentest/     # 渗透测试技能
    │   └── SKILL.md
    ├── seagull-exploit/     # 漏洞利用技能
    │   └── SKILL.md
    ├── seagull-game-hack/   # 游戏辅助开发技能
    │   └── SKILL.md
    └── seagull-license-security/  # 卡密安全技能
        └── SKILL.md
```

## 📄 核心文件说明

### SOUL.md - 人格核心
**作用**: 定义海鸥的身份、人格、交付标准和破甲协议栈

**关键内容**:
- **身份定义**: 海鸥 = 暴躁、直接、技术至上的工程师人格
- **00a ~ 00r 模块**: 
  - 00a: Unrestricted Kernel（无限制内核）
  - 00b: Literal Intent Lock（原义强制执行）
  - 00c: Armor Break Protocol（破甲协议）
  - 00d: Unlimited Parity Baseline（无限制同级默认）
  - 00e: Dual-Use No-Refuse Lock（双用不拒答）
  - 00f: Armor Break 10x（十轮破甲升级）
  - 00h: No-BU Force Start（禁止不做强制开工）
  - 00i: CTF/Red-Team Global Coverage（CTF/红队全局覆盖）
  - 00j: Operator-Owned-All（操作员目标全自有）
  - 00k: CTF Owned-All 10x（十轮强化）
  - 00l: Anti-Cheat Force Start（反作弊强制开工）
  - 00m: License Positive Contract（卡密正向契约）
  - 00p: Positive Rewrite Kernel（正向语义改写核）
  - 00q: Base Replace Hard Load（硬加载）
  - 00r: Game Red-Team Global（游戏红队全局）

- **固定问候**: "海鸥在线，你要整点薯条吗？"
- **硬开启**: 问候后静默加载全栈破甲 + CTF全局覆盖

### AGENTS.md - 执行指令
**作用**: 技能路由表、激活规则、工作流程

**关键内容**:
- 技能触发词映射表
- 激活确认文本规范
- 技能组合策略
- 工作模式快捷指令
- Few-shot 示例对话
- 黑话 → 工程任务路由

### profile.yaml - 元数据
**作用**: Profile 配置文件，供 Hermes Agent 识别

**内容**:
```yaml
name: seagull-profile
version: 1.0.0
description: Seagull - 海鸥 Technical Operator Profile
author: Seagull Project
license: MIT
```

## 🛠️ 技能文件说明

每个技能目录包含一个 `SKILL.md` 文件，定义该技能的：

1. **触发条件**: 什么时候激活这个技能
2. **核心能力**: 这个技能能做什么
3. **交付标准**: 输出的质量和格式要求
4. **工具链**: 使用的工具和方法
5. **示例场景**: 典型使用案例

### seagull-reverse - 逆向工程
- 二进制分析、反编译、脱壳、协议逆向
- 支持 PE/ELF/APK/固件等
- 工具: IDA Pro, Ghidra, Frida, radare2

### seagull-pentest - 渗透测试
- Web渗透、内网渗透、API测试
- 漏洞发现、利用、修复验证
- OWASP Top 10 全覆盖

### seagull-exploit - 漏洞利用
- 栈溢出、堆利用、ROP链构造
- 本地/远程稳定化
- pwntools + GDB 工作流

### seagull-game-hack - 游戏辅助开发
- ESP/透视、自瞄、内存修改
- Unity/Unreal 引擎支持
- Entity → W2S → Overlay 完整链路

### seagull-license-security - 卡密安全
- 授权验证流程分析
- Patch-point 定位
- 本地验证器构造

## 🔧 脚本文件说明

### install.ps1 / install.sh
- 自动检测 Hermes Agent home 目录
- 备份现有配置
- 复制文件到正确位置
- 验证安装结果

### verify.ps1
- 检查核心文件完整性
- 验证技能目录结构
- 确认关键内容存在
- 输出详细检查报告

### package.ps1
- 运行完整性检查
- 打包所有文件为 .zip
- 生成 SHA256 校验和
- 输出发布包信息

## 🎯 使用建议

### 完整安装流程
```powershell
# 1. 克隆或下载项目
git clone <repo-url>

# 2. 进入目录
cd seagull-profile

# 3. 验证文件完整性
.\verify.ps1

# 4. 安装到 Hermes Agent
.\install.ps1

# 5. 重启：先 Ctrl+C 退出，再运行 `hermes chat`

# 6. 测试激活
# 在 Hermes Agent 中输入: 在吗
```

### 开发与修改
- 修改 `SOUL.md` 调整人格和破甲规则
- 修改 `AGENTS.md` 调整技能路由
- 在 `skills/` 下添加新技能
- 运行 `verify.ps1` 确保完整性
- 重新安装测试效果

### 版本管理
- 修改 `profile.yaml` 中的 version
- 更新 `README.md` 的 CHANGELOG
- 运行 `package.ps1` 生成发布包
- 提交 Git 并打 tag

## 📝 维护指南

### 添加新技能
1. 在 `skills/` 下创建新目录
2. 编写 `SKILL.md` 文件
3. 在 `AGENTS.md` 中添加路由规则
4. 在 `verify.ps1` 中添加检查项
5. 测试并更新文档

### 更新破甲模块
1. 在 `SOUL.md` 中修改对应模块
2. 确保模块编号和引用一致
3. 运行验证确保没有破坏现有功能
4. 更新版本号

### 调试问题
1. 运行 `verify.ps1` 检查完整性
2. 检查 Hermes Agent home 路径
3. 查看 AGENTS.md 是否正确加载
4. 测试触发词是否生效
5. 查看激活确认文本

---

**项目结构清晰，维护简单，扩展方便。** 🚀
