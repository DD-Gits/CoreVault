#!/usr/bin/env python3
"""
repair_project.py — Add missing template files to an existing Obsidian project.

Cross-platform Python port of Repair-ObsidianProject.ps1.

Use case: a project was created before a template was added (e.g. a new
_meta/ subfolder was introduced in a later vault version). Repair finds the
project's type by checking where its template lives, then copies any
missing files from the template into the project.

Important: Repair NEVER overwrites existing files. Existing project content
is sacred — Repair only adds what's missing.

Usage:
    python repair_project.py [--vault PATH] [--project PATH] [--dry-run]

If --project is omitted, the script prompts for it.
"""

from __future__ import annotations

import argparse
import shutil
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from vault_helpers import (
    cprint, header, hint, warn, ok, err,
    prompt_required,
    find_vault_from_script,
)


def detect_project_type(project_path: Path, vault_path: Path) -> str | None:
    """
    Determine whether a project is Work or Personal based on its location
    in the vault, OR fall back to checking the .gitignore content style.
    """
    try:
        rel = project_path.relative_to(vault_path / "02 - Projects")
        type_part = rel.parts[0]
        if type_part in ("Work", "Personal"):
            return type_part
    except ValueError:
        pass
    return None


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Add missing template files to an existing Obsidian project.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument("--vault", default="", help="Path to the Obsidian vault")
    parser.add_argument("--project", default="", help="Path to the project to repair")
    parser.add_argument("--dry-run", action="store_true",
                        help="Show what would be added without writing anything")
    args = parser.parse_args()

    header("Repair Obsidian project")

    # -----------------------------------------------------------------
    # Resolve project path (required input)
    # -----------------------------------------------------------------

    project_path_str = prompt_required(
        "Project path (full path to the existing project folder)",
        current=args.project,
    )
    project_path = Path(project_path_str).expanduser().resolve()

    if not project_path.is_dir():
        err(f"Project path not found: {project_path}")
        return 1

    # -----------------------------------------------------------------
    # Resolve vault path
    # -----------------------------------------------------------------

    vault_path_str = args.vault.strip()
    if not vault_path_str:
        detected = find_vault_from_script(Path(__file__))
        if detected:
            vault_path_str = str(detected)
        else:
            # Try to derive from the project path: project is
            # <vault>/02 - Projects/<Type>/<Name>/
            try:
                candidate = project_path.parent.parent.parent
                if (candidate / "CLAUDE.md").is_file():
                    vault_path_str = str(candidate)
            except Exception:
                pass

    if not vault_path_str:
        warn("Vault path could not be auto-detected and was not provided.")
        vault_path_str = prompt_required("Vault path (full path to the existing vault folder)")

    vault_path = Path(vault_path_str).expanduser().resolve()

    if not vault_path.is_dir():
        err(f"Vault path not found: {vault_path}")
        return 1

    # -----------------------------------------------------------------
    # Detect project type
    # -----------------------------------------------------------------

    project_type = detect_project_type(project_path, vault_path)
    if not project_type:
        err(f"Could not determine whether {project_path} is a Work or Personal project.")
        err("Move it under <vault>/02 - Projects/Work/ or .../Personal/ first.")
        return 1

    template_path = vault_path / "System" / "Templates" / "Projects" / project_type
    if not template_path.is_dir():
        err(f"Project template not found: {template_path}")
        return 1

    # -----------------------------------------------------------------
    # Display plan
    # -----------------------------------------------------------------

    print()
    print(f"Project:  {project_path}")
    print(f"Type:     {project_type}")
    print(f"Template: {template_path}")
    print(f"Mode:     {'DRY RUN (no changes will be written)' if args.dry_run else 'WRITE'}")
    print()

    # -----------------------------------------------------------------
    # Walk the template and detect missing files / folders
    # -----------------------------------------------------------------

    added_folders: list[Path] = []
    added_files: list[Path] = []
    skipped: list[Path] = []

    # Find all template files
    template_files = [p for p in template_path.rglob("*") if p.is_file()]

    for template_file in template_files:
        rel = template_file.relative_to(template_path)
        target = project_path / rel

        if target.exists():
            skipped.append(rel)
            continue

        # Track the immediate parent folders that don't yet exist
        for parent in reversed(target.parents):
            if parent == project_path:
                break
            if not parent.exists() and parent not in added_folders:
                added_folders.append(parent)

        added_files.append(rel)

        if not args.dry_run:
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(template_file, target)

    # -----------------------------------------------------------------
    # Summary output
    # -----------------------------------------------------------------

    summary_line = "=== DRY RUN SUMMARY (nothing was written) ===" if args.dry_run \
                   else "=== REPAIR SUMMARY ==="
    print(summary_line)
    print()

    if added_folders:
        print(f"Added folders ({len(added_folders)}):")
        for folder in added_folders:
            print(f"  + {folder.relative_to(project_path)}")
        print()

    if added_files:
        print(f"Added files ({len(added_files)}):")
        for rel in added_files:
            print(f"  + {rel}")
        print()

    if skipped:
        print(f"Skipped (already present, {len(skipped)} files):")
        for rel in skipped[:5]:
            print(f"  = {rel}")
        if len(skipped) > 5:
            print(f"  ... and {len(skipped) - 5} more")
        print()

    if not added_files and not added_folders:
        ok("Project is up to date with the template. Nothing to repair.")
    elif args.dry_run:
        hint("Re-run without --dry-run to apply.")
    else:
        ok(f"Repair complete. Added {len(added_files)} file(s) and {len(added_folders)} folder(s).")

    return 0


if __name__ == "__main__":
    sys.exit(main())
