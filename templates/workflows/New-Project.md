---
type: workflow
tags: [workflow, project]
---

# New project workflow

How to spin up a new project under `02 - Projects/Work/` or `02 - Projects/Personal/`. Covers the three repo modes (notes-only / new code / cloned repo) and what to do after the script finishes.

## TL;DR

```powershell
# Notes-only project (no git)
.\System\Scripts\New-ObsidianProject.ps1 -ProjectName "My Project" -ProjectType Work

# New code project (git init at project root, stubbed root README)
.\System\Scripts\New-ObsidianProject.ps1 -ProjectName "Pwd Reset Gateway" -ProjectType Work -RepoMode Init

# Existing repo (clone into project folder, overlay _meta/)
.\System\Scripts\New-ObsidianProject.ps1 `
  -ProjectName "Pwd Reset Gateway" `
  -ProjectType Work `
  -RepoMode Clone `
  -RepoUrl "https://github.com/example/pwd-reset-gateway.git"
```

Run with no parameters for an interactive prompt.

## What you get

Every new project lays out the same way:

```
02 - Projects/<Type>/<Project>/
  .gitignore               ← repo root (or _meta/.gitignore in Clone mode)
  AGENTS.md                ← auto-discovery pointer for Codex / AGENTS.md-aware agents
  README.md                ← only in Init mode — short, repo-facing stub
  _meta/                   ← Obsidian-managed working notes
    README.md              ← project home note (status, links, focus)
    CLAUDE.md              ← load-bearing AI context: stack, glossary, never-dos
    AI-Memory.md           ← AI corrections, validated approaches, domain quirks
    PRD.md                 ← what we're building (business-level)
    Scope.md
    Tasks.md
    Handover.md
    Decisions/             ← ADR folder — one file per decision (immutable)
      README.md, 0000-template.md
    Risks-Issues/          ← one file per risk or issue
      README.md, 0000-template.md
    Plans/                 ← implementation plans; how we'll build it, in phases/slices
      README.md, 0000-template.md
    Slices/                ← vertical slices of work with per-env deployment tracking
      README.md, 0000-template.md
    Specs/                 ← technical specs (architecture, data model, API contracts)
      README.md, 0000-template.md
    References/            ← mockups, screenshots, examples, related-system docs
      README.md
    AI-Sessions/           ← gitignored by default
    Meetings/              ← gitignored by default
    Assets/                ← binaries gitignored; markdown attachments kept
    Development/           ← Work only: dev notes, test cases, prompts, scripts
```

Not every project will use every folder. Notes-only projects often use just PRD/Tasks/Decisions. A full code rollout will use Plans + Slices + Specs + References. Empty folders cost nothing; the consistent shape helps AI agents know where to look.

The script fills in:

- `_meta/README.md` frontmatter (`status`, `area`, `owner`, `start_date`, `target_date`) and the `# <Project>` heading
- `project:` frontmatter field in CLAUDE.md, AI-Memory.md, and the Decisions/Risks-Issues templates
- A `Project: [[<name>]]` reference under the heading of files without frontmatter

## Repo modes

### `-RepoMode None` (default)

No git is run. Template is copied as-is, including the root `.gitignore` (so a later `git init` already has sensible defaults). Use this for notes-only projects — stakeholder coordination, planning work, anything without code.

### `-RepoMode Init`

For a new project where you'll own the repo from scratch.

1. Template copied to project folder
2. `_meta/` filled in as usual
3. **Stubbed root `README.md`** created with the project title and a pointer to `_meta/`
4. `git init` run at the project root

The stubbed root README is repo-facing (audience: anyone who clones your repo). `_meta/README.md` is project-facing (audience: you and AI agents). They serve different readers.

You'll need to add a remote (`git remote add origin …`) and make the first commit yourself.

### `-RepoMode Clone -RepoUrl <url>`

For an existing external repo you want to track in Obsidian.

1. `git clone <url>` runs first — the project folder *is* the cloned repo
2. The `_meta/` template is overlaid into the cloned repo
3. The template `.gitignore` lands at **`_meta/.gitignore`** (not the root) — the cloned repo's own root `.gitignore` is left untouched
4. Other template root-level files (e.g. `AGENTS.md`) are copied to the project root, **but only if the cloned repo doesn't already have a file with that name**. If the upstream repo already has its own `AGENTS.md`, we respect it.
5. `_meta/` fields (frontmatter `project:`) are filled in. The project-root `AGENTS.md` (if newly added by us) also gets its `project:` field set.

The cloned repo's `README.md` / `CLAUDE.md` at root stay as the upstream maintainers wrote them. Yours in `_meta/` are separate.

**You may want to add `_meta/` to the cloned repo's root `.gitignore`** if you don't want your project notes committed to the upstream repo at all. Or merge the contents of `_meta/.gitignore` into the root `.gitignore` if you do want some `_meta/` content tracked.

## .gitignore behaviour

The template `.gitignore` excludes:

- `_meta/AI-Sessions/` — Claude/Codex session logs may contain secrets or sensitive context
- `_meta/Meetings/` — stakeholder-confidential
- `_meta/Assets/*.{png,jpg,jpeg,gif,pdf,mp4,mov,zip}` — binaries (use git-lfs instead if you prefer)
- `.env`, `*.pem`, `*.key`, `secrets.json`, `credentials.json`
- Node / Python / build cruft
- IDE files and OS junk

To **commit** AI sessions or meetings on a specific project, remove or comment those lines in that project's `.gitignore` before your first commit.

## First-time setup (right after the script finishes)

The script gives you a structurally complete project with empty content files. Two of those files — `_meta/CLAUDE.md` and `_meta/PRD.md` — need to be populated before AI sessions get useful. The fastest way is to use the **Bootstrap prompts** at [[../../04 - Resources/AI/Prompts/Project-Bootstrap|04 - Resources/AI/Prompts/Project-Bootstrap]]. They work with any AI agent (Claude, Codex, Cursor, ChatGPT) — interview-style.

Recommended order:

1. **Scaffold `_meta/CLAUDE.md`** — open the Bootstrap prompt file, copy the first block ("Scaffold `_meta/CLAUDE.md`"), paste it into your agent. The agent will ask you 6 structured questions about the project (summary, goal, stack, glossary, conventions, never-dos) and write `_meta/CLAUDE.md` for you. Takes 5-10 minutes.

2. **Author `_meta/PRD.md`** — pick one of the three PRD modes in the Bootstrap file:
   - **Import** — paste content from an external tool (Notion, Linear, Aha!, an email thread). Agent maps it into the PRD template and flags gaps.
   - **Build** — interview from scratch when you have an idea but nothing written down.
   - **Review** — paste an existing draft for a structured completeness/clarity check before locking it in.

3. **Sanity-check** (optional) — re-run the **Review** prompt on the PRD you just authored. Catches vague goals, missing acceptance criteria, undefined terms.

4. **Ready for real work** — switch from the Bootstrap prompts to the [[../../04 - Resources/AI/Prompts/Project-Session-Kickoff|Session Kickoff prompts]] for ongoing work (full kickoff / light kickoff / resume / wrap-up).

The Bootstrap prompts are **one-time per project**. The Session Kickoff prompts are what you'll use every working session afterwards.

## Working with AI on the project

The flow Claude / Codex / ChatGPT should follow (codified in vault-root `CLAUDE.md`):

1. Read `_meta/CLAUDE.md` first — the load-bearing context
2. Read `_meta/README.md` for status and outcome
3. Check `_meta/AI-Memory.md` for prior corrections and domain quirks
4. Check `_meta/PRD.md`, `_meta/Tasks.md`, `_meta/Decisions/` as needed
5. Check `_meta/AI-Sessions/` for prior session summaries
6. **At end of session:** append a session note to `_meta/AI-Sessions/` (use the `AI Session` Templater template)
7. Append durable learnings to `_meta/AI-Memory.md` — *only* things future agents need (corrections, validated approaches, quirks). Session-specific stuff stays in the session note

## Adding a decision

Decisions are immutable. To record one:

1. Copy `_meta/Decisions/0000-template.md` to `_meta/Decisions/NNNN-short-title.md` (next free number, kebab-case)
2. Fill in context, decision, alternatives, consequences
3. Set `status: accepted` in frontmatter once decided

To change an existing decision, write a new ADR that supersedes it, then update the old one's `status: superseded` and `superseded_by: NNNN-replacement-title`.

## Adding a risk or issue

1. Copy `_meta/Risks-Issues/0000-template.md` to `_meta/Risks-Issues/NNNN-short-title.md`
2. Set `kind: risk` (potential, with likelihood) or `kind: issue` (active, with status)
3. Update `status` as it evolves; append entries to the History section

## Adding an implementation plan

Use a plan when you have a non-trivial body of work that needs to be sequenced into phases or slices. Often the output of a "write plan" / "planning" session with an AI.

1. Copy `_meta/Plans/0000-template.md` to `_meta/Plans/NNNN-short-title.md`
2. Fill in goal, context, approach, and break the work into phases/slices
3. Set `status: accepted` once you're committing to it
4. As you start each slice, create a matching file in `_meta/Slices/` and set `plan: NNNN-this-plan`
5. If the plan needs major rework, write a new plan with `supersedes: NNNN-old`, set the old plan's `superseded_by`, and move on

## Adding a slice + tracking deployment

A slice is a vertical unit of implementation work — something that can be built, tested, and shipped end-to-end on its own.

1. Copy `_meta/Slices/0000-template.md` to `_meta/Slices/NNNN-short-title.md`
2. Set `plan: NNNN-parent-plan` to link the parent plan
3. Fill in goal, scope, acceptance criteria, test plan, deployment plan
4. Work the slice. Update `status` (`planning → in-progress → complete`).
5. As you deploy through environments, update the `deploy_*` fields:
   ```yaml
   deploy_dev: deployed
   deploy_test: deployed
   deploy_staging: not-deployed   # next promotion
   deploy_prod: not-deployed
   deploy_history:
     - "2026-05-15 dev: shipped via PR #142"
     - "2026-05-16 test: smoke passed"
   ```
6. `_meta/Slices/README.md` and `System/Dashboards/Project Dashboard.md` will pick this up automatically and show "ready to promote" lists.

## Adding a technical spec

Use a spec when the *how it works* is non-trivial — architecture across components, a data model worth pinning down, an API contract others will rely on.

1. Copy `_meta/Specs/0000-template.md` to `_meta/Specs/NNNN-short-title.md`
2. Fill in summary, context, architecture, data model, API
3. Set `status: accepted` once stable
4. Link the spec from any plans / slices that implement against it

If you radically change a spec later, supersede it (new file with `supersedes:`, old file gets `status: superseded` + `superseded_by:`).

## Reference material

Drop reusable reference material into `_meta/References/` — mockups, screenshots, example implementations, sample data. Suggested subfolders: `Mockups/`, `Screenshots/`, `Examples/`, `Architecture/`, `Data/`, `External/`.

Distinct from `_meta/Assets/` (inline attachments embedded in notes) — `References/` is for material you'll *look up repeatedly* while working.

## Skills (the `-Skills` parameter)

By default, `New-ObsidianProject.ps1 -Skills Default` imports a curated set of **helper skills** into the project — slash-command versions of the most common workflows.

### Modes

| `-Skills` value | Behaviour |
|---|---|
| (omitted) | Interactive prompt — same as picking `Default` if you just hit Enter |
| `None` | Don't import any skills. `.claude/` and `.agents/` not created at the project root. |
| `Default` | Curated set: `kickoff`, `wrap-up`, `new-session-log` (recommended) |
| `All` | Every skill folder in `04 - Resources/AI/Skills/` |
| `Custom` | Interactive y/N picker for each skill in the library |
| `kickoff,wrap-up` (comma-list) | Import exactly those named skills |

### Where they land

Selected skills are copied to **both**:

- `.claude/skills/<skill>/SKILL.md` — read by Claude Code
- `.agents/skills/<skill>/SKILL.md` — read by Codex and any agent following the open standard ([agentskills.io](https://agentskills.io))

Same content in both locations. Whichever agent you happen to be running in this project, the skills work.

### Gitignore behaviour

Helper skills are **gitignored by default** — they help you *work on* the project, they're not part of any deliverable. Each developer's checkout has its own copies.

- **None / Init modes:** the project-root `.gitignore` includes `.claude/skills/` and `.agents/skills/` lines (from the template).
- **Clone mode:** the cloned repo's root `.gitignore` is left untouched. Instead, the script appends `.claude/skills/` and `.agents/skills/` to `.git/info/exclude` — local-only, never committed, never affects the upstream repo.

### If a project's deliverable IS a skill

Then those skills should be committed, not gitignored. Remove or comment out the `.claude/skills/` and `.agents/skills/` lines from the project's `.gitignore` (or don't add them to `.git/info/exclude` in Clone mode). Helper skills you'd want for development can still live alongside — just be careful to commit only the deliverable.

### Refreshing skills in an existing project

Skills are snapshotted at import. Updating one in the vault library doesn't propagate. To refresh:

```powershell
Copy-Item -Path "<vault>\04 - Resources\AI\Skills\<skill>" `
          -Destination "<project>\.claude\skills\" -Recurse -Force
Copy-Item -Path "<vault>\04 - Resources\AI\Skills\<skill>" `
          -Destination "<project>\.agents\skills\" -Recurse -Force
```

### Adding a new helper skill to the library

See [[../../04 - Resources/AI/Skills/README|the library README]] for the "Adding a new skill" steps.

## Common gotchas

- **`git init` fails** — script will tell you. Usually means git isn't on PATH. Either install git or re-run with `-RepoMode None`.
- **Project already exists** — script refuses to overwrite. Delete the folder first if you really want to recreate, or pick a different name.
- **Template path not found** — run `System\Scripts\Create-ObsidianAiVault.ps1` first to scaffold the templates.
- **README links inside `_meta/` look unresolved in Obsidian** — wiki-links like `[[PRD]]` resolve by note name; if you have multiple projects each with a `PRD`, Obsidian's "shortest path" resolution picks one. Use the file from Quick Switcher within the project folder to navigate reliably, or enable Settings → Files and Links → "Relative path" in Obsidian.
- **Dataview indexes / dashboards empty** — confirm Dataview is installed, then check that `_meta/README.md` has `type: project` in its frontmatter. Frontmatter is what dashboard queries match on.

## Related

- Vault-root [[CLAUDE]] — canonical conventions
- Project template tree: `System/Templates/Projects/`
- Scripts: `System/Scripts/Create-ObsidianAiVault.ps1` (vault scaffold), `System/Scripts/New-ObsidianProject.ps1` (this workflow)
