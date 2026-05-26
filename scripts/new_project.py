#!/usr/bin/env python3
"""
new_project.py — Create a new Obsidian project from templates.

Cross-platform Python port of New-ObsidianProject.ps1.

Reads templates from <vault>/System/Templates/Projects/<Type>/ and writes a
new project into <vault>/02 - Projects/<Type>/<ProjectName>/.

Usage:
    python new_project.py [--vault PATH] [--name NAME] [--type Work|Personal]
                          [--repo-mode None|Init|Clone] [--repo-url URL]
                          [--owner OWNER] [--area AREA] [--status STATUS]
                          [--target-date YYYY-MM-DD] [--skills SPEC]
                          [--open-in-explorer]

If a required argument is omitted, the script prompts interactively.

Vault path resolution order:
    1. --vault argument (used as default in the prompt; you can still edit)
    2. Auto-detected from this script's location (script lives at
       <vault>/System/Scripts/new_project.py)
    3. No default — you must type an explicit path. There is no silent
       fallback to a guessed location.
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
from pathlib import Path

# Allow running both as a script and as part of the install package
sys.path.insert(0, str(Path(__file__).resolve().parent))
from vault_helpers import (
    cprint, header, hint, warn, ok, err,
    prompt_required, prompt_optional, prompt_choice,
    safe_name, find_vault_from_script,
    set_frontmatter_field, set_body_heading, set_status_list,
    add_project_reference_to_body,
    today_iso, is_git_available,
)


DEFAULT_SKILLS = ["kickoff", "wrap-up", "new-session-log", "handoff"]


# ---------------------------------------------------------------------------
# Skills resolution
# ---------------------------------------------------------------------------

def get_available_skills(skills_library: Path) -> list[str]:
    """Return sorted list of skill names found in the skills library."""
    if not skills_library.is_dir():
        return []
    skills = []
    for entry in skills_library.iterdir():
        if entry.is_dir() and (entry / "SKILL.md").is_file():
            skills.append(entry.name)
    return sorted(skills)


def prompt_skills_selection(current: str | None) -> str:
    """Prompt for the skills selection spec, returning the raw string."""
    if current is not None and current.strip():
        return current.strip()

    print()
    print("Skills to import (helper skills like /kickoff, /wrap-up, /new-session-log):")
    print("  None     - import nothing")
    print("  Default  - curated set: kickoff, wrap-up, new-session-log (recommended)")
    print("  All      - every skill in the library")
    print("  Custom   - interactive picker")

    value = input("Skills [Default]: ").strip()
    return value if value else "Default"


def resolve_skills(selection: str, available: list[str]) -> list[str]:
    """Resolve a skill selection spec to a concrete list of skill names."""
    selection = selection.strip()

    if selection.lower() == "none":
        return []
    if selection.lower() == "default":
        return [s for s in DEFAULT_SKILLS if s in available]
    if selection.lower() == "all":
        return available

    if selection.lower() == "custom":
        if not available:
            warn("Skills library is empty.")
            return []
        print()
        print("Available skills (answer y/N for each):")
        picked = []
        for skill in available:
            marker = " (in default set)" if skill in DEFAULT_SKILLS else ""
            response = input(f"  {skill}{marker} [y/N]: ").strip().lower()
            if response == "y":
                picked.append(skill)
        return picked

    # Comma-separated explicit list
    names = [n.strip() for n in selection.split(",") if n.strip()]
    missing = [n for n in names if n not in available]
    if missing:
        raise ValueError(
            f"Unknown skill(s): {', '.join(missing)}. "
            f"Available: {', '.join(available)}"
        )
    return names


def import_project_skills(project_path: Path, skills_library: Path,
                          skill_names: list[str], repo_mode: str) -> None:
    """Copy chosen skills into the project's .claude/skills/ and .agents/skills/."""
    if not skill_names:
        hint("No skills imported.")
        return

    import shutil

    claude_path = project_path / ".claude" / "skills"
    agents_path = project_path / ".agents" / "skills"
    claude_path.mkdir(parents=True, exist_ok=True)
    agents_path.mkdir(parents=True, exist_ok=True)

    for name in skill_names:
        src = skills_library / name
        if not src.is_dir():
            warn(f"Skill '{name}' not found at {src}, skipping.")
            continue
        for dst_base in (claude_path, agents_path):
            dst = dst_base / name
            if dst.exists():
                shutil.rmtree(dst)
            shutil.copytree(src, dst)

    cprint(f"Imported {len(skill_names)} skill(s): {', '.join(skill_names)}", color="cyan")
    print(f"  -> {claude_path}")
    print(f"  -> {agents_path}")

    # Clone mode: don't disturb the upstream .gitignore; add skill paths to
    # .git/info/exclude so they don't appear in `git status`.
    if repo_mode == "Clone":
        exclude_file = project_path / ".git" / "info" / "exclude"
        if exclude_file.is_file():
            existing = exclude_file.read_text(encoding="utf-8", errors="ignore")
            lines_to_add = []
            if not any(line.strip() == ".claude/skills/" for line in existing.splitlines()):
                lines_to_add.append(".claude/skills/")
            if not any(line.strip() == ".agents/skills/" for line in existing.splitlines()):
                lines_to_add.append(".agents/skills/")
            if lines_to_add:
                with exclude_file.open("a", encoding="utf-8") as f:
                    f.write("\n# Added by new_project.py - helper skills are personal, not committed\n")
                    for line in lines_to_add:
                        f.write(line + "\n")
                cprint("Updated .git/info/exclude with skill paths (local-only, not committed).",
                       color="cyan")


# ---------------------------------------------------------------------------
# Main flow
# ---------------------------------------------------------------------------

def main() -> int:
    parser = argparse.ArgumentParser(
        description="Create a new Obsidian project from templates.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument("--vault", default=None, help="Path to the Obsidian vault")
    parser.add_argument("--name", default=None, help="Project name")
    parser.add_argument("--type", dest="ptype", default=None, choices=[None, "Work", "Personal"],
                        help="Project type")
    parser.add_argument("--repo-mode", default=None, choices=[None, "None", "Init", "Clone"],
                        help="Git repo behaviour")
    parser.add_argument("--repo-url", default=None, help="Git repo URL (for Clone mode)")
    parser.add_argument("--owner", default=None, help="Project owner")
    parser.add_argument("--area", default=None, help="Project area")
    parser.add_argument("--status", default=None, help="Initial status")
    parser.add_argument("--target-date", default=None, help="Target date (YYYY-MM-DD); pass empty string to leave blank")
    parser.add_argument("--skills", default=None, help="Skills selection (None/Default/All/Custom/comma-list)")
    parser.add_argument("--open-in-explorer", action="store_true",
                        help="Open the created project in the OS file manager")
    parser.add_argument("--no-prompt", action="store_true",
                        help="Don't prompt for missing values; use defaults instead")
    args = parser.parse_args()

    # -----------------------------------------------------------------
    # Resolve vault path
    # -----------------------------------------------------------------

    vault_arg = (args.vault or "").strip()
    vault_default = vault_arg
    default_source = ""

    if not vault_default:
        # Try auto-detect from this script's location
        detected = find_vault_from_script(Path(__file__))
        if detected:
            vault_default = str(detected)
            default_source = "auto-detected from script location"

    header("Create new Obsidian project")

    if vault_arg:
        # User passed --vault explicitly
        vault_path_str = prompt_optional("Vault path", current=None,
                                         default=vault_arg)
    elif vault_default:
        # Auto-detect succeeded
        print()
        hint(f"Vault path default: {vault_default}")
        hint(f"  ({default_source})")
        vault_path_str = prompt_optional(
            "Vault path (press Enter to accept default, or type a different path)",
            current=None, default=vault_default,
        )
    else:
        # No default available — require explicit input
        print()
        warn("Script is not running from inside a vault and no --vault was supplied.")
        warn("You must provide an explicit vault path.")
        vault_path_str = prompt_required("Vault path (full path to the existing vault folder)")

    vault_path = Path(vault_path_str).expanduser().resolve()

    # -----------------------------------------------------------------
    # Other prompts
    # -----------------------------------------------------------------

    project_name = prompt_required("Project name", current=args.name)
    project_type = prompt_choice("Project type", ["Work", "Personal"],
                                 current=args.ptype, default="Work")
    repo_mode = prompt_choice("Repo mode", ["None", "Init", "Clone"],
                              current=args.repo_mode, default="None")

    repo_url = ""
    if repo_mode == "Clone":
        repo_url = prompt_required("Git repo URL to clone", current=args.repo_url)

    owner = prompt_optional("Owner", current=args.owner,
                            default=os.environ.get("USER") or os.environ.get("USERNAME") or "")
    area = prompt_optional("Area", current=args.area, default=project_type)
    status = prompt_optional("Status", current=args.status, default="Planning")
    target_date = prompt_optional(
        "Target date (optional, YYYY-MM-DD format, e.g. 2026-06-30; press Enter to leave blank)",
        current=args.target_date, default="",
    )
    skills_spec = prompt_skills_selection(args.skills)

    # -----------------------------------------------------------------
    # Resolve paths and validate
    # -----------------------------------------------------------------

    safe_project_name = safe_name(project_name)
    template_path = vault_path / "System" / "Templates" / "Projects" / project_type
    skills_library = vault_path / "04 - Resources" / "AI" / "Skills"
    project_path = vault_path / "02 - Projects" / project_type / safe_project_name
    meta_path = project_path / "_meta"
    today = today_iso()

    available_skills = get_available_skills(skills_library)

    try:
        skills_to_import = resolve_skills(skills_spec, available_skills)
    except ValueError as e:
        err(str(e))
        return 1

    if not vault_path.is_dir():
        err(f"Vault path not found: {vault_path}")
        return 1
    if not template_path.is_dir():
        err(f"Project template not found: {template_path}")
        err("Run create_vault.py first to set up the vault.")
        return 1
    if project_path.exists():
        err(f"Project already exists: {project_path}")
        return 1
    if repo_mode in ("Init", "Clone") and not is_git_available():
        err("git was not found on PATH. Install git or use --repo-mode None.")
        return 1

    # -----------------------------------------------------------------
    # Create project from template (per repo mode)
    # -----------------------------------------------------------------

    import shutil

    agents_md_from_upstream = False

    if repo_mode == "Clone":
        cprint(f"Cloning {repo_url} into {project_path} ...", color="cyan")
        result = subprocess.run(["git", "clone", repo_url, str(project_path)])
        if result.returncode != 0:
            err(f"git clone failed (exit {result.returncode}).")
            return 1

        # Overlay _meta/ from template
        template_meta = template_path / "_meta"
        if template_meta.is_dir():
            for src_file in template_meta.rglob("*"):
                if src_file.is_dir():
                    continue
                rel = src_file.relative_to(template_meta)
                dst = meta_path / rel
                dst.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(src_file, dst)

        # Copy root-level template files. .gitignore goes to _meta/ to avoid
        # disturbing upstream. Other root files only copy if missing upstream.
        for src_file in template_path.iterdir():
            if not src_file.is_file():
                continue
            if src_file.name == ".gitignore":
                shutil.copy2(src_file, meta_path / ".gitignore")
                warn(f"Placed project .gitignore at _meta/.gitignore "
                     f"(cloned repo's root .gitignore preserved).")
            else:
                dst = project_path / src_file.name
                if dst.exists():
                    hint(f"Skipped existing root file: {src_file.name} "
                         f"(cloned repo already has one).")
                    if src_file.name == "AGENTS.md":
                        agents_md_from_upstream = True
                else:
                    shutil.copy2(src_file, dst)
                    cprint(f"Copied template root file to project root: {src_file.name}",
                           color="cyan")
    else:
        # None or Init — copy the full template tree
        shutil.copytree(template_path, project_path)

    # -----------------------------------------------------------------
    # Customise _meta/README.md
    # -----------------------------------------------------------------

    readme_path = meta_path / "README.md"
    set_body_heading(readme_path, "Project Name", safe_project_name)
    set_frontmatter_field(readme_path, "status", status)
    set_frontmatter_field(readme_path, "area", area)
    set_frontmatter_field(readme_path, "owner", owner)
    set_frontmatter_field(readme_path, "start_date", today)
    if target_date:
        set_frontmatter_field(readme_path, "target_date", target_date)

    set_status_list(readme_path, {
        "Status":      status,
        "Owner":       owner,
        "Start date":  today,
        "Target date": target_date,
        "Area":        area,
    })

    # -----------------------------------------------------------------
    # Fill `project:` frontmatter and body Project: references across _meta/
    # -----------------------------------------------------------------

    frontmatter_files = [
        "CLAUDE.md",
        "AI-Memory.md",
        "Decisions/README.md",
        "Decisions/0000-template.md",
        "Risks-Issues/README.md",
        "Risks-Issues/0000-template.md",
        "Plans/README.md",
        "Plans/0000-template.md",
        "Slices/README.md",
        "Slices/0000-template.md",
        "Specs/README.md",
        "Specs/0000-template.md",
        "References/README.md",
    ]
    for rel in frontmatter_files:
        set_frontmatter_field(meta_path / rel, "project", safe_project_name)

    # AGENTS.md at the project root — but only if we placed it ourselves
    if agents_md_from_upstream:
        hint("Left upstream AGENTS.md frontmatter unchanged "
             "(clone mode, file owned by upstream repo).")
    else:
        set_frontmatter_field(project_path / "AGENTS.md", "project", safe_project_name)

    body_only_files = [
        "PRD.md",
        "Scope.md",
        "Tasks.md",
        "Handover.md",
        "Development/Notes.md",
        "Development/Test-Cases.md",
        "AI-Sessions/_AI-Session-Index.md",
    ]
    for rel in body_only_files:
        add_project_reference_to_body(meta_path / rel, safe_project_name)

    # -----------------------------------------------------------------
    # Import skills
    # -----------------------------------------------------------------

    import_project_skills(project_path, skills_library, skills_to_import, repo_mode)

    # -----------------------------------------------------------------
    # Repo-mode specific finishing steps
    # -----------------------------------------------------------------

    if repo_mode == "Init":
        root_readme = project_path / "README.md"
        if not root_readme.exists():
            root_readme.write_text(
                f"# {safe_project_name}\n\n"
                f"> Short description of what this project does.\n\n"
                f"---\n\n"
                f"This is the repository root. Working notes, decisions, AI context, and "
                f"project metadata live in [`_meta/`](./_meta/).\n",
                encoding="utf-8",
            )
            print("Stubbed root README.md.")

        cprint(f"Running git init in {project_path} ...", color="cyan")
        result = subprocess.run(["git", "init"], cwd=str(project_path),
                                capture_output=True)
        if result.returncode != 0:
            warn(f"git init returned exit {result.returncode}.")

    elif repo_mode == "Clone":
        cprint(f"Cloned repo left at {project_path}. _meta/ overlay applied; "
               f"cloned repo's tracked files untouched.", color="cyan")

    # -----------------------------------------------------------------
    # Completion message
    # -----------------------------------------------------------------

    print()
    ok(f"Created {project_type} project ({repo_mode} mode):")
    print(f"  {project_path}")
    print()
    print("Next steps:")
    print("  1. (One-time) Open '04 - Resources/AI/Prompts/Project-Bootstrap.md' and use")
    print("     'Scaffold _meta/CLAUDE.md' (interview-style) to populate CLAUDE.md.")
    print("  2. (One-time) From the same Bootstrap file, use one of the 'Author PRD' prompts.")
    if skills_to_import:
        print("  3. Start real work sessions with the imported skills:")
        for s in skills_to_import:
            print(f"       /{s}")
        print("     (Skills are also paste-able as prompts from '04 - Resources/AI/Prompts/Project-Session-Kickoff.md'.)")
    else:
        print("  3. When you start a real work session, use the prompts in")
        print("     '04 - Resources/AI/Prompts/Project-Session-Kickoff.md'.")
    if repo_mode == "Init":
        print("  4. git add / commit at the project root when you're ready.")
        print("     (Note: .claude/skills/ and .agents/skills/ are gitignored by default.)")
    if repo_mode == "Clone":
        print("  4. Review the repo and _meta/.gitignore; merge with the repo's root .gitignore")
        print("     if you want _meta entries committed. Skills are already excluded via")
        print("     .git/info/exclude (local-only, no commit needed).")
    print()

    # -----------------------------------------------------------------
    # Optionally open in the OS file manager
    # -----------------------------------------------------------------

    if args.open_in_explorer:
        try:
            if sys.platform == "win32":
                os.startfile(str(project_path))  # noqa
            elif sys.platform == "darwin":
                subprocess.run(["open", str(project_path)])
            else:
                subprocess.run(["xdg-open", str(project_path)])
        except Exception as e:
            warn(f"Could not open file manager: {e}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
