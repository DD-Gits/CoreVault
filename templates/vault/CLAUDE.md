# CLAUDE.md

This vault is used for work notes, personal notes, projects, development notes, meetings, tasks, and AI-assisted workflows.

## Main vault locations

- `00 - Inbox/` is for temporary captures and unprocessed notes.
- `01 - Calendar/` is for daily, weekly, monthly, and review notes.
- `02 - Projects/` is for active work and personal projects.
- `03 - Areas/` is for ongoing responsibilities and long-term areas of ownership.
- `04 - Resources/` is for reusable reference material and technical notes.
- `05 - Tasks/` is for cross-project task tracking.
- `06 - Meetings/` is for meeting notes not tied to a single project.
- `07 - Messaging/` is for email drafts, stakeholder updates, and message templates.
- `08 - Development/` is for scripts, snippets, experiments, and development logs.
- `09 - Archive/` is for inactive or completed material.
- `System/` is for templates, dashboards, attachments, and vault mechanics.

## Template locations

- Note templates live in `System/Templates/Notes/`.
- Project templates live in `System/Templates/Projects/Work/` and `System/Templates/Projects/Personal/`.

## Link conventions

Every project under `02 - Projects/` has files with the same names (`README.md`, `PRD.md`, `CLAUDE.md`, etc.). Obsidian's default link resolution ("shortest path when possible") picks one when you write `[[PRD]]` — usually fine *within* a project, unreliable across projects.

- **Inside a project:** plain wiki-links like `[[PRD]]` or `[[Decisions/README|Decisions index]]` resolve to files in the same `_meta/` folder. This is intended.
- **Across projects:** always use a path-qualified link, e.g. `[[02 - Projects/Work/Other-Project/_meta/PRD|Other project PRD]]`.
- **Required setting:** Settings → Files and Links → **New link format = "Relative path to file"**. `Create-ObsidianAiVault.ps1` writes this to `.obsidian/app.json` for new vaults; verify or set manually for older ones. This makes new links resolve relative to the current note, eliminating cross-project ambiguity.

## Project folder layout

Each project under `02 - Projects/Work/<Project>/` or `02 - Projects/Personal/<Project>/` is structured as a (potential) git repo:

- Project root is the **repo root**. Code, configs, and anything the repo itself owns live here.
- `_meta/` holds **Obsidian-managed notes** (`README.md`, `CLAUDE.md`, `AI-Memory.md`, `PRD.md`, `Decisions/`, etc.).
- `.gitignore` at project root excludes `_meta/AI-Sessions/` and `_meta/Meetings/` by default (sensitive working notes).

For projects with no code, the root may be empty and only `_meta/` is used.

## Coding discipline

Behavioural guidelines to reduce common LLM coding mistakes. These apply during all coding work in this vault, on top of any project-specific rules in the project's `_meta/CLAUDE.md`.

**Precedence:** If a project's `_meta/CLAUDE.md` conflicts with these global rules, the project-specific rules take priority. Project-level instructions are scoped intentionally; this file is the default behaviour for everything the project doesn't override.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks (typo fixes, obvious one-liners), use judgment — not every change needs the full rigor.

*Adapted from the [Karpathy-inspired Claude guidelines](https://github.com/multica-ai/andrej-karpathy-skills), which distil Andrej Karpathy's observations on LLM coding pitfalls into four principles.*

### 1. Think before coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity first

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: *"Would a senior engineer say this is overcomplicated?"* If yes, simplify.

### 3. Surgical changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.

When your changes create orphans:

- Remove imports/variables/functions that *your* changes made unused.
- Don't remove pre-existing dead code unless asked.
- "Unused by the codebase" doesn't mean "unused" — config files, dotfile directories (`.claude/`, `.agents/`), documentation, and metadata files (`AGENTS.md`, `_meta/*`) are read by tooling, humans, or other agents rather than by the code. Never delete files outside the explicit scope of the user's request.

**The test:** every changed line should trace directly to the user's request.

### 4. Goal-driven execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:

- *"Add validation"* → *"Write tests for invalid inputs, then make them pass."*
- *"Fix the bug"* → *"Write a test that reproduces it, then make it pass."*
- *"Refactor X"* → *"Ensure tests pass before and after."*

For multi-step tasks, state a brief plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria (*"make it work"*) require constant clarification.

### Interaction with the project workflow

For complex projects this vault uses Slices with explicit **Contract** sections (Done means / Verification plan / Out of contract). The contract is the project-specific instantiation of *"think before coding"* and *"goal-driven execution"*: it forces externally-observable success criteria before any code is written. Treat the contract as authoritative when one exists. For simple no-slice work (one-off scripts, small fixes), apply the four principles directly.

The end-of-session `/wrap-up` evaluator pass also leans on these principles — particularly *"surgical changes"* (was every change necessary?) and *"simplicity first"* (could this be smaller?). Expect evaluator findings that reference them.

## How to work with projects

When helping with a project, all paths below are relative to the project root unless noted.

### Project setup (one-time per project)

Right after creating a project via `New-ObsidianProject.ps1`, the `_meta/CLAUDE.md` and `_meta/PRD.md` files are empty templates. Use the **Bootstrap prompts** at [[04 - Resources/AI/Prompts/Project-Bootstrap]] to fill them in — agent-agnostic, interview-style. Four blocks:

- **Scaffold `_meta/CLAUDE.md`** — interview-style; agent asks 6 structured questions (summary, goal, stack, glossary, conventions, never-dos) and writes the file.
- **Author PRD — Import** — paste source content from another tool; agent maps it to the PRD template and flags gaps.
- **Author PRD — Build** — interview from scratch when there's no source material.
- **Author PRD — Review** — structured completeness/clarity check on an existing draft.

Run these *once* per project. Move to Session start modes (below) for every working session afterwards.

### Session start modes

The steps below describe a **full kickoff** — read everything before doing anything. That's the right mode for a fresh session or after a long break. Three other modes exist; the canonical prompts for each live in [[04 - Resources/AI/Prompts/Project-Session-Kickoff]]:

- **Full kickoff** — agent has file access; reads `_meta/CLAUDE.md` → `AI-Memory.md` → `README.md` → latest `AI-Sessions/<file>` before proposing anything.
- **Light kickoff** — chat-only agent; you paste those three files manually.
- **Resume in-flight work** — you were here recently; agent only reads the latest `AI-Sessions/<file>` Handoff section and asks for go-ahead. Skips the full project recap.
- **End-of-session wrap-up** — writes the session summary directly to `_meta/AI-Sessions/<date>-<topic>.md` (don't leave it as chat-only text). Proposes AI-Memory updates and any new ADRs for your review — those are durable and curated, so the agent shouldn't write them to disk without your confirmation.

If you don't paste one of those prompts, default to the full-kickoff flow described next.

### Skills (invocable alternative to prompts)

If the project has helper skills imported (default for new projects via `New-ObsidianProject.ps1 -Skills Default`), the same workflows are available as slash commands:

- `/kickoff` — full session kickoff
- `/wrap-up` — end-of-session capture
- `/handoff` — mid-session context save before continuing in a fresh chat
- `/new-session-log [topic]` — create a dated session log

Skills are the invocable counterpart of the paste-able prompts above — same behaviour, different ergonomics. They live at `.claude/skills/` (Claude Code) and `.agents/skills/` (Codex and others). Both are gitignored by default since they're personal workflow helpers, not project deliverables. See [[04 - Resources/AI/Skills/README|the skill library]] for details.

### Full-kickoff flow

1. Read `_meta/CLAUDE.md` first — it's the load-bearing context file.
2. Read `_meta/README.md` for status and outcome.
3. Check `_meta/AI-Memory.md` for prior corrections, validated approaches, and domain quirks.
4. Check `_meta/PRD.md`, `_meta/Tasks.md`, and `_meta/Decisions/` as needed.
5. Check `_meta/AI-Sessions/` for previous Claude/Codex work.
6. Add useful session summaries to `_meta/AI-Sessions/` when finishing.
7. Append durable learnings to `_meta/AI-Memory.md` (not session-specific — only things future agents need).
8. Do not overwrite decisions; supersede them with a new ADR file in `_meta/Decisions/`.
9. Prefer clear Markdown notes that are useful for future handover.
10. If the project root also contains code, treat the repo's own `README.md` / `CLAUDE.md` at root as separate audiences (repo users) from the `_meta/` versions (project owner / AI agents).

## Preferred working style

These are project-specific preferences layered on top of the coding-discipline principles above.

- Be practical and implementation-focused.
- Prefer clear explanations and maintainable structure.
- Use descriptive variable names.
- Prefer early returns.
- Keep helper functions grouped clearly.
- Preserve useful existing comments where possible.
- Highlight assumptions and risks.
- Separate requirements, options, decisions, and implementation notes.

## Useful project files

Most serious projects should include (paths relative to project root):

- `.gitignore` — at project root; excludes sensitive notes and dev cruft
- `_meta/README.md` — project overview, status, and links (YAML frontmatter for dashboards)
- `_meta/CLAUDE.md` — load-bearing AI context: stack, conventions, glossary, never-dos. **Not** auto-loaded by Claude Code (which only auto-loads `CLAUDE.md` at the working directory or its parents); read explicitly by the `/kickoff` skill, by AGENTS.md-aware agents that follow the pointer, or by running Claude Code from inside `_meta/`.
- `AGENTS.md` (at project root, **not** under `_meta/`) — pointer file with relative paths into `_meta/`, auto-loaded by Codex and other AGENTS.md-aware agents when launched from the project root
- `_meta/AI-Memory.md` — corrections, validated approaches, and non-obvious learnings discovered while working with AI on this project
- `_meta/PRD.md` — what we're building (business-level)
- `_meta/Scope.md`
- `_meta/Tasks.md`
- `_meta/Handover.md`
- `_meta/Decisions/` — one ADR-style file per decision; immutable, superseded by new files
- `_meta/Risks-Issues/` — one file per risk or issue; updated in place
- `_meta/Plans/` — implementation plans; how we'll build it, in phases/slices. Plans evolve (draft → accepted → in-progress → complete) or are superseded
- `_meta/Slices/` — vertical implementation slices with per-environment deployment tracking (dev/test/staging/prod)
- `_meta/Specs/` — technical specifications: architecture, data model, API contracts; sits between PRD and code
- `_meta/References/` — mockups, screenshots, examples, related-system docs you'll look up repeatedly
- `_meta/AI-Sessions/` (gitignored by default)
- `_meta/Meetings/` (gitignored by default)

### How Plans / Slices / Specs / Decisions relate

- **PRD** = what (business requirements). **Scope** = boundaries.
- **Decisions** = why (immutable rationale for non-obvious choices).
- **Specs** = how it works (technical contracts: architecture, data, APIs). Constrained by decisions.
- **Plans** = how we'll build it (approach, phases). May reference specs.
- **Slices** = units of implementation that roll up to plans. Each slice tracks deployment status per environment.
- **Tasks** = short-horizon to-do list. Often unpacked from the active slice.

## AI handoff pattern

When finishing a session, capture:

- What changed
- What was decided
- Open questions
- Next recommended action
- Files or notes touched
