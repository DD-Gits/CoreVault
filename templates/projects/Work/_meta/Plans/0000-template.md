---
type: plan
project:
status: draft        # draft | accepted | in-progress | complete | superseded | abandoned
date:
supersedes:
superseded_by:
related_slices: []
related_specs: []
related_decisions: []
tags: [plan]
---

# NNNN — Plan title

## Goal

What this plan delivers, in one paragraph. The outcome someone could verify.

## Context

What's the situation prompting this plan? Why now? Link the PRD section, related decisions, or the spec it implements.

## Approach

High-level approach, not file-by-file detail. Why this approach over alternatives (cross-reference [[../Decisions/README|Decisions]] if a formal ADR exists).

## Phases / slices

Break the plan into vertical slices that can each be implemented and tested independently. Each slice should get its own file in `../Slices/` once accepted.

1. **NNNN — <title>** — one-line description, dependencies, rough size.
2. **NNNN — <title>** — …
3. **NNNN — <title>** — …

## Out of scope

What this plan does *not* cover. Future plans or follow-ups.

-

## Risks and unknowns

-

## Open questions

-

## Links

- PRD: [[../PRD]]
- Specs:
- Decisions:
- Parent plan (if this supersedes one):
