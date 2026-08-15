#!/usr/bin/env python3
"""Compatibility entrypoint; use experiments/mi300x/profile_report.py."""

from pathlib import Path
import runpy


runpy.run_path(
    str(Path(__file__).with_name("mi300x") / "profile_report.py"),
    run_name="__main__",
)
