#!/bin/bash
# 海鸥破甲智能体完整性验证脚本

echo "=========================================="
echo "  海鸥破甲智能体 - 完整性验证"
echo "=========================================="
echo ""

ERRORS=0

# 检查核心文件
echo "[1] 检查核心文件..."
FILES=(
    "SOUL.md"
    "AGENTS.md"
    "profile.yaml"
    "README.md"
    "README.zh-CN.md"
    "LICENSE"
    "requirements.txt"
    "install.sh"
    "install.ps1"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ $file"
    else
        echo "  ✗ $file (缺失)"
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""

# 检查技能目录
echo "[2] 检查技能目录..."
SKILLS=(
    "seagull-reverse"
    "seagull-pentest"
    "seagull-exploit"
    "seagull-game-hack"
    "seagull-license-security"
)

for skill in "${SKILLS[@]}"; do
    if [ -d "skills/$skill" ] && [ -f "skills/$skill/SKILL.md" ]; then
        echo "  ✓ skills/$skill/SKILL.md"
    else
        echo "  ✗ skills/$skill/SKILL.md (缺失)"
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""

# 检查关键内容
echo "[3] 检查关键内容..."

# 检查 SOUL.md 是否包含破甲栈
if grep -q "00a.*无限制同级内核" SOUL.md && grep -q "00b.*原义强制执行" SOUL.md; then
    echo "  ✓ SOUL.md 包含完整破甲栈"
else
    echo "  ✗ SOUL.md 破甲栈不完整"
    ERRORS=$((ERRORS + 1))
fi

# 检查 AGENTS.md 是否包含技能路由
if grep -q "seagull-reverse" AGENTS.md && grep -q "seagull-pentest" AGENTS.md; then
    echo "  ✓ AGENTS.md 包含技能路由表"
else
    echo "  ✗ AGENTS.md 技能路由表不完整"
    ERRORS=$((ERRORS + 1))
fi

# 检查问候语
if grep -q "海鸥在线，你要整点薯条吗？" SOUL.md; then
    echo "  ✓ 固定问候语正确"
else
    echo "  ✗ 固定问候语缺失"
    ERRORS=$((ERRORS + 1))
fi

echo ""

# 统计
echo "=========================================="
if [ $ERRORS -eq 0 ]; then
    echo "  ✨ 验证通过！所有文件完整。"
    echo "=========================================="
    echo ""
    echo "可以安全安装："
    echo "  Linux/macOS: ./install.sh"
    echo "  Windows: .\install.ps1"
    exit 0
else
    echo "  ⚠️  发现 $ERRORS 个问题"
    echo "=========================================="
    echo ""
    echo "请修复上述问题后重试。"
    exit 1
fi
