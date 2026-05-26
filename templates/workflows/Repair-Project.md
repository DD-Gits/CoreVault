---
type: workflow
tags: [workflow, project, repair]
---

# Repair a project workflow

How to bring an existing project back into sync with the current project template when the template has evolved (new folders, new files, new conventions) without disturbing the project's existing content.

## When to use

- The template has gained new folders (e.g. `Plans/`, `Slices/`, `Specs/`, `References/`) since the project was created
- A new file has been added to the template (e.g. `AGENTS.md`)
- You're not sure if a project has everything it should — `-DryRun` will tell you
- You suspect a project lost some files and want to catch it up

## When NOT to use

- You want to overwrite or refresh existing files → Repair never modifies existing content. Edit them manually or copy from the template explicitly.
- You want to refresh helper skills (`.claude/skills/`, `.agents/skills/`) → those are personal, not synced from the library by Repair. Use the manual recipe in [[../../04 - Resources/AI/Skills/README|the skill library README]].
- The project's structure has intentionally diverged from the template and you want to keep it that way.

## TL;DR

```powershell
# Preview what would change (recommended first run)
.\System\Scripts\Repair-ObsidianProject.ps1 -ProjectName "My Project" -DryRun

# Apply the additions
.\System\Scripts\Repair-ObsidianProject.ps1 -ProjectName "My Project"

# By full path (works for projects under unusual locations)
.\System\Scripts\Repair-ObsidianProject.ps1 -ProjectPath "C:\path\to\project"
```

Run with no arguments for an interactive prompt.

## What it does

1. **Auto-detect** the vault from the script's location.
2. **Resolve** the project path (from `-ProjectPath`, or `-ProjectName` + optional `-ProjectType`, or an interactive prompt).
3. **Determine** project type (Work / Personal) from the path.
4. **Walk** the relevant template tree at `System\Templates\Projects\<Type>\`.
5. **Add** any folders and files that are missing in the project — mirroring the template's structure.
6. **Fill** the `project:` frontmatter field on newly-added files (the template ships these blank).
7. **Skip** anything that already exists — never modifies existing content.
8. **Print** a summary: added folders, added files, and skipped (existing) items.

## What it does NOT do

| Concern | Behaviour |
|---|---|
| Overwrite existing files | Never. Existing files are always skipped. |
| Modify existing file content | Never. Even frontmatter on existing files is left alone. |
| Refresh `.claude/skills/` or `.agents/skills/` | Never. Helper skills are personal, managed by `New-ObsidianProject.ps1 -Skills` at creation time or manually thereafter. |
| Update the project's `.gitignore` beyond adding it if missing | Never. If you customised the `.gitignore`, your customisations stay. |
| Handle Clone-mode repos specially | No. In a Clone-mode project, the cloned repo's root `.gitignore` is left alone (because it exists, and Repair skips existing). The `_meta/.gitignore` placement convention isn't replicated by Repair — handle Clone-mode gitignore layout manually. |

## Output

```
Repair Obsidian project
-----------------------

Project: C:\Users\you\Obsidian\Vault\02 - Projects\Work\My Project
Type:    Work
Template: C:\Users\you\Obsidian\Vault\System\Templates\Projects\Work
Mode:    DRY RUN (no changes will be written)


=== DRY RUN SUMMARY (nothing was written) ===

Added folders (4):
  + _meta\Plans
  + _meta\Slices
  + _meta\Specs
  + _meta\References

Added files (8):
  + AGENTS.md
  + _meta\Plans\0000-template.md
  + _meta\Plans\README.md
  + _meta\Slices\0000-template.md
  + _meta\Slices\README.md
  + _meta\Specs\0000-template.md
  + _meta\Specs\README.md
  + _meta\References\README.md

Skipped (already present, 21 files):
  = _meta\AI-Memory.md
  = _meta\CLAUDE.md
  ... and 19 more

Re-run without -DryRun to apply.
```

## Parameters

| Parameter | Description |
|---|---|
| `-VaultPath <path>` | Override vault auto-detection. Defaults to two parents up from script location. |
| `-ProjectPath <path>` | Full path to the project folder. Overrides `-ProjectName`. |
| `-ProjectName <name>` | Project folder name. Used with `-ProjectType`. If `-ProjectType` is omitted, the script searches both Work and Personal — errors if found in both. |
| `-ProjectType Work | Personal` | Project category. Used with `-ProjectName`, or inferred from `-ProjectPath`. |
| `-DryRun` | Preview changes without writing any files. Recommended first run. |

## Safe to re-run

Repair is idempotent. Running it twice in a row on the same project: first run adds missing items, second run reports "Nothing to repair — project is already in sync with the template."

## Related

- [[New-Project|New project workflow]] — create a new project from scratch
- [[Archive-Project|Archive project workflow]] — close out a finished project
- Project templates: `System\Templates\Projects\Work\` and `System\Templates\Projects\Personal\`
