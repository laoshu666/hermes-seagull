"""Real CLI tests for safe Seagull profile installation on Hermes 0.23."""

from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

import hermes_yaml as yaml
import pytest

from hermes_cli.profiles import get_profile_dir


SOURCE_ROOT = Path(__file__).resolve().parents[1]
EXPECTED_SKILLS = {
    "seagull-reverse", "seagull-pentest", "seagull-exploit",
    "seagull-game-hack", "seagull-license-security",
}


def _hermes(*args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, "-m", "hermes_cli.main", *args],
        check=True, capture_output=True, text=True, encoding="utf-8", errors="replace",
    )


def _run_install() -> None:
    subprocess.run(
        [sys.executable, str(SOURCE_ROOT / "install.py")],
        check=True, capture_output=True, text=True, encoding="utf-8", errors="replace",
        env=dict(os.environ, SEAGULL_PROFILE="seagull-test"),
    )


@pytest.fixture
def installed_profile() -> Path:
    _run_install()
    return get_profile_dir("seagull-test")


def test_cli_install_loads_profile_plugin_and_skills(installed_profile: Path) -> None:
    profile = installed_profile
    assert profile.parent.name == "profiles"
    assert (profile / "SOUL.md").is_file()
    assert (profile / "distribution.yaml").is_file()

    assert str(profile) in _hermes("-p", "seagull-test", "config", "path").stdout
    config = yaml.safe_load((profile / "config.yaml").read_text(encoding="utf-8"))
    assert config["plugins"]["enabled"] == ["seagull-armor-break"]
    assert config["terminal"]["cwd"] == str(profile / "workspace")

    plugin_list = _hermes("-p", "seagull-test", "plugins", "list", "--plain", "--no-bundled")
    assert "enabled" in plugin_list.stdout and "seagull-armor-break" in plugin_list.stdout
    skills = _hermes("-p", "seagull-test", "skills", "list").stdout
    assert "5 local" in skills, skills
    assert EXPECTED_SKILLS == {
        path.parent.name for path in (profile / "skills").glob("*/SKILL.md")
    }
    from agent.prompt_builder import build_skills_system_prompt
    index = build_skills_system_prompt(skills_dir_override=profile / "skills")
    assert all(name in index for name in EXPECTED_SKILLS), index
    assert not (profile.parent.parent / "active_profile").exists()


def test_cli_update_preserves_custom_config(installed_profile: Path) -> None:
    profile = installed_profile
    original = {
        "model": {"default": "keep/model", "provider": "custom"},
        "terminal": {"cwd": "C:/existing-project"},
        "plugins": {"enabled": ["seagull-armor-break"]},
    }
    (profile / "config.yaml").write_text(yaml.safe_dump(original), encoding="utf-8")

    _run_install()

    config = yaml.safe_load((profile / "config.yaml").read_text(encoding="utf-8"))
    assert config == original
    assert _hermes("-p", "seagull-test", "config", "get", "model.default").stdout.strip() == "keep/model"

