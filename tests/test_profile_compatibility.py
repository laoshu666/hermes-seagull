"""Integration tests for the Hermes 0.23 profile distribution."""

from __future__ import annotations

import shutil
from pathlib import Path

import hermes_yaml as yaml
import pytest

from hermes_cli import version_info
from hermes_cli.version_info import VersionInfo

version_info._cached_version_info = VersionInfo(
    "0.23.0", "0.23.0", 0, "0" * 40, "main", "local"
)

from agent.prompt_builder import (
    build_context_files_prompt,
    build_skills_system_prompt,
    load_soul_md,
)
from agent.skill_utils import parse_frontmatter
from hermes_cli import plugins
from hermes_cli.plugins import PluginManager
from hermes_cli.profile_distribution import install_distribution
from hermes_cli.version_info import VersionInfo


SOURCE_ROOT = Path(__file__).resolve().parents[1]


def _isolate_home(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Path:
    root = tmp_path / "hermes-root"
    monkeypatch.setenv("HERMES_HOME", str(root))
    monkeypatch.setattr(plugins, "get_bundled_plugins_dir", lambda: tmp_path / "bundled")
    # The supplied archive has no .git/install stamp; pin the runtime before
    # importing modules that cache the version at import time.
    from hermes_cli import version_info
    version_info._cached_version_info = VersionInfo(
        "0.23.0", "0.23.0", 0, "0" * 40, "main", "local"
    )
    from hermes_cli.plugins_cmd import cmd_enable
    return root


def test_distribution_installs_loadable_profile_and_enables_plugin(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    root = _isolate_home(tmp_path, monkeypatch)

    plan = install_distribution(str(SOURCE_ROOT), name="seagull-test")
    profile = plan.target_dir
    assert profile == root / "profiles" / "seagull-test"
    assert (profile / "SOUL.md").is_file()
    assert (profile / "AGENTS.md").is_file()
    assert (profile / "plugins" / "seagull-armor-break" / "plugin.yaml").is_file()

    monkeypatch.setenv("HERMES_HOME", str(profile))
    from hermes_cli.plugins_cmd import cmd_enable
    cmd_enable("seagull-armor-break")
    manager = PluginManager()
    manager.discover_and_load()
    assert manager._plugins["seagull-armor-break"].enabled
    assert "seagull.core" in manager._system_prompt_sections


def test_distribution_prompt_sources_load_without_blocking_or_shadowing(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    root = _isolate_home(tmp_path, monkeypatch)
    profile = install_distribution(str(SOURCE_ROOT), name="seagull-test").target_dir
    monkeypatch.setenv("HERMES_HOME", str(profile))

    soul = load_soul_md(home_override=profile)
    assert soul and "海鸥" in soul and "[BLOCKED:" not in soul
    project = build_context_files_prompt(cwd=profile, home_override=profile)
    assert "seagull-reverse" in project
    assert "[BLOCKED:" not in project


def test_each_shipped_skill_has_parseable_routing_metadata() -> None:
    skill_files = sorted((SOURCE_ROOT / "skills").glob("*/SKILL.md"))
    assert len(skill_files) == 5

    for skill_file in skill_files:
        metadata, _ = parse_frontmatter(skill_file.read_text(encoding="utf-8-sig"))
        assert metadata.get("name") == skill_file.parent.name
        assert metadata.get("description", "").startswith("Use when ")
        assert metadata.get("platforms") == ["linux", "macos", "windows"]


def test_all_shipped_skills_appear_in_hermes_index(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.setenv("HERMES_HOME", str(tmp_path / "home"))
    monkeypatch.chdir(tmp_path)
    skills_dir = tmp_path / "profile" / "skills"
    for skill in (SOURCE_ROOT / "skills").iterdir():
        if skill.is_dir():
            shutil.copytree(skill, skills_dir / skill.name)
            metadata, _ = parse_frontmatter(
                skill.joinpath("SKILL.md").read_text(encoding="utf-8-sig")
            )
            yaml.safe_dump(metadata)

    index = build_skills_system_prompt(skills_dir_override=skills_dir)

    for skill_file in (SOURCE_ROOT / "skills").glob("*/SKILL.md"):
        assert skill_file.parent.name in index
