# Obsidian AI Vault — Install Package

A cross-platform install package that bootstraps an Obsidian vault structured for AI-assisted development work, with persistent project context, durable AI memory, and a kickoff/wrap-up session protocol that works across Claude Code, Codex, Cursor, and other AGENTS.md-aware agents.

This is the install package. The bootstrapper (`create_vault.py` or `Create-ObsidianAiVault.ps1`) builds a working vault somewhere on your machine. Once the vault exists you no longer need this package — the operational scripts (`new_project`, `repair_project`) get copied into the vault and run from there.

Once the vault exists, three guides sit at its root — read them in this order:

- `Obsidian-AI-User-Guide.md` — the day-to-day playbook (create projects, run sessions, slash commands). Start here.
- `Vault-Guide.md` — orientation. Folder structure, project layout, how context files relate.
- `Obsidian-AI-Workflow-Guide.md` — the rationale. Durable vs episodic memory, the evaluator loop, when to escalate from simple to complex.

You can take the workflow on faith from the User Guide and read the other two when you want the deeper picture.

---

## What's in this package

```
obsidian-ai-vault/
├── create_vault.py                   ← Linux/macOS/Windows bootstrapper
├── Create-ObsidianAiVault.ps1        ← Windows-native bootstrapper (PowerShell)
├── templates/                        ← All template content
│   ├── vault/                        Vault-root files (CLAUDE.md, etc.)
│   ├── notes/                        Note templates (Daily, Weekly, AI Session, etc.)
│   ├── projects/Work/                Work project _meta/ tree
│   ├── projects/Personal/            Personal project _meta/ tree
│   ├── skills/                       Helper skills (kickoff, wrap-up, new-session-log)
│   ├── prompts/                      Paste-able prompts for chat-only agents
│   ├── presets/                      Domain-specific context presets (e.g. ServiceNow)
│   ├── workflows/                    Internal workflow docs
│   └── extras/                       Seeded vault content (Tasks, Dashboards, etc.)
├── scripts/                          Operational scripts (copied into the vault)
│   ├── new_project.py                Python: create a project from templates
│   ├── repair_project.py             Python: add missing files to existing project
│   ├── vault_helpers.py              Shared Python utilities
│   ├── New-ObsidianProject.ps1       PowerShell equivalent
│   └── Repair-ObsidianProject.ps1    PowerShell equivalent
└── README.md                         This file
```

---

## Quick start

### Linux / macOS

```bash
# Requires Python 3.10 or newer. Check with: python3 --version
cd obsidian-ai-vault
./create_vault.py
```

Or with an explicit vault path:

```bash
./create_vault.py --vault ~/Documents/MyVault
```

### Windows

You have two equivalent options. Pick whichever is more comfortable.

**Option A — Python (cross-platform):**

```powershell
cd obsidian-ai-vault
python create_vault.py
```

**Option B — PowerShell (Windows-native):**

```powershell
cd obsidian-ai-vault
.\Create-ObsidianAiVault.ps1
```

Both build the same vault.

---

## What the bootstrapper does

1. Prompts for the vault path (default: `~/Obsidian/Vault`) and confirms before writing.
2. Creates the top-level folder structure (`00 - Inbox/` through `09 - Archive/`, plus `System/`).
3. Copies vault-root files (`CLAUDE.md`, `CODEX.md`, `Vault-Guide.md`, `Vault-Map.md`, `Session-Rituals.md`, `Obsidian-AI-User-Guide.md`, `Obsidian-AI-Workflow-Guide.md`).
4. Copies note templates to `System/Templates/Notes/`.
5. Copies project templates to `System/Templates/Projects/Work/` and `.../Personal/`.
6. Copies the skills library to `04 - Resources/AI/Skills/`.
7. Copies prompt templates to `04 - Resources/AI/Prompts/`.
8. Copies presets to `04 - Resources/AI/Presets/` (skipped if the package has no `templates/presets/`).
9. Copies workflow docs to `System/Workflows/`.
10. Copies seeded extras (Tasks files, Dashboards, Inbox stub, Area indexes).
11. Copies the OS-appropriate operational scripts to `System/Scripts/`.

By default the bootstrapper copies only the OS-native operational scripts (`.py` on Linux/macOS, both `.py` and `.ps1` on Windows). Pass `--all-scripts` to copy both regardless of OS — useful for vaults accessed from multiple operating systems (e.g. via a synced folder).

---

## After vault creation

The bootstrapper is no longer needed. The operational scripts live in your vault:

```bash
cd <vault>/System/Scripts
python3 new_project.py        # or python on Windows
./new_project.py              # if executable (Linux/macOS)
```

These scripts read templates from `<vault>/System/Templates/` (which the bootstrapper copied there), so edits to the vault's templates immediately affect future projects without needing to touch this install package.

---

## Common command-line options

The tables below document the Python script flags. The PowerShell equivalents accept the same options but in PascalCase form: `--vault PATH` → `-VaultPath PATH`, `--name NAME` → `-ProjectName NAME`, `--type Work` → `-ProjectType Work`, and so on. Boolean flags drop the `-` (`--force` → `-ForceOverwrite`, `--dry-run` → `-DryRun`, `--no-confirm` → `-NoConfirm`, `--all-scripts` → `-AllScripts`). Run `Get-Help .\<script>.ps1 -Full` from PowerShell for the authoritative list per script.

### `create_vault.py`

| Flag | Purpose |
|------|---------|
| `--vault PATH` | Set the vault path non-interactively |
| `--force` | Overwrite existing files where they already exist |
| `--no-confirm` | Skip the confirmation prompt (for unattended use) |
| `--all-scripts` | Copy both `.py` and `.ps1` operational scripts (default: OS-native only) |

### `new_project.py`

| Flag | Purpose |
|------|---------|
| `--vault PATH` | Set the vault path non-interactively |
| `--name NAME` | Project name |
| `--type Work\|Personal` | Project type |
| `--repo-mode None\|Init\|Clone` | Git repo behaviour |
| `--repo-url URL` | Git repo URL (required for Clone mode) |
| `--owner OWNER` | Project owner |
| `--area AREA` | Project area |
| `--status STATUS` | Initial status (default: Planning) |
| `--target-date YYYY-MM-DD` | Target date (optional) |
| `--skills SPEC` | `None`, `Default`, `All`, `Custom`, or a comma-separated list |
| `--open-in-explorer` | Open the created project in the OS file manager |

### `repair_project.py`

| Flag | Purpose |
|------|---------|
| `--vault PATH` | Set the vault path non-interactively |
| `--project PATH` | Path to the project to repair |
| `--dry-run` | Show what would be added without writing anything |

---

## Updating templates

Two places to make changes, depending on what you're trying to achieve:

**Change behaviour for future *new vaults*:**
Edit files in `<install-package>/templates/`. Re-running `create_vault.py` against a fresh location picks up the changes.

**Change behaviour for *existing projects in your current vault*:**
Edit files in `<vault>/System/Templates/`. Future projects created via `new_project.py` (or its PowerShell sibling) pick them up automatically. Existing projects keep their templates as they were created — use `repair_project.py` to add any *new* files that have been added to the template since the project was created (it never overwrites).

If you maintain both the install package and your vault, keeping them in sync is a manual step. The recommendation is to make changes in the install package's `templates/` first, then re-bootstrap or copy specific files into your vault.

---

## Requirements

- **Python 3.10 or newer** for the Python scripts. Available out-of-the-box on most modern Linux distributions and macOS; install from python.org or the Microsoft Store on Windows.
- **PowerShell 5.1+ on Windows** for the PowerShell scripts. Ships with Windows 10 and 11.
- **git** on PATH if you want to use Init or Clone repo modes. Optional otherwise.
- **No external Python dependencies.** The scripts use only the standard library.

---

## Platform notes

**Line endings**: All template files in this package use Unix LF line endings. Obsidian handles both LF and CRLF cleanly, so this works on Windows without adjustment.

**File permissions**: On Linux/macOS the Python scripts are marked executable (`chmod +x`). On Windows you'll always invoke them with `python` or `python3`.

**ANSI colours**: The Python scripts use ANSI escape codes for coloured terminal output. Modern Windows terminals (Windows Terminal, PowerShell 7+) handle these natively. Older `cmd.exe` may show the codes literally; the scripts still work, just less prettily.

---

## What this isn't

This package builds the vault scaffolding. It does not run your agents, manage your sessions, or do AI work for you. Those happen *inside* the vault, once it exists, via your normal AI tools (Claude Code, Codex, Cursor, claude.ai, etc.) reading the files this package creates.

For the conceptual workflow — what the vault is for, how the kickoff/wrap-up loop works, when to use simple vs complex project structure, how the evaluator pass operates — read the guides at the generated vault's root: `Obsidian-AI-User-Guide.md` for the day-to-day playbook, `Vault-Guide.md` for orientation, and `Obsidian-AI-Workflow-Guide.md` for the deeper rationale.
