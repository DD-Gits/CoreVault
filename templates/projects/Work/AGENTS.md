---
type: project-agents
project:
---

# AGENTS.md

This project is tracked using a vault-level Obsidian + AI workflow. The substantive project context for AI agents lives under `./_meta/`. **Read `./_meta/CLAUDE.md` first.**

## Quick links (relative paths, navigable by any agent)

- `./_meta/CLAUDE.md` — project context: stack, conventions, glossary, never-dos. Load-bearing.
- `./_meta/AI-Memory.md` — corrections, validated approaches, domain quirks from prior sessions. Treat its "Corrections" section as hard rules.
- `./_meta/README.md` — project status and current focus.
- `./_meta/PRD.md` — what we're building (business-level).
- `./_meta/AI-Sessions/` — prior session summaries (read the most recent before starting work).
- `./_meta/Decisions/` — ADR-style records of project decisions (immutable).

## Where to record outcomes

- End-of-session summary → `./_meta/AI-Sessions/<YYYY-MM-DD>-<topic>.md`
- Durable learnings (corrections, validated approaches) → append to `./_meta/AI-Memory.md`
- New decisions → new file in `./_meta/Decisions/` based on `0000-template.md`

## Cross-project conventions

For code-style preferences that apply across all projects, see the vault-root `CODEX.md` (typically `../../../CODEX.md` from this file's location — up through the project folder, project-type folder, and `02 - Projects/` to the vault root).
