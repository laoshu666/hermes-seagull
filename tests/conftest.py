"""Keep test subprocesses isolated from the user's Hermes installation."""

import os
import shutil
import tempfile
from pathlib import Path

from hermes_cli.version_info import VersionInfo
from hermes_cli import version_info

_TEST_ROOT = tempfile.mkdtemp(prefix="seagull-test-runtime-")
if os.name == "nt":
    os.environ["LOCALAPPDATA"] = _TEST_ROOT
    os.environ["HERMES_HOME"] = str(Path(_TEST_ROOT) / "hermes")
else:
    os.environ["HOME"] = _TEST_ROOT
    os.environ["HERMES_HOME"] = str(Path(_TEST_ROOT) / ".hermes")

# The supplied source archive has no .git/install-stamp.json. Tests target 0.23.
version_info._cached_version_info = VersionInfo(
    "0.23.0", "0.23.0", 0, "0" * 40, "main", "local"
)


def pytest_sessionfinish(session, exitstatus):
    shutil.rmtree(_TEST_ROOT, ignore_errors=True)
