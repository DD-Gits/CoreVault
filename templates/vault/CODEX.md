# CODEX.md

Coding-agent guidance for this vault. Companion to vault-root `CLAUDE.md`; this file focuses on how to write code for a project, not the project workflow itself.

## Project layout (recap)

Each project under `02 - Projects/<Work|Personal>/<Project>/` is structured as a (potential) git repo:

- Project root holds code, `README.md` (repo-facing), and `.gitignore`.
- `_meta/` holds Obsidian-managed working notes (`CLAUDE.md`, `AI-Memory.md`, `PRD.md`, `Decisions/`, etc.).

See vault-root `CLAUDE.md` for the canonical workflow.

## General coding preferences

- Prefer small, reviewable changes.
- Explain assumptions before large refactors.
- Do not introduce new dependencies unless necessary.
- Preserve existing comments where possible.
- Add clear comments for complex logic.
- Prefer readable code over clever code.
- Keep generated code easy to test and hand over.

## PowerShell preferences

- Use clear parameter names.
- Prefer functions for reusable logic.
- Use safe defaults.
- Do not hardcode secrets.
- Avoid writing credentials or tokens to logs.
- Use `-WhatIf` style patterns where appropriate for destructive changes.

## Repository and script hygiene

- Keep one-off scripts organised by platform or tool.
- Add a short header explaining purpose, inputs, and usage.
- Avoid committing secrets, bearer tokens, client secrets, or embedded credentials.
- Prefer environment variables, secret stores, or secure vaults for credentials.
- Respect the project's `.gitignore` (or `_meta/.gitignore` in clone-mode projects). Do not add committed copies of files that the gitignore excludes by default (`.env`, secrets, AI session logs, meeting notes, binary assets).

## AI coding workflow

### Project setup (one-time per project)

Same as Claude: right after `New-ObsidianProject.ps1` creates the project, use the **Bootstrap prompts** at [[04 - Resources/AI/Prompts/Project-Bootstrap]] to populate `_meta/CLAUDE.md` (the load-bearing project context — read by all agents, including Codex) and `_meta/PRD.md`. The prompts are agent-agnostic, so paste blocks into Codex directly.

**Auto-discovery for Codex:** each project includes an `AGENTS.md` pointer file **at the project root** (not under `_meta/` — Codex looks at working-dir + parents, not children). When Codex is launched from the project folder, it auto-loads this file, which points to `./_meta/CLAUDE.md` for the substantive context.

### Session start modes

The steps below describe a **full kickoff** for a coding session — read project context before touching code. Use this mode for a fresh session or after a long break. For continuing in-flight work, prefer the **Resume** prompt — it's fine for coding work; you'd skip the recap and pick up from the last session's Handoff. All session prompts live in [[04 - Resources/AI/Prompts/Project-Session-Kickoff]] (kickoff / light kickoff / resume / wrap-up).

### Skills (slash-command alternative)

If the project has helper skills imported (default for new projects), the same workflows are available as slash commands via Codex's `.agents/skills/` discovery: `/kickoff`, `/wrap-up`, `/handoff`, `/new-session-log`. These follow the [Agent Skills open standard](https://agentskills.io) and work in any compatible agent. See [[04 - Resources/AI/Skills/README|the skill library]] for details.

### Full-kickoff flow for code work

Before making changes:

1. Read `_meta/CLAUDE.md` for project context (stack, conventions, never-dos).
2. Read `_meta/AI-Memory.md` for corrections and validated approaches from prior sessions.
3. Check `_meta/Decisions/` for ADRs that constrain the change (especially anything `status: accepted` that's relevant).
4. Check `_meta/Specs/` if a relevant spec exists — it pins down architecture, data, and API contracts.
5. If there's an active plan in `_meta/Plans/` or slice in `_meta/Slices/` matching this work, read it.
6. Skim recent files in `_meta/AI-Sessions/` for in-flight work.
7. Identify the goal and relevant files.
8. Summarise the current behaviour.
9. Propose the smallest useful change.
10. Apply the change.
11. Explain what changed and how to test it.

After changes:

- Append a session summary to `_meta/AI-Sessions/` using the `AI Session` template (date, tool, goal, decisions, files touched, follow-ups, handoff).
- Append durable learnings to `_meta/AI-Memory.md` — only things future agents need (corrections, validated approaches, domain quirks). Session-specific detail stays in the session note.
- If a new decision was made, add a new ADR file in `_meta/Decisions/` (copy `0000-template.md`). Do not modify existing decisions; supersede them with a new file.

## Commit hygiene

- Prefer focused commits with clear, present-tense messages ("Add retry to webhook handler", not "fixed stuff").
- Don't `git add -A` or `git add .` blindly — review what's staged. The default `.gitignore` excludes AI sessions and meeting notes for a reason; a blanket add can override carelessly.
- For Clone-mode projects: `_meta/` is overlaid on top of someone else's repo. Check whether your changes should land in `_meta/` (your notes) or at root (their code) before staging.
- Don't push without checking the diff for secrets or sensitive context pasted into notes during AI sessions.
