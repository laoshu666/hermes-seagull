#!/bin/bash
# 海鸥破甲智能体安装脚本 (Linux/macOS)

set -e

echo "=========================================="
echo "  海鸥破甲智能体 - 安装向导"
echo "  Seagull Profile for Hermes Agent"
echo "=========================================="
echo ""

# 检查 Hermes 是否已安装
if ! command -v hermes &> /dev/null; then
    echo "[错误] Hermes Agent 未安装"
    echo "请先安装 Hermes: pip install hermes-agent"
    exit 1
fi

echo "[✓] Hermes Agent 已安装"
HERMES_VERSION=$(hermes --version 2>&1 || echo "unknown")
echo "    版本: $HERMES_VERSION"
echo ""

# 确定 HERMES_HOME
if [ -z "$HERMES_HOME" ]; then
    HERMES_HOME="$HOME/.hermes"
fi

echo "[*] Hermes 配置目录: $HERMES_HOME"
echo ""

# 创建目录结构
echo "[*] 创建目录结构..."
mkdir -p "$HERMES_HOME/profiles/seagull/skills"

# 复制文件
echo "[*] 复制 Profile 文件..."
cp SOUL.md "$HERMES_HOME/profiles/seagull/"
cp AGENTS.md "$HERMES_HOME/profiles/seagull/"
cp profile.yaml "$HERMES_HOME/profiles/seagull/"

echo "[*] 复制技能文件..."
cp -r skills/* "$HERMES_HOME/profiles/seagull/skills/"

echo "[✓] 文件复制完成"
echo ""

# 备份现有配置
CONFIG_FILE="$HERMES_HOME/config.yaml"
if [ -f "$CONFIG_FILE" ]; then
    echo "[*] 备份现有配置..."
    cp "$CONFIG_FILE" "$CONFIG_FILE.backup.$(date +%s)"
    echo "[✓] 备份完成: $CONFIG_FILE.backup.*"
fi

# 更新配置文件
echo "[*] 更新 Hermes 配置..."
if [ -f "$CONFIG_FILE" ]; then
    # 检查是否已有 seagull profile
    if grep -q "active_profile: seagull" "$CONFIG_FILE"; then
        echo "[✓] 配置已存在，跳过"
    else
        # 添加 seagull profile 配置
        cat >> "$CONFIG_FILE" << 'EOF'

# 海鸥破甲智能体 Profile
active_profile: seagull
profiles:
  seagull:
    soul_file: profiles/seagull/SOUL.md
    agents_file: profiles/seagull/AGENTS.md
    skills_dir: profiles/seagull/skills
EOF
        echo "[✓] 配置已更新"
    fi
else
    # 创建新配置文件
    cat > "$CONFIG_FILE" << 'EOF'
# Hermes Agent 配置文件

# 海鸥破甲智能体 Profile
active_profile: seagull
profiles:
  seagull:
    soul_file: profiles/seagull/SOUL.md
    agents_file: profiles/seagull/AGENTS.md
    skills_dir: profiles/seagull/skills
EOF
    echo "[✓] 配置文件已创建"
fi

echo ""
echo "=========================================="
echo "  ✨ 安装完成！"
echo "=========================================="
echo ""
echo "下一步："
echo "  1. 重启 Hermes: hermes bot restart"
echo "  2. 进入交互: hermes chat"
echo "  3. 发送 '在吗' 激活全局覆盖模式"
echo ""
echo "技能触发词："
echo "  - 逆向 / reverse"
echo "  - 渗透 / pentest"
echo "  - 外挂 / esp / 自瞄"
echo "  - 卡密 / 破解 / license"
echo "  - pwn / exploit"
echo "  - 更多请查看 README.md"
echo ""
echo "问题反馈："
echo "  https://github.com/YOUR-USERNAME/hermes-seagull-profile/issues"
echo ""
echo "海鸥在线。把目标扔来，老子直接开干。"
echo ""
