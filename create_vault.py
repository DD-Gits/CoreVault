#!/usr/bin/env python3
"""
create_vault.py — Bootstrap a new Obsidian AI vault.

Cross-platform Python port of Create-ObsidianAiVault.ps1.

This script lives in the install-package root and reads templates from
./templates/. It writes a fresh vault to the user-specified path, copying:

  - Vault-root files (CLAUDE.md, CODEX.md, Vault-Guide.md, Vault-Map.md)
  - Top-level folder structure (00 - Inbox through 09 - Archive)
  - System/ structure (Templates/, Scripts/, Dashboards/, Workflows/)
  - Note templates (under System/Templates/Notes/)
  - Project templates (under System/Templates/Projects/Work/ and Personal/)
  - Skills library (04 - Resources/AI/Skills/)
  - Prompt library (04 - Resources/AI/Prompts/)
  - Workflow docs (System/Workflows/)
  - Seeded extras (Tasks lists, Inbox file, Dashboards, Area indexes)
  - The OS-appropriate operational scripts (new_project / repair_project)

Usage:
    python create_vault.py [--vault PATH] [--force] [--no-confirm]
                           [--all-scripts]

If --vault is omitted, the script prompts. If --no-confirm is passed, the
script proceeds without the confirmation prompt (useful for unattended use).

By default the script copies only the OS-appropriate operational scripts
(.py on Linux/macOS, .ps1 on Windows). Pass --all-scripts to copy both
(useful if the vault will be accessed from multiple operating systems).
"""

from __future__ import annotations

import argparse
import os
import shutil
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "scripts"))
from vault_helpers import (
    cprint, header, hint, warn, ok, err,
    prompt_required, prompt_optional, prompt_yes_no,
    find_install_package,
    read_text, write_text,
)


# ---------------------------------------------------------------------------
# Vault skeleton
# ---------------------------------------------------------------------------

VAULT_TOP_LEVEL_FOLDERS = [
    "00 - Inbox",
    "01 - Calendar/Daily",
    "01 - Calendar/Weekly",
    "01 - Calendar/Monthly",
    "01 - Calendar/Reviews",
    "02 - Projects/Work",
    "02 - Projects/Personal",
    "03 - Areas/Work",
    "03 - Areas/Personal",
    "04 - Resources/AI/Prompts",
    "04 - Resources/AI/Skills",
    "04 - Resources/Technical",
    "04 - Resources/Reference",
    "05 - Tasks",
    "06 - Meetings",
    "07 - Messaging",
    "08 - Development",
    "09 - Archive/Projects",
    "09 - Archive/Resources",
    "System/Templates/Notes",
    "System/Templates/Projects/Work",
    "System/Templates/Projects/Personal",
    "System/Dashboards",
    "System/Scripts",
    "System/Workflows",
    "System/Attachments",
]


def detect_install_package() -> Path:
    """Find the install package containing templates/ and scripts/."""
    pkg = find_install_package()
    if pkg is None:
        err("Could not find the install package (templates/ and scripts/ folders).")
        err("Make sure create_vault.py is being run from the install package root.")
        sys.exit(1)
    return pkg


def confirm_and_resolve_vault_path(args) -> Path:
    """Show resolved vault path, allow override, return final path."""
    if args.vault.strip():
        vault_path_str = args.vault.strip()
    else:
        # Default: ~/Obsidian/Vault (cross-platform)
        vault_path_str = str(Path.home() / "Obsidian" / "Vault")

    if args.no_confirm:
        return Path(vault_path_str).expanduser().resolve()

    header("Obsidian AI vault creation")
    print()
    print("About to create / update a vault at:")
    cprint(f"  {vault_path_str}", color="yellow")

    candidate = Path(vault_path_str).expanduser()
    if candidate.exists():
        if args.force:
            hint("  (path exists — existing files will be overwritten where --force applies)")
        else:
            hint("  (path exists — existing files will be left in place; pass --force to overwrite)")
    else:
        hint("  (path does not yet exist — it will be created)")

    print()
    response = input("Press Enter to continue, or type a different path (Ctrl+C to abort): ").strip()
    if response:
        vault_path_str = response

    print()
    cprint(f"Using vault path: {vault_path_str}", color="green")
    print()

    return Path(vault_path_str).expanduser().resolve()


def make_top_level_skeleton(vault_path: Path) -> None:
    """Create the numbered top-level folders and the System/ tree."""
    for folder in VAULT_TOP_LEVEL_FOLDERS:
        (vault_path / folder).mkdir(parents=True, exist_ok=True)


def copy_with_skip(src: Path, dst: Path, force: bool, label: str = "") -> tuple[int, int]:
    """
    Copy src → dst. Returns (copied_count, skipped_count).
    If force is False, existing files at dst are skipped.
    """
    copied = 0
    skipped = 0

    if src.is_file():
        if dst.exists() and not force:
            skipped += 1
        else:
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)
            copied += 1
        return copied, skipped

    if src.is_dir():
        for sub in src.rglob("*"):
            if sub.is_dir():
                continue
            rel = sub.relative_to(src)
            target = dst / rel
            if target.exists() and not force:
                skipped += 1
                continue
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(sub, target)
            copied += 1

    return copied, skipped


def copy_operational_scripts(pkg: Path, vault_path: Path, all_scripts: bool,
                             force: bool) -> None:
    """Copy new_project and repair_project scripts to vault/System/Scripts/."""
    scripts_dst = vault_path / "System" / "Scripts"
    scripts_dst.mkdir(parents=True, exist_ok=True)

    # Python scripts (always copy at least these — they're cross-platform)
    py_scripts = ["vault_helpers.py", "new_project.py", "repair_project.py"]
    # PowerShell scripts (copy on Windows or if --all-scripts)
    ps_scripts = ["New-ObsidianProject.ps1", "Repair-ObsidianProject.ps1"]

    include_py = True  # always — they work on any OS
    include_ps = all_scripts or sys.platform == "win32"

    copied = 0
    for name in py_scripts if include_py else []:
        src = pkg / "scripts" / name
        if src.is_file():
            dst = scripts_dst / name
            if dst.exists() and not force:
                continue
            shutil.copy2(src, dst)
            # Make Python scripts executable on Unix
            if sys.platform != "win32" and name != "vault_helpers.py":
                dst.chmod(0o755)
            copied += 1

    for name in ps_scripts if include_ps else []:
        src = pkg / "scripts" / name
        if src.is_file():
            dst = scripts_dst / name
            if dst.exists() and not force:
                continue
            shutil.copy2(src, dst)
            copied += 1

    cprint(f"Copied {copied} operational script(s) to System/Scripts/", color="cyan")


# ---------------------------------------------------------------------------
# Main flow
# ---------------------------------------------------------------------------

def main() -> int:
    parser = argparse.ArgumentParser(
        description="Bootstrap a new Obsidian AI vault.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument("--vault", default="", help="Path where the vault will be created")
    parser.add_argument("--force", action="store_true",
                        help="Overwrite existing files where they already exist")
    parser.add_argument("--no-confirm", action="store_true",
                        help="Skip the confirmation prompt (for unattended use)")
    parser.add_argument("--all-scripts", action="store_true",
                        help="Copy both .py and .ps1 operational scripts to the vault "
                             "(default: only the OS-native ones)")
    args = parser.parse_args()

    pkg = detect_install_package()
    vault_path = confirm_and_resolve_vault_path(args)

    if not vault_path.exists():
        vault_path.mkdir(parents=True)
    elif not vault_path.is_dir():
        err(f"Path exists but is not a directory: {vault_path}")
        return 1

    # -----------------------------------------------------------------
    # Build skeleton
    # -----------------------------------------------------------------

    header("Building vault skeleton")
    make_top_level_skeleton(vault_path)
    ok(f"Created {len(VAULT_TOP_LEVEL_FOLDERS)} top-level folders")

    # -----------------------------------------------------------------
    # Vault-root content files
    # -----------------------------------------------------------------

    header("Vault-root files")
    vault_root_src = pkg / "templates" / "vault"
    copied, skipped = copy_with_skip(vault_root_src, vault_path, args.force)
    ok(f"Vault-root files: {copied} copied, {skipped} skipped (already present)")

    # -----------------------------------------------------------------
    # Note templates (System/Templates/Notes/)
    # -----------------------------------------------------------------

    header("Note templates")
    notes_dst = vault_path / "System" / "Templates" / "Notes"
    copied, skipped = copy_with_skip(pkg / "templates" / "notes", notes_dst, args.force)
    ok(f"Note templates: {copied} copied, {skipped} skipped")

    # -----------------------------------------------------------------
    # Project templates (System/Templates/Projects/)
    # -----------------------------------------------------------------

    header("Project templates")
    projects_dst = vault_path / "System" / "Templates" / "Projects"
    copied, skipped = copy_with_skip(pkg / "templates" / "projects", projects_dst,
                                     args.force)
    ok(f"Project templates: {copied} copied, {skipped} skipped")

    # -----------------------------------------------------------------
    # Skills library (04 - Resources/AI/Skills/)
    # -----------------------------------------------------------------

    header("Skills library")
    skills_dst = vault_path / "04 - Resources" / "AI" / "Skills"
    copied, skipped = copy_with_skip(pkg / "templates" / "skills", skills_dst,
                                     args.force)
    ok(f"Skills: {copied} files copied, {skipped} skipped")

    # -----------------------------------------------------------------
    # Prompts (04 - Resources/AI/Prompts/)
    # -----------------------------------------------------------------

    header("Prompt library")
    prompts_dst = vault_path / "04 - Resources" / "AI" / "Prompts"
    copied, skipped = copy_with_skip(pkg / "templates" / "prompts", prompts_dst,
                                     args.force)
    ok(f"Prompts: {copied} copied, {skipped} skipped")

    # -----------------------------------------------------------------
    # Workflow docs (System/Workflows/)
    # -----------------------------------------------------------------

    header("Workflow docs")
    workflows_dst = vault_path / "System" / "Workflows"
    copied, skipped = copy_with_skip(pkg / "templates" / "workflows", workflows_dst,
                                     args.force)
    ok(f"Workflows: {copied} copied, {skipped} skipped")

    # -----------------------------------------------------------------
    # Seeded extras (Tasks, Inbox, Dashboards, Area indexes)
    # -----------------------------------------------------------------

    header("Seeded extras")
    extras_src = pkg / "templates" / "extras"
    if extras_src.is_dir():
        copied, skipped = copy_with_skip(extras_src, vault_path, args.force)
        ok(f"Extras: {copied} copied, {skipped} skipped")

    # -----------------------------------------------------------------
    # Operational scripts
    # -----------------------------------------------------------------

    header("Operational scripts")
    copy_operational_scripts(pkg, vault_path, args.all_scripts, args.force)

    # -----------------------------------------------------------------
    # Completion message
    # -----------------------------------------------------------------

    print()
    ok("Vault created.")
    print()
    print("Next steps:")
    print(f"  1. Open the vault in Obsidian: File → Open Vault → {vault_path}")
    print("  2. Read Vault-Guide.md for the workflow overview.")
    print("  3. Create your first project:")
    if sys.platform == "win32":
        print(f"       cd \"{vault_path}\\System\\Scripts\"")
        print("       python new_project.py")
        print("     or:")
        print("       .\\New-ObsidianProject.ps1")
    else:
        print(f"       cd \"{vault_path}/System/Scripts\"")
        print("       python3 new_project.py")
    print()

    return 0


if __name__ == "__main__":
    sys.exit(main())
