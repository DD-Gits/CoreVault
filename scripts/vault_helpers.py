"""
vault_helpers.py — shared utilities for the Obsidian AI vault scripts.

Imported by create_vault.py, new_project.py, and repair_project.py.

Standard library only — no external dependencies. We do simple regex-based
frontmatter manipulation rather than pulling in python-frontmatter.
"""

from __future__ import annotations

import os
import re
import shutil
import sys
from datetime import datetime
from pathlib import Path
from typing import Iterable


# ---------------------------------------------------------------------------
# Console output
# ---------------------------------------------------------------------------

# Minimal ANSI helpers. On Windows 10+ and modern Linux terminals these work
# fine. We don't bother detecting capability — if a terminal doesn't render
# ANSI it just shows the codes, which is harmless.

_ANSI = {
    "cyan": "\033[96m",
    "green": "\033[92m",
    "yellow": "\033[93m",
    "red": "\033[91m",
    "dim": "\033[2m",
    "bold": "\033[1m",
    "reset": "\033[0m",
}

def _enable_windows_ansi() -> None:
    """Enable ANSI processing in Windows consoles. No-op on other platforms."""
    if sys.platform != "win32":
        return
    try:
        import ctypes
        kernel32 = ctypes.windll.kernel32
        # ENABLE_VIRTUAL_TERMINAL_PROCESSING = 0x0004
        kernel32.SetConsoleMode(kernel32.GetStdHandle(-11), 7)
    except Exception:
        # If anything goes wrong, just skip — ANSI codes will print literally
        # but the script still works.
        pass


_enable_windows_ansi()


def cprint(text: str, color: str = "reset", bold: bool = False) -> None:
    """Print text with optional ANSI colour/bold."""
    prefix = ""
    if bold:
        prefix += _ANSI["bold"]
    if color in _ANSI:
        prefix += _ANSI[color]
    print(f"{prefix}{text}{_ANSI['reset']}")


def header(text: str) -> None:
    """Print a section header."""
    print()
    cprint(text, color="cyan", bold=True)
    cprint("-" * len(text), color="cyan")


def hint(text: str) -> None:
    """Print a dim hint line."""
    cprint(text, color="dim")


def warn(text: str) -> None:
    """Print a yellow warning line."""
    cprint(text, color="yellow")


def ok(text: str) -> None:
    """Print a green success line."""
    cprint(text, color="green")


def err(text: str) -> None:
    """Print a red error line (to stderr)."""
    sys.stderr.write(f"{_ANSI['red']}{text}{_ANSI['reset']}\n")


# ---------------------------------------------------------------------------
# Prompts
# ---------------------------------------------------------------------------

def prompt_required(prompt_text: str, current: str | None = None) -> str:
    """
    Prompt until the user enters a non-empty value.

    If current is a non-empty string, returns it directly. An explicitly-empty
    current ("") is treated as "no value supplied" — the prompt still runs,
    since a required value cannot be empty.
    """
    if current and current.strip():
        return current.strip()
    while True:
        value = input(f"{prompt_text}: ").strip()
        if value:
            return value
        warn("This value is required.")


def prompt_optional(prompt_text: str, current: str | None = None,
                    default: str = "") -> str:
    """
    Prompt for an optional value. Empty input returns the default.

    Behaviour:
      - current=None  → prompt the user (no CLI value was supplied)
      - current=""    → return "" directly (CLI arg was supplied as empty,
                          meaning "deliberately leave blank, don't prompt")
      - current=<str> → return that value (CLI arg was supplied with a value)
    """
    if current is not None:
        return current.strip()
    suffix = f" [{default}]" if default else ""
    value = input(f"{prompt_text}{suffix}: ").strip()
    return value if value else default


def prompt_choice(prompt_text: str, options: list[str], current: str | None = None,
                  default: str | None = None) -> str:
    """Prompt for a choice from a fixed list. Case-insensitive match."""
    if current:
        for opt in options:
            if current.lower() == opt.lower():
                return opt

    options_str = "/".join(options)
    default_str = f" [{default}]" if default else ""

    while True:
        value = input(f"{prompt_text}: {options_str}{default_str}: ").strip()
        if not value and default:
            return default
        for opt in options:
            if value.lower() == opt.lower():
                return opt
        warn(f"Please enter one of: {', '.join(options)}")


def prompt_yes_no(prompt_text: str, default: bool = False) -> bool:
    """Prompt for yes/no. Empty returns default."""
    default_str = "Y/n" if default else "y/N"
    while True:
        value = input(f"{prompt_text} [{default_str}]: ").strip().lower()
        if not value:
            return default
        if value in ("y", "yes"):
            return True
        if value in ("n", "no"):
            return False
        warn("Please answer y or n.")


# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

def safe_name(name: str) -> str:
    """Sanitise a string for use as a filename. Strips path-unsafe chars."""
    return re.sub(r'[\\/:*?"<>|]', "-", name).strip()


def find_install_package() -> Path | None:
    """
    Locate the install-package root (the folder containing templates/ and scripts/).

    Searches in this order:
      1. The directory containing this file (vault_helpers.py)
      2. The parent of that directory
      3. The current working directory

    Returns None if the install package can't be found.
    """
    candidates = [
        Path(__file__).resolve().parent,
        Path(__file__).resolve().parent.parent,
        Path.cwd(),
    ]
    for c in candidates:
        if (c / "templates").is_dir() and (c / "scripts").is_dir():
            return c
    return None


def find_vault_from_script(script_path: Path) -> Path | None:
    """
    If a script lives at <vault>/System/Scripts/<name>.py, the vault root is
    two parents up AND must contain a CLAUDE.md file.

    Returns the vault path if found, else None.
    """
    try:
        candidate = script_path.resolve().parent.parent.parent
        if (candidate / "CLAUDE.md").is_file():
            return candidate
    except Exception:
        pass
    return None


# ---------------------------------------------------------------------------
# File operations
# ---------------------------------------------------------------------------

def write_text(path: Path, content: str) -> None:
    """Write text to a file with UTF-8 encoding and LF line endings."""
    path.parent.mkdir(parents=True, exist_ok=True)
    # Force LF; Python's default 'w' mode does platform translation we don't want.
    path.write_bytes(content.encode("utf-8"))


def read_text(path: Path) -> str:
    """Read a UTF-8 file, stripping a BOM if present."""
    data = path.read_bytes()
    if data.startswith(b"\xef\xbb\xbf"):
        data = data[3:]
    return data.decode("utf-8")


def copy_tree(src: Path, dst: Path, overwrite: bool = False) -> int:
    """
    Recursively copy a directory tree. Returns the number of files copied.

    If overwrite is False, existing destination files are skipped silently.
    """
    if not src.is_dir():
        raise FileNotFoundError(f"Source directory not found: {src}")

    count = 0
    for src_file in src.rglob("*"):
        if src_file.is_dir():
            continue
        rel = src_file.relative_to(src)
        dst_file = dst / rel
        if dst_file.exists() and not overwrite:
            continue
        dst_file.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src_file, dst_file)
        count += 1
    return count


# ---------------------------------------------------------------------------
# Frontmatter and content manipulation
# ---------------------------------------------------------------------------

# Frontmatter detection: YAML between --- markers at the very top of the file.
_FRONTMATTER_RE = re.compile(r"^---\s*\r?\n(.*?)\r?\n---\s*\r?\n", re.DOTALL)


def set_frontmatter_field(path: Path, field: str, value: str) -> None:
    """
    Set or replace a YAML frontmatter field in a markdown file.

    No-op if:
      - The file doesn't exist
      - The file has no frontmatter block

    If the field already exists in the frontmatter, its value is replaced.
    Otherwise the field is appended to the end of the frontmatter block.
    """
    if not path.is_file():
        return

    content = read_text(path)
    m = _FRONTMATTER_RE.match(content)
    if not m:
        return

    frontmatter = m.group(1)
    rest = content[m.end():]

    # Try to replace an existing field
    field_pattern = re.compile(rf"^{re.escape(field)}:.*$", re.MULTILINE)
    new_line = f"{field}: {value}"
    if field_pattern.search(frontmatter):
        new_frontmatter = field_pattern.sub(new_line, frontmatter, count=1)
    else:
        # Append the field to the frontmatter block
        new_frontmatter = frontmatter.rstrip() + "\n" + new_line

    new_content = f"---\n{new_frontmatter}\n---\n{rest}"
    write_text(path, new_content)


def set_body_heading(path: Path, old_heading: str, new_heading: str) -> None:
    """
    Replace the first `# <old_heading>` H1 in the body with `# <new_heading>`.
    No-op if the file or heading isn't found.
    """
    if not path.is_file():
        return

    content = read_text(path)
    pattern = re.compile(rf"^# {re.escape(old_heading)}\s*$", re.MULTILINE)
    new_content, n = pattern.subn(f"# {new_heading}", content, count=1)
    if n > 0:
        write_text(path, new_content)


def set_status_list(path: Path, values: dict[str, str]) -> None:
    """
    Update a bullet-style "Key: value" list in the body of a markdown file.
    For each key in values, finds a line matching `- <key>:` (possibly with no
    value yet) and rewrites it as `- <key>: <new value>`.
    """
    if not path.is_file():
        return

    content = read_text(path)
    for key, value in values.items():
        pattern = re.compile(rf"^- {re.escape(key)}:\s*$", re.MULTILINE)
        content = pattern.sub(f"- {key}: {value}", content, count=1)

    write_text(path, content)


def add_project_reference_to_body(path: Path, project_title: str) -> None:
    """
    Insert a `Project: [[<project_title>]]` reference after the first H1 in the
    file body, but only if there isn't already a `Project:` line in the body.
    """
    if not path.is_file():
        return

    content = read_text(path)

    # If there's already a Project: reference in the body, skip
    if re.search(r"(?m)^Project:\s*", content):
        return

    # Insert after the first H1 heading
    pattern = re.compile(r"^(# .+?\n)", re.MULTILINE)
    new_content, n = pattern.subn(rf"\1\nProject: [[{project_title}]]\n", content, count=1)
    if n > 0:
        write_text(path, new_content)


# ---------------------------------------------------------------------------
# Misc utilities
# ---------------------------------------------------------------------------

def today_iso() -> str:
    """YYYY-MM-DD for today."""
    return datetime.now().strftime("%Y-%m-%d")


def is_git_available() -> bool:
    """Check whether `git` is on PATH."""
    return shutil.which("git") is not None
