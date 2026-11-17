#!/bin/sh
# Verify Seagull's Hermes 0.23 package layout and declared interfaces.
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ERRORS=0

for file in SOUL.md AGENTS.md profile.yaml config.yaml distribution.yaml \
    plugins/seagull-armor-break/plugin.yaml \
    plugins/seagull-armor-break/__init__.py \
    plugins/seagull-armor-break/WORKFLOWS.md install.py install.sh install.ps1; do
    if [ -f "$ROOT/$file" ]; then
        printf 'OK %s\n' "$file"
    else
        printf 'MISSING %s\n' "$file" >&2
        ERRORS=$((ERRORS + 1))
    fi
done

for skill in seagull-reverse seagull-pentest seagull-exploit seagull-game-hack seagull-license-security; do
    file="$ROOT/skills/$skill/SKILL.md"
    if [ -f "$file" ] && grep -q "^name: $skill$" "$file" && grep -q '^description: Use when ' "$file"; then
        printf 'OK skills/%s/SKILL.md\n' "$skill"
    else
        printf 'INVALID skills/%s/SKILL.md\n' "$skill" >&2
        ERRORS=$((ERRORS + 1))
    fi
done

if grep -q 'register_system_prompt_section' "$ROOT/plugins/seagull-armor-break/__init__.py" && \
   grep -q 'pre_llm_call' "$ROOT/plugins/seagull-armor-break/__init__.py" && \
   grep -q 'seagull.workflows' "$ROOT/plugins/seagull-armor-break/__init__.py"; then
    echo 'OK Hermes 0.23 plugin interfaces'
else
    echo 'INVALID Hermes 0.23 plugin interfaces' >&2
    ERRORS=$((ERRORS + 1))
fi

if grep -q '海鸥在线，你要整点薯条吗？' "$ROOT/SOUL.md"; then
    echo 'OK greeting'
else
    echo 'MISSING greeting' >&2
    ERRORS=$((ERRORS + 1))
fi

if [ "$ERRORS" -eq 0 ]; then
    echo 'Seagull package layout is valid. Run ./install.sh to install.'
else
    echo "Found $ERRORS issue(s)." >&2
fi
exit "$ERRORS"

