---
name: verify-context
description: List the project context files currently loaded in this session, so you can spot if the auto-load chain (project-root CLAUDE.md → _meta/CLAUDE.md → stack preset) silently didn't fire. Use when the agent seems to be guessing at conventions or asking questions that CLAUDE.md should have answered.
disable-model-invocation: true
---

State, in order, what is currently in your context for this project. Do not re-read anything to find out — report what you already have, because that's what we're verifying.

For each of the following, say either "loaded" (with a one-line summary of what the file says) or "not loaded":

1. The project's root `CLAUDE.md` stub (the file containing the `@_meta/CLAUDE.md` reference).
2. `_meta/CLAUDE.md` — the substantive project context.
3. Any stack presets referenced from `_meta/CLAUDE.md` (e.g. `04 - Resources/AI/Presets/servicenow.md`). Name each one.
4. `AGENTS.md` at the project root.
5. `_meta/AI-Memory.md`.
6. The most recent `_meta/AI-Sessions/<file>` (if any).

After the report, give a one-line verdict:

- **All loaded** — the auto-load chain fired correctly.
- **Partial** — list what's missing and what the likely cause is (typo in `@`-reference, file not yet created, wrong working directory, agent not auto-load-aware).
- **Nothing project-specific loaded** — the agent was launched outside the project root, or the root `CLAUDE.md` stub is missing or malformed.

If anything is missing, suggest the single most likely fix. Do not start reading files to repair the situation unless I ask — the point of this skill is diagnosis, not repair.
