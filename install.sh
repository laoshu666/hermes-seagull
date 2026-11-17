#!/bin/sh
# Seagull installer for Hermes 0.23 (Linux/macOS)
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
if [ -n "${HERMES_PYTHON:-}" ]; then
    PYTHON=$HERMES_PYTHON
elif command -v python3 >/dev/null 2>&1; then
    PYTHON=python3
elif command -v python >/dev/null 2>&1; then
    PYTHON=python
else
    echo "Python not found. Install Hermes 0.23 or set HERMES_PYTHON." >&2
    exit 1
fi

if [ "$#" -gt 0 ]; then
    SEAGULL_PROFILE=$1
    export SEAGULL_PROFILE
fi
exec "$PYTHON" "$SCRIPT_DIR/install.py"
