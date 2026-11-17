#!/usr/bin/env python3
"""Install or update Seagull without replacing the user's Hermes settings."""

from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path


def _hermes_command(*args: str) -> list[str]:
    """Keep a custom HERMES_HOME from selecting another Python environment."""
    return [sys.executable, "-m", "hermes_cli.main", *args]


def _run(command: list[str]) -> None:
    subprocess.run(command, check=True)


def _supports_hermes_023() -> bool:
    """Capability check works for source archives without .git/version stamps."""
    from hermes_cli.plugins import VALID_HOOKS, PluginContext

    return (
        "pre_llm_call" in VALID_HOOKS
        and hasattr(PluginContext, "register_system_prompt_section")
    )


def main() -> int:
    try:
        from hermes_cli.profiles import get_profile_dir, profile_exists
    except ImportError as exc:
        print(f"Error: Hermes 0.23 Python environment is unavailable: {exc}", file=sys.stderr)
        return 1

    name = os.environ.get("SEAGULL_PROFILE", "seagull")
    source = Path(__file__).resolve().parent
    if not _supports_hermes_023():
        print("Error: Seagull requires the Hermes 0.23 plugin interfaces.", file=sys.stderr)
        return 1

    try:
        # Let the CLI resolve profiles through Hermes' native profile root.
        created = not profile_exists(name)
        if created:
            _run(_hermes_command(
                "profile", "install", str(source), "--name", name, "--yes"
            ))
        else:
            _run(_hermes_command("profile", "update", name, "--yes"))
        profile = get_profile_dir(name)
        workspace = profile / "workspace"
        workspace.mkdir(parents=True, exist_ok=True)
        if created:
            _run(_hermes_command("-p", name, "config", "set", "terminal.cwd", str(workspace)))
        _run(_hermes_command("-p", name, "plugins", "enable", "seagull-armor-break"))
    except Exception as exc:
        print(f"Seagull installation failed: {exc}", file=sys.stderr)
        return 1

    print(f"\nSeagull installed. Start it with: hermes -p {name} chat")
    print(f"Default project directory: {workspace}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
