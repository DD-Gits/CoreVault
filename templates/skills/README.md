---
type: skills-index
tags: [skills, library]
---

# Skill library

Project helper / builder skills that wrap repeated workflow steps. Skills here follow the [Agent Skills open standard](https://agentskills.io) — same `SKILL.md` format works in Claude Code, Codex, Cursor, Goose, Gemini CLI, and many others.

## Purpose: helpers, not deliverables

Skills in this library are **personal workflow helpers** — kickoff, wrap-up, session logging, and similar. They help you *work on* projects, they are not part of any project's deliverable.

This distinction matters for git:

- **Helper skills** (this library) are **gitignored** at the project level by default. Each developer's checkout has its own copies, no shared commit history.
- **Skills that are part of a project's deliverable** (e.g. a project building a custom skill for distribution) live wherever the project requires, are committed, and are NOT imported from this library.

The template `.gitignore` excludes `.claude/skills/` and `.agents/skills/`. If a project's deliverable is itself a skill, remove those lines per-project.

## What's in the library

### Core protocol skills (default set)

These ship in every new project by default. They implement the workflow's load-bearing protocol.

| Skill | Purpose | Invoke via |
|---|---|---|
| `kickoff` | Start a fresh session: reads `_meta/CLAUDE.md`, `_meta/AI-Memory.md`, `_meta/README.md`, and the latest `_meta/AI-Sessions/<file>`; recaps; asks what to focus on. | `/kickoff` |
| `wrap-up` | End-of-session capture: runs the lightweight evaluator pass, drafts session summary, identifies AI-Memory updates, flags new ADRs. | `/wrap-up` |
| `new-session-log` | Create a dated session log file in `_meta/AI-Sessions/` from the AI Session template structure. | `/new-session-log [topic]` |
| `handoff` | Mid-session compaction. Writes a checkpoint file and produces a self-contained continuation prompt for resuming in a fresh chat. Use when context is filling up but the slice isn't done. | `/handoff` |

### Optional skills (alignment and exploration)

These are pre-work skills that fire *before* implementation begins. Not included in the default set — import via `--skills Custom` or `--skills All`, or per-skill comma-list.

| Skill | Purpose | Invoke via |
|---|---|---|
| `grill` | Pre-work alignment ritual. Default style is Pocock interrogation; projects can override via a `Grilling style:` note in `_meta/CLAUDE.md`. Pass an optional style argument to force a specific approach: `/grill pocock`, `/grill brainstorm`, `/grill devil`. | `/grill` |
| `devils-advocate` | Agent argues *against* your plan — strongest case for not doing it. Use when you suspect you're attached to a particular approach and want a genuine counter-position. | `/devils-advocate` |
| `brainstorm` | Divergent exploration. Generates a spread of approaches before you commit. Use when the goal is clear but the approach isn't. | `/brainstorm` |

All skills have `disable-model-invocation: true` set so the agent won't auto-trigger them. You decide when to invoke.

### When to use which alignment skill

- **`/grill`** — you have a draft plan; you want it sharpened into a verifiable Slice Contract. Default style follows project setting (Pocock unless overridden in `_meta/CLAUDE.md`).
- **`/grill <style>`** — force a specific grilling style for this invocation: `/grill pocock`, `/grill brainstorm`, `/grill devil`.
- **`/devils-advocate`** — you have a draft plan; you want to see if it survives adversarial review.
- **`/brainstorm`** — you don't have a plan yet; you want to see the realistic option space.

Roughly: brainstorm → grill → devils-advocate, but most work uses one of them, not all three.

## How skills land in a project

When you create a new project via `New-ObsidianProject.ps1` with `-Skills Default` (the default), the script copies the curated set into **both** locations at the project root:

- `.claude/skills/<skill>/SKILL.md` — read by Claude Code
- `.agents/skills/<skill>/SKILL.md` — read by Codex and any agent following the open standard

Both paths are gitignored. Each developer ends up with their own copies; the originals stay in this library.

## Import modes (the `-Skills` parameter)

| Value | Behaviour |
|---|---|
| `None` | Do not copy any skills. `.claude/` and `.agents/` not created. |
| `Default` (default) | Copy the curated default set: `kickoff`, `wrap-up`, `new-session-log`, `handoff`. |
| `All` | Copy every skill folder in this library. |
| `Custom` | Interactive picker — pick which skills to copy. |
| Comma-list (e.g. `-Skills kickoff,wrap-up,grill`) | Copy exactly those named skills. |

## Adding a new skill to the library

1. Create a folder: `04 - Resources/AI/Skills/<skill-name>/`
2. Add `SKILL.md` with frontmatter (`description` minimum; consider `disable-model-invocation: true` for explicit-invoke skills; `argument-hint` for parameterised skills).
3. Optionally include `scripts/`, `references/`, or `assets/` subdirectories alongside `SKILL.md`.
4. Update the table above.
5. If the new skill should be in the `Default` import set, also add it to the default list in `New-ObsidianProject.ps1` (`$DefaultSet` in `Resolve-SkillSelection`) and `Create-ObsidianAiVault.ps1`.

## Refreshing skills in an existing project

Skills are snapshotted at import time — updating a skill in this library does NOT automatically propagate to existing projects. To refresh:

```powershell
# Copy from library to the project's .claude/skills/ and .agents/skills/
Copy-Item -Path "C:\path\to\vault\04 - Resources\AI\Skills\<skill>" `
          -Destination "C:\path\to\project\.claude\skills\" `
          -Recurse -Force
Copy-Item -Path "C:\path\to\vault\04 - Resources\AI\Skills\<skill>" `
          -Destination "C:\path\to\project\.agents\skills\" `
          -Recurse -Force
```

A dedicated `-SyncSkills` flag may land later if this becomes a frequent need.

## Notes on agent-specific behaviour

- **Claude Code** reads project skills from `.claude/skills/`. Skill descriptions live in context so the agent knows what's available; full content loads when invoked. Supports `disable-model-invocation`, `allowed-tools`, dynamic context injection (`` !`command` ``), and argument substitution (`$ARGUMENTS`, `$0`, `$1`, etc.).
- **Codex** reads from `.agents/skills/`. Similar core behaviour; some advanced features may differ.
- **Other agents** (Cursor, Goose, Gemini CLI, etc.) — each has its own conventions; the SKILL.md core format works everywhere.

## Related

- [[Project-Bootstrap]] — one-time per project: scaffold CLAUDE.md, author PRD
- [[Project-Session-Kickoff]] — paste-ready prompt versions of the kickoff / wrap-up flows (use when you can't or don't want to install skills)
