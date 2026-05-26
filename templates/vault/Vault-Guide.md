---
type: guide
tags: [guide, vault, onboarding]
---

# Vault Guide

Orientation for this vault. Covers folder structure, how each project is laid out for git, how Claude / Codex / ChatGPT use the vault, and the role of each `.md` context file from vault-root down to per-project.

For a terse structural reference, see [[Vault-Map]]. For the canonical AI-agent contract, see [[CLAUDE]]. This file connects the two and explains *why* things are arranged the way they are.

## Contents

1. [What this vault is for](#what-this-vault-is-for)
2. [Vault layout](#vault-layout)
3. [Project layout](#project-layout)
4. [How it works with git](#how-it-works-with-git)
5. [How it works with Claude](#how-it-works-with-claude)
6. [How it works with Codex](#how-it-works-with-codex)
7. [The context files explained](#the-context-files-explained)
8. [Templates and plugins](#templates-and-plugins)
9. [Where each kind of thing lives](#where-each-kind-of-thing-lives)
10. [Related workflows](#related-workflows)

## What this vault is for

Work notes, personal notes, projects, development work, meetings, tasks, and — most importantly — durable AI-assisted workflows. The structure is designed so that Claude, Codex, and ChatGPT sessions leave behind *useful artefacts* (decisions, corrections, session summaries) rather than disposable transcripts.

The two core ideas:

- **Per-project context** that AI agents read at the start of every session, so you stop re-explaining the same project five times.
- **Per-project git repos** so code, notes, decisions, and AI history live together and can be cloned, shared, or archived as a unit.

## Vault layout

Top-level folders follow a PARA-style convention:

| Folder | What goes here |
|---|---|
| `00 - Inbox/` | Temporary captures, unprocessed notes |
| `01 - Calendar/` | Daily, weekly, monthly, retrospective notes |
| `02 - Projects/` | Active projects (Work / Personal) — each its own git-ready folder |
| `03 - Areas/` | Ongoing responsibilities with no fixed end date (ServiceNow, LogicMonitor, Health, Finance, …) |
| `04 - Resources/` | Reusable reference material, technical docs, AI prompt library |
| `05 - Tasks/` | Cross-project task views (Work-Tasks, Personal-Tasks, Waiting-For, Backlog) |
| `06 - Meetings/` | Meeting notes not tied to a single project |
| `07 - Messaging/` | Email drafts, stakeholder updates, message templates |
| `08 - Development/` | Cross-project scripts, snippets, experiments — project-specific code lives in the project folder |
| `09 - Archive/` | Inactive or completed material |
| `System/` | Vault mechanics: templates, dashboards, scripts, workflow docs |

Vault-root `.md` files:

- `CLAUDE.md` — global instructions for Claude (and other agents that read it)
- `CODEX.md` — global instructions for Codex (and other coding agents)
- `Vault-Map.md` — terse structure reference
- `Vault-Guide.md` — this file

## Project layout

Each project under `02 - Projects/Work/<Project>/` or `02 - Projects/Personal/<Project>/` is structured to be both an Obsidian project node and a (potential) git repo:

```
<Project>/                         ← git repo root
  .gitignore                       ← (or _meta/.gitignore in Clone mode)
  AGENTS.md                        ← auto-discovery pointer for Codex / AGENTS.md-aware agents
  README.md                        ← repo-facing, only in Init mode (or from cloned repo)
  <code, configs, src/, etc.>      ← anything the repo itself owns
  _meta/                           ← Obsidian-managed notes
    README.md                      ← project home note (status, links, focus)
    CLAUDE.md                      ← load-bearing AI context: stack, glossary, never-dos
    AI-Memory.md                   ← AI corrections, validated approaches, domain quirks
    PRD.md                         ← what we're building (business-level)
    Scope.md
    Tasks.md
    Handover.md
    Decisions/                     ← ADR folder (one file per decision, immutable)
      README.md, 0000-template.md
    Risks-Issues/                  ← one file per risk or issue
      README.md, 0000-template.md
    Plans/                         ← implementation plans (how we'll build it, phases/slices)
      README.md, 0000-template.md
    Slices/                        ← vertical slices of work + per-env deployment tracking
      README.md, 0000-template.md
    Specs/                         ← technical specs (architecture, data, APIs)
      README.md, 0000-template.md
    References/                    ← mockups, screenshots, examples, related-system docs
      README.md
    AI-Sessions/                   ← session summaries (gitignored by default)
    Meetings/                      ← project meeting notes (gitignored by default)
    Assets/                        ← inline note attachments (binaries gitignored)
    Development/                   ← Work only: dev notes, test cases, scripts, prompts
```

### How the implementation files relate

```
PRD (what) ──────► Scope (boundaries)
   │
   ├─► Decisions (why)  ◄────────┐
   │      ▲                       │ (constrains)
   │      │ (informs)              │
   ▼      │                       │
Specs (how it works) ─────────────┘
   │
   │ (implements)
   ▼
Plans (how we'll build it)
   │
   │ (decomposes into)
   ▼
Slices (units of implementation, with deploy tracking)
   │
   │ (unpacks to)
   ▼
Tasks (short-horizon to-do list)
```

Not every project needs every layer. Notes-only projects might use only PRD + Tasks. A complex code rollout will use all of them. The folders sit empty until you populate them — empty folders cost nothing and the consistent shape helps AI agents know where to look.

**The key separation:** project root is for repo content (audience: developers, repo users), `_meta/` is for Obsidian-managed working notes (audience: you, AI agents). For notes-only projects with no code, the root is mostly empty and only `_meta/` is used.

This split means:

- A code project's `README.md` (at root) and `_meta/README.md` (in Obsidian) can both exist without collision — they serve different audiences.
- Sensitive notes (AI session transcripts, meeting minutes) are gitignored by default and never accidentally pushed to a public repo.
- The same template works for every project type (notes-only, new-code, cloned-repo).

New projects should be created via `System/Scripts/New-ObsidianProject.ps1`. See [[System/Workflows/New-Project|New Project workflow]].

## How it works with git

Each project folder *is* a git repo (or can be — projects without code can skip git entirely).

### Three modes, picked at project creation

| Mode | What happens | When to use |
|---|---|---|
| `None` | Template copied as-is. No git is run. `.gitignore` is left at the root for later. | Pure notes / planning, no code |
| `Init` | Template copied, root `README.md` stubbed, `git init` run at project root | Starting a new code project from scratch |
| `Clone` | `git clone <url>` first, `_meta/` overlaid on top of the cloned repo, `.gitignore` placed at `_meta/.gitignore` so the cloned repo's root `.gitignore` is preserved | Tracking an external repo in Obsidian |

The `-RepoMode` parameter on `New-ObsidianProject.ps1` picks the mode.

### `.gitignore` defaults

The template `.gitignore` excludes:

- `_meta/AI-Sessions/` — session transcripts may contain secrets pasted in by you or the agent
- `_meta/Meetings/` — stakeholder-confidential
- `_meta/Assets/*.{png,jpg,jpeg,gif,pdf,mp4,mov,zip}` — binaries (use git-lfs if you prefer)
- `.env`, `*.pem`, `*.key`, `secrets.json`, `credentials.json`
- Node / Python / build cruft
- IDE files and OS junk

To commit AI sessions or meetings for a specific project (e.g., team handover), remove those lines from the project's `.gitignore` before the first commit.

### Obsidian Sync vs git

The core `sync` plugin is enabled. The two systems coexist:

- **Obsidian Sync** moves the markdown content across your devices. It does *not* sync `.git/` (which is correct — git state isn't device-portable that way).
- **Git** moves commits between your machine and a remote (GitHub, Azure DevOps, etc.).

Add `.git` to **Settings → Files and Links → Excluded files** so Obsidian doesn't index `.git/` folders. Otherwise startup gets slow as you accumulate per-project repos.

### Per-project git, not vault-wide

The whole vault is *not* a single git repo. Per-project repos let you:

- Share or archive a single project (notes + code) without dragging the whole vault
- Keep personal notes outside any shared repo
- Use different remotes for different projects (some on GitHub, some Azure DevOps, some local-only)

Cross-project work (snippets, shared scripts) lives in `08 - Development/` and is not git-tracked by default.

## How it works with Claude

This vault works with **any** Claude integration — Claude Code from a terminal pointed at the vault folder, Claude.ai web, the Anthropic API, or the optional Claudian plugin if you have it installed. The workflow (vault-root `CLAUDE.md` auto-load, kickoff/wrap-up prompts, skills) is the same regardless of how you launch Claude. Project-level `_meta/CLAUDE.md` is read via the kickoff skill or by AGENTS.md-aware agents — see the context layering section below.

### The context layering

When you start a Claude session in a project folder, three layers of context apply:

1. **Vault-root `CLAUDE.md`** — global conventions: PARA layout, project-folder convention, AI handoff pattern, working style preferences. This is what tools like Claude Code load automatically when the working directory contains a `CLAUDE.md`.
2. **Project `_meta/CLAUDE.md`** — project-specific context: tech stack, domain glossary, conventions that override vault defaults, never-dos. **You must point Claude at this manually** (paste it, attach it, or use the kickoff prompt to instruct the agent to read it).
3. **Project `_meta/AI-Memory.md`** — durable corrections, validated approaches, and domain quirks from prior sessions. Read after CLAUDE.md to catch the things that aren't in formal docs.

### Two-stage prompt workflow

The vault ships with a paste-ready prompt library at `04 - Resources/AI/Prompts/` covering two distinct phases:

- **Bootstrap (one-time per project)** — `Project-Bootstrap.md` has four interview-style blocks that fill in `_meta/CLAUDE.md` and `_meta/PRD.md` for a brand new project. Run these once, right after creating the project.
- **Session kickoff (every working session)** — `Project-Session-Kickoff.md` has four blocks for starting and ending sessions: full kickoff, light kickoff (chat-only), resume in-flight work, and end-of-session wrap-up.

Both files are agent-agnostic — paste the relevant block into Claude, Codex, Cursor, ChatGPT, or any other agent.

### The session loop

For each AI session on a project (after one-time Bootstrap is done):

**Start:**
1. Open `04 - Resources/AI/Prompts/Project-Session-Kickoff.md`, pick the right block (full kickoff for fresh sessions, resume for continuing in-flight work, light kickoff for chat-only agents), paste into your agent.
2. The agent reads `_meta/CLAUDE.md` → `_meta/AI-Memory.md` → `_meta/README.md` → the latest `_meta/AI-Sessions/<file>`, recaps the project, surfaces relevant constraints, and asks what to focus on. *It does not propose work first.*

**During:**
3. Work happens. The agent edits files, runs commands, writes code.

**End:**
4. Paste the **End-of-session wrap-up** block from the same prompt file. The agent drafts:
   - A session summary for `_meta/AI-Sessions/<date>-<topic>.md` (use the `AI Session` Templater template for consistency).
   - Durable learnings for `_meta/AI-Memory.md` (corrections, validated approaches, domain quirks).
   - Any new ADRs for `_meta/Decisions/`.
5. You review and commit those artefacts.

This loop is what makes the vault *durable* across sessions. The next agent (or you in three months) can read `_meta/CLAUDE.md` + `_meta/AI-Memory.md` + the latest session summary and be productive in five minutes instead of fifty.

### Optional: the Claudian plugin

`Claudian` (`realclaudian`) is a community plugin that embeds Claude Code inside Obsidian — convenient if you want to avoid alt-tabbing to a terminal. It is **not required**; everything in this vault works equally well with Claude Code run externally (terminal in the project folder), Cursor, Codex, ChatGPT, or any other AI agent.

If you do install Claudian:

- It launches Claude Code with the vault (or a subfolder) as the working directory.
- The working directory's `CLAUDE.md` is auto-loaded — same behaviour as external Claude Code.
- Launch it at the project folder so `_meta/CLAUDE.md` and `AGENTS.md` are within reach.

(Aside: don't confuse Claudian with Claude.ai's web-product connectors — Claude.ai connectors are integrations on the hosted product, unrelated to this Obsidian plugin.)

## How it works with Codex

Codex (the term covers both the OpenAI Codex CLI and similar coding agents) uses the same layered context, but its conventions file is `CODEX.md`.

- Vault-root `CODEX.md` covers general code style preferences (PowerShell hygiene, secrets handling, commit hygiene). Stack-specific rules (ServiceNow, Next.js, etc.) live in `04 - Resources/AI/Presets/`, referenced per-project from `_meta/CLAUDE.md`.
- It explicitly tells Codex to read `_meta/CLAUDE.md` and `_meta/AI-Memory.md` for project context — there is no separate `_meta/CODEX.md` per project, because the project-level context is the same regardless of which agent reads it.
- Codex follows the same session-summary / AI-Memory / ADR loop as Claude.
- The same Bootstrap and Session Kickoff prompts at `04 - Resources/AI/Prompts/` apply — they're agent-agnostic. Paste them into Codex (or whichever code-focused agent you use) instead of Claude.

If you only ever used Claude, you could fold `CODEX.md` into `CLAUDE.md`. They're split because:

- `CODEX.md` carries language-specific style rules that don't apply to general AI tasks.
- Some agents (depending on the tool you use to invoke them) load only their named file by default.

## The context files explained

Putting all the `.md` "context" files in one table:

| File | Scope | Purpose | Who reads it |
|---|---|---|---|
| `CLAUDE.md` (vault root) | Global | Vault-wide conventions, PARA layout, project workflow, handoff pattern | Claude / agents in the vault working dir |
| `CODEX.md` (vault root) | Global | Code-flavoured preferences and commit hygiene | Codex / code-focused agents |
| `Vault-Map.md` (vault root) | Global | Terse structural reference | Humans (mostly) |
| `Vault-Guide.md` (vault root) | Global | This onboarding doc | Humans |
| `04 - Resources/AI/Prompts/Project-Bootstrap.md` | Global | Paste-ready prompts for scaffolding a new project (CLAUDE.md scaffold + PRD import/build/review) | You, when setting up a new project |
| `04 - Resources/AI/Prompts/Project-Session-Kickoff.md` | Global | Paste-ready prompts for starting/ending sessions (full kickoff / light kickoff / resume / wrap-up) | You, every working session |
| `04 - Resources/AI/Skills/<skill>/SKILL.md` | Global | Slash-command helpers for repeated workflow steps (`/kickoff`, `/wrap-up`, `/new-session-log`). Open standard format; imported into projects on creation. | The agent, when you invoke `/<skill>` |
| `_meta/README.md` (per project) | Project | Project overview, status, links, current focus. Frontmatter feeds dashboards (`type: project`, `status`, `area`, dates) | Humans + Dataview |
| `_meta/CLAUDE.md` (per project) | Project | Project-specific AI context: stack, glossary, conventions, never-dos. Auto-loaded by Claude Code. | Any AI agent working on the project |
| `AGENTS.md` (per project, at **root** — not `_meta/`) | Project | Pointer file with relative paths into `_meta/`. Auto-loaded by AGENTS.md-aware agents (Codex et al) when launched from the project root. | Codex / Cursor / any AGENTS.md-aware agent |
| `_meta/AI-Memory.md` (per project) | Project | Durable corrections, validated approaches, domain quirks | Any AI agent. Append-only |
| `_meta/AI-Sessions/<date>.md` | Per session | Transcript-style summary of a single session | Future sessions, future-you |
| `_meta/Decisions/NNNN-*.md` | Per decision | ADR-style: context, decision, alternatives, consequences. Immutable | Anyone trying to understand "why does the project do X this way" |
| `_meta/Risks-Issues/NNNN-*.md` | Per entry | Per-risk or per-issue tracking with status history | Project owners, handover readers |
| `_meta/Plans/NNNN-*.md` | Per plan | Implementation plan: approach + phases/slices. Can evolve (`draft → accepted → in-progress → complete`) or be superseded | AI agents executing the plan, future-you |
| `_meta/Slices/NNNN-*.md` | Per slice | Vertical implementation slice with acceptance criteria, test plan, and per-environment deployment status | Whoever is implementing, deploying, or auditing rollout |
| `_meta/Specs/NNNN-*.md` | Per spec | Technical specification: architecture, data model, API contracts, edge cases, non-functionals | Anyone implementing against the contract; AI agents writing code |
| `_meta/References/` | Project | Mockups, screenshots, examples, related-system docs you'll look up repeatedly | Humans + AI agents when context is needed beyond the spec |

### Vault-root vs project-level — the key distinction

- **Vault-root files** are about *how to work in this vault overall*. They don't know about any specific project.
- **Project `_meta/` files** are about *this specific project*. They don't restate vault conventions — they add to or override them.

The agent should read vault-root → project-`_meta/` in that order. The project layer wins when conventions conflict.

### `CLAUDE.md` vs `AI-Memory.md` (per project)

These both look like "things the agent should know" but they're different:

- `_meta/CLAUDE.md` is the **stable contract** — designed, written deliberately, updated occasionally. Stack, conventions, glossary, never-dos.
- `_meta/AI-Memory.md` is the **growing logbook** — corrections you've given the agent, things that surprised you, validated approaches. Append-only. The agent reads it but typically *you* (or the agent at end-of-session) are the one writing to it.

A useful test: if the agent does X wrong twice, it goes in `AI-Memory.md`. If it's a documented project rule you'd tell *any* contributor, it goes in `CLAUDE.md`.

### `Decisions/` vs `AI-Memory.md`

- `Decisions/` records **project decisions** (we chose REST over GraphQL because…). Decisions are immutable and superseded by new ADRs.
- `AI-Memory.md` records **how to work with AI on this project** (don't use the old SDK version; the staging URL is X; field Y is computed not stored).

If the rule survives a change of AI agent (or applies to humans too), it's a decision. If it's specifically about steering AI sessions, it's memory.

## Templates and plugins

### Templates

Live under `System/Templates/`:

- `System/Templates/Notes/` — note templates: Daily / Weekly / Monthly notes, Meeting Note, AI Session, Message Draft, Dev Log
- `System/Templates/Projects/Work/` and `System/Templates/Projects/Personal/` — the full project template trees that `New-ObsidianProject.ps1` copies

Calendar and AI Session templates have YAML frontmatter (`type: daily`, `type: weekly`, `type: monthly`, `type: ai-session`) so Dataview can query them by date or kind.

### Prompts

Live under `04 - Resources/AI/Prompts/`:

- **`Project-Bootstrap.md`** — one-time per project. Four interview-style blocks for filling in `_meta/CLAUDE.md` and authoring `_meta/PRD.md` (import / build / review).
- **`Project-Session-Kickoff.md`** — per working session. Four blocks: full kickoff, light kickoff (chat-only), resume in-flight work, end-of-session wrap-up.

Both files are agent-agnostic — paste blocks into Claude, Codex, Cursor, ChatGPT, or any other agent. `Create-ObsidianAiVault.ps1` scaffolds them automatically so peer vaults get the same toolkit out of the box.

The pointers at the top of `_meta/CLAUDE.md` and `_meta/PRD.md` templates link to `Project-Bootstrap.md` so new users discover the scaffolding prompts without hunting for them.

### Skills

Live under `04 - Resources/AI/Skills/`:

- **`kickoff/`** — slash-command version of the session kickoff (Bootstrap-equivalent for fresh project sessions).
- **`wrap-up/`** — slash-command version of the end-of-session capture.
- **`new-session-log/`** — creates a dated AI Session log file from the template.

Skills follow the [Agent Skills open standard](https://agentskills.io) — same `SKILL.md` format works in Claude Code, Codex, Cursor, Goose, Gemini CLI, etc. Skills are the **invocable** counterpart of the **paste-able** prompts: same workflow, different ergonomics. Use whichever feels right per moment.

**Skills are project-helper / builder tools, not project deliverables.** When you create a project with `New-ObsidianProject.ps1 -Skills Default`, the selected skills are copied to **both** `.claude/skills/` (Claude Code) and `.agents/skills/` (Codex and other agents following the open standard) at the project root. Both paths are gitignored — each developer's checkout has their own copies.

If a project's deliverable *is* a skill (e.g. a project building a custom skill for distribution), remove `.claude/skills/` and `.agents/skills/` from that project's `.gitignore`. Helper skills and deliverable skills are conceptually distinct.

### Plugins enabled

| Plugin | Why it's here |
|---|---|
| Core: Templates | Resolves `{{date}}` / `{{title}}` tokens in templates |
| Core: Daily Notes | Auto-creates daily notes with a date-named filename |
| Core: Properties | Frontmatter editing UI |
| Core: Bases | Native query/database — alternative to Dataview, reads frontmatter |
| Core: Sync | Cross-device sync of markdown |
| Templater (community) | Folder Templates (auto-apply on file creation), richer date/scripting |
| Dataview (community) | The `dataview` code blocks in dashboards and `_meta/Decisions/README.md` |
| Claudian (community, `realclaudian`) — **optional** | Embeds Claude Code inside Obsidian. Not required; external Claude Code / Codex / Cursor / ChatGPT work the same way |
| Obsidian Local REST API | (Optional) HTTP access to the vault |

### Key settings to know

`Create-ObsidianAiVault.ps1` writes three of these to `.obsidian/*.json` during vault creation. Templater settings remain manual because the plugin is installed by hand on first launch.

- **Settings → Templates → Template folder location** = `System/Templates` *(auto — `.obsidian/templates.json`)*
- **Settings → Templater → Template folder location** = `System/Templates` *(manual — set after installing Templater)*
- **Settings → Templater → Folder Templates** = (see [[System/Workflows/New-Project|New Project workflow]] for the mappings) *(manual)*
- **Settings → Files and Links → New link format** = **"Relative path to file"** *(auto — `.obsidian/app.json`)*. Avoids cross-project link ambiguity since every project has files with the same names.
- **Settings → Files and Links → Excluded files** = add `.git` so Obsidian doesn't index per-project git folders *(auto — `.obsidian/app.json`, `userIgnoreFilters`)*

## Where each kind of thing lives

Quick lookup when you're not sure where to put something.

| Thing | Where |
|---|---|
| Quick capture you'll process later | `00 - Inbox/` |
| Today's working note | `01 - Calendar/Daily/` |
| A new project (Work) | `02 - Projects/Work/<Project>/` — create with `New-ObsidianProject.ps1` |
| A reusable AI prompt (one-off, project-agnostic) | `04 - Resources/AI/Prompts/` |
| The Bootstrap / Kickoff prompts | `04 - Resources/AI/Prompts/Project-Bootstrap.md` and `Project-Session-Kickoff.md` |
| A helper skill (gitignored per-project) | `04 - Resources/AI/Skills/<skill>/SKILL.md` — copy into project `.claude/skills/` and `.agents/skills/` via `New-ObsidianProject.ps1 -Skills` |
| A skill that IS a project deliverable | Wherever the project requires (e.g. `src/skills/`). Commit it. Remove `.claude/skills/` and `.agents/skills/` from that project's `.gitignore`. |
| A meeting note tied to a specific project | `02 - Projects/<Type>/<Project>/_meta/Meetings/` |
| A meeting note NOT tied to a project | `06 - Meetings/<Work\|Personal\|Recurring>/` |
| Cross-project script or snippet | `08 - Development/<category>/` |
| Project-specific script or code | At the project's repo root, *not* in `08 - Development/` |
| A decision about the project | `02 - Projects/<Type>/<Project>/_meta/Decisions/NNNN-*.md` |
| An implementation plan | `02 - Projects/<Type>/<Project>/_meta/Plans/NNNN-*.md` |
| A unit of implementation work to track through deployment | `02 - Projects/<Type>/<Project>/_meta/Slices/NNNN-*.md` |
| A technical spec (architecture, API, data model) | `02 - Projects/<Type>/<Project>/_meta/Specs/NNNN-*.md` |
| A mockup, screenshot, or external example | `02 - Projects/<Type>/<Project>/_meta/References/<subfolder>/` |
| A correction the AI agent should remember on this project | `02 - Projects/<Type>/<Project>/_meta/AI-Memory.md` |
| A correction about how the AI should behave *everywhere* | Vault-root `CLAUDE.md` or `CODEX.md` (commit deliberately) |
| Claude Code skills / commands specific to this project | `.claude/skills/` and `.claude/commands/` at project root (not `_meta/`) — Claude Code looks for them at the working dir root |
| Workflow documentation | `System/Workflows/` |
| Reusable template (note or project) | `System/Templates/` |
| Vault scaffolding scripts | `System/Scripts/` |
| Bring an old project's structure up to current template | `System/Scripts/Repair-ObsidianProject.ps1` — adds missing files/folders only |

> **Python alternative.** Each PowerShell script in `System/Scripts/` ships with a Python equivalent (`new_project.py`, `repair_project.py`) that does the same thing. Use `python new_project.py` on macOS/Linux, or either on Windows.

## Related workflows

- [[System/Workflows/New-Project|Creating a new project]]
- [[System/Workflows/Repair-Project|Repairing a project]] — bring an older project back in sync with the current template (adds missing files, never overwrites)
- [[System/Workflows/Archive-Project|Archiving a project]]
- [[04 - Resources/AI/Prompts/Project-Bootstrap|Bootstrap prompts]] — one-time per project: scaffold CLAUDE.md, author PRD (import / build / review)
- [[04 - Resources/AI/Prompts/Project-Session-Kickoff|Session Kickoff prompts]] — every working session: full / light / resume / wrap-up
- [[04 - Resources/AI/Skills/README|Skill library]] — slash-command helpers (`/kickoff`, `/wrap-up`, `/new-session-log`)
- [[CLAUDE|Vault-root CLAUDE.md]] — the canonical agent contract
- [[CODEX|Vault-root CODEX.md]] — code-focused agent preferences
- [[Vault-Map]] — terse structural reference
