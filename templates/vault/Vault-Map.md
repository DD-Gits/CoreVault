# Vault Map

Terse structural reference. For the comprehensive guide, see [[Vault-Guide]].

## 00 - Inbox

Temporary holding area for quick notes, rough ideas, and items that need processing.

## 01 - Calendar

Time-based notes.

- `Daily/` — daily working notes (uses `Daily Note` template).
- `Weekly/` — weekly planning and review.
- `Monthly/` — monthly planning and review.
- `Reviews/` — broader retrospectives.

## 02 - Projects

Active projects with outcomes, deliverables, or deadlines. Each project is laid out as a (potential) git repo:

```
<Project>/                  ← git repo root (may be empty for notes-only projects)
  .gitignore
  AGENTS.md                  ← auto-discovery for Codex / AGENTS.md-aware agents
  README.md                  ← repo-facing stub (Init mode) or from cloned repo
  _meta/                     ← Obsidian-managed notes
    README.md, CLAUDE.md, AI-Memory.md, PRD.md, Scope.md, Tasks.md, Handover.md
    Decisions/, Risks-Issues/, Plans/, Slices/, Specs/, References/
    AI-Sessions/, Meetings/, Assets/, Development/ (Work only)
```

Folders:

- `Work/` — work projects.
- `Personal/` — personal projects.

Project templates live under `System/Templates/Projects/`. Create new projects with `System/Scripts/New-ObsidianProject.ps1`.

## 03 - Areas

Ongoing responsibilities with no fixed end date.

Examples: ServiceNow, LogicMonitor, Azure, AI Agents, Health, Finance, Home.

## 04 - Resources

Reusable reference material, technical documentation, examples, research, patterns, and AI prompts.

- `Technical/` — language- and platform-specific reference (ServiceNow, PowerShell, JavaScript, Azure, Architecture).
- `AI/` — Claude/Codex reference, **prompt library**, **skill library**, and **preset library**:
  - `AI/Prompts/Project-Bootstrap.md` — one-time per project: scaffold CLAUDE.md + author PRD.
  - `AI/Prompts/Project-Session-Kickoff.md` — every working session: kickoff / resume / wrap-up.
  - `AI/Skills/<skill>/SKILL.md` — slash-command helpers (`/kickoff`, `/wrap-up`, `/new-session-log`). Imported into projects via `New-ObsidianProject.ps1 -Skills`.
  - `AI/Presets/<stack>.md` — stack-specific rule fragments (e.g. ServiceNow ES5 conventions). Referenced from per-project `_meta/CLAUDE.md` via `@` syntax.
- `Reference/` — general reference material.

## 05 - Tasks

Cross-project task views.

Useful files: `Work-Tasks.md`, `Personal-Tasks.md`, `Waiting-For.md`, `Backlog.md`.

## 06 - Meetings

Meeting notes that are *not* tied to a single project.

Project-specific meetings live inside the project: `02 - Projects/<Work or Personal>/<Project>/_meta/Meetings/`.

## 07 - Messaging

Drafts, stakeholder updates, email templates, Slack/Teams messages, and reusable communication snippets.

## 08 - Development

Cross-project scripts, snippets, experiments, development notes, and repo-adjacent working material. **Project-specific** code lives at the project's repo root, not here.

## 09 - Archive

Completed, inactive, or historical material. See [[System/Workflows/Archive-Project|Archive workflow]] for the process.

## System

Vault mechanics.

- `Templates/Notes/` — note templates (Daily, Weekly, Monthly, Meeting, AI Session, Message Draft, Dev Log).
- `Templates/Projects/Work/`, `Templates/Projects/Personal/` — project template trees (`_meta/` + `.gitignore`).
- `Dashboards/` — Dataview-driven home and project dashboards.
- `Scripts/` — `Create-ObsidianAiVault.ps1` (scaffold), `New-ObsidianProject.ps1` (new project), `Repair-ObsidianProject.ps1` (catch a project up to current template).
- `Workflows/` — process docs: `New-Project.md`, `Repair-Project.md`, `Archive-Project.md`.
- `Attachments/`, `Excalidraw/` — vault-wide attachments and diagrams.

## Vault-root files

- [[CLAUDE]] — canonical AI agent contract: conventions, project workflow, session modes.
- [[CODEX]] — code-focused agent preferences: language style, commit hygiene.
- [[Vault-Guide]] — comprehensive onboarding doc.
- [[Vault-Map]] — this file.
