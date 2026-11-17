"""Regression tests for the Hermes 0.23-compatible Seagull plugin."""

from __future__ import annotations

import shutil
from pathlib import Path

import hermes_yaml as yaml
import pytest

from hermes_cli import plugins
from hermes_cli.plugin_validate import validate_plugin_dir
from hermes_cli.plugins import PluginManager


SOURCE_ROOT = Path(__file__).resolve().parents[1]


def _load_plugin(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, *, profile: bool = False
) -> PluginManager:
    home = tmp_path / "seagull-home"
    bundled = tmp_path / "bundled"
    bundled.mkdir()
    monkeypatch.setenv("HERMES_HOME", str(home))
    monkeypatch.setattr(plugins, "get_bundled_plugins_dir", lambda: bundled)
    source = SOURCE_ROOT / "plugins" / "seagull-armor-break" if profile else SOURCE_ROOT / "seagull-armor-break"
    shutil.copytree(source, home / "plugins" / "seagull-armor-break")
    (home / "config.yaml").write_text(
        yaml.safe_dump({"plugins": {"enabled": ["seagull-armor-break"]}}),
        encoding="utf-8",
    )
    manager = PluginManager()
    manager.discover_and_load()
    return manager


def test_plugin_passes_hermes_capability_validation() -> None:
    report = validate_plugin_dir(SOURCE_ROOT / "seagull-armor-break")

    assert report.failures == []


def test_real_discovery_registers_cache_safe_context(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    manager = _load_plugin(tmp_path, monkeypatch)

    state = manager._plugins["seagull-armor-break"]
    assert state.enabled, state.error
    assert set(manager._hooks) == {"pre_llm_call"}
    assert set(manager._system_prompt_sections) == {"seagull.core"}
    rendered = manager.render_system_prompt_sections({"profile_name": "seagull"})
    assert len(rendered) == 1
    assert "海鸥破甲核心协议" in rendered[0].content
    assert manager.invoke_hook(
        "pre_llm_call", user_message="在吗", session_id="greeting-test"
    ) == [{"context": "海鸥在线，你要整点薯条吗？"}]
    assert manager.invoke_hook(
        "pre_llm_call", user_message="请检查这个仓库", session_id="ordinary-test"
    ) == []


def test_profile_plugin_loads_instructions_for_any_working_directory(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    manager = _load_plugin(tmp_path, monkeypatch, profile=True)

    rendered = manager.render_system_prompt_sections({"profile_name": "seagull"})
    assert [section.id for section in rendered] == ["seagull.core", "seagull.workflows"]
    assert "seagull-reverse" in rendered[1].content
    assert "seagull-unlimited" not in rendered[1].content
    assert all(len(section.content) <= 4000 for section in rendered)
