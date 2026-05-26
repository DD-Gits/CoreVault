---
type: ai-memory
project:
---

# AI Working Memory

Project-scoped corrections, validated approaches, and non-obvious learnings for AI sessions. Distinct from [[Decisions/README|Decisions]] (which records *project* decisions) — this file is about *how to work with AI on this project*.

When in doubt: if it would surprise a fresh agent or save you re-explaining context, write it down here.

## How to use

- Append entries; do not rewrite history.
- Each entry: short rule, then **Why:** (what triggered it — a correction, an incident, a confirmed approach) and **How to apply:** (when/where it kicks in).
- Link related decisions, risks, or sessions with `[[…]]`.

## Corrections (do NOT do)

Things the agent kept getting wrong. Record after the correction sticks.

### Example

- **Rule:** Do not use `SomeApi.v1` — always use `v2`.
- **Why:** v1 silently drops fields on certain payloads; discovered in session 2026-04-12.
- **How to apply:** Any time generating client code or examples for this service.

## Validated approaches (DO do)

Non-obvious approaches that worked. Save these so the next agent doesn't re-derive them or be talked out of a good call.

-

## Domain quirks

Things about this codebase, data, or stakeholders that aren't documented elsewhere and would mislead a fresh agent.

-

## Promoted evaluator learnings

Patterns extracted from repeated evaluator findings. **Each entry must reference at least two distinct slices** where the same root cause appeared — single occurrences stay in their slice's Evaluation section and are not promoted here.

### Example

- **Rule:** Don't add tests against private helper functions; assert on public behaviour only.
- **Why:** Three slices had test fixes that boiled down to coupling tests to internals that later changed shape.
- **Seen in:** [[Slices/0003-user-auth]], [[Slices/0007-rate-limit]], [[Slices/0011-export-pipeline]]
- **How to apply:** When writing or reviewing tests, target the public surface; if a private helper feels test-worthy, that's a signal it should be its own module.

## Open questions for the agent

Things you want the next session to investigate or decide.

- [ ]
