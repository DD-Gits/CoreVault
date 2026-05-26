---
type: slice
project:
plan:                       # NNNN-parent-plan
status: planning            # planning | in-progress | blocked | complete | abandoned
priority:                   # low | medium | high
opened:
closed:
deploy_dev: not-deployed       # not-deployed | deployed | rolled-back
deploy_test: not-deployed
deploy_staging: not-deployed
deploy_prod: not-deployed
deploy_history: []          # list of "YYYY-MM-DD <env>: <note>" strings
tags: [slice]
---

# NNNN — Slice title

## Goal

What this slice delivers end-to-end. Should be demonstrable as a single change set.

## Scope

### In

-

### Out

-

## Files / areas touched

-

## Contract

Negotiated before any code is written. The generator proposes; the evaluator (or you) reviews. Iterate until both agree this is the right scope and verifiable.

### Done means

Specific, externally observable behaviour. Not "implement X" but "the user can do X and Y happens." If you cannot describe done without referring to internal implementation, refine until you can.

-

### Verification plan

How "done" will be checked. Concrete enough that someone other than the implementer could run through it.

-

### Out of contract

Things explicitly *not* in scope for this slice, that a reviewer might otherwise expect.

-

## Acceptance criteria

- [ ]
- [ ]

## Test plan

- [ ] Unit / component
- [ ] Integration
- [ ] Manual / smoke
- [ ] Regression for related slices

## Evaluation

Filled in by an evaluator pass (skeptical review) before the slice is closed. There are two valid forms of evaluator pass — the goal is the same, the rigour differs:

- **Lightweight (default):** the implementing agent runs the evaluator pass from `/wrap-up`, explicitly stepping out of implementer mode. Cheap, runs every session. Catches obvious issues but biased toward leniency.
- **Full (preferred for high-stakes slices):** a fresh agent / context with no investment in the work — the implementer hands over the slice and code, the evaluator reviews and reports back. Slower, but the bias toward leniency goes away.

Use lightweight by default; promote to a full evaluator pass when the slice touches anything load-bearing (data integrity, security, public APIs, anything where shipping broken is expensive).

### Evaluator findings

Concrete issues found, with enough detail to act on. Each finding should reference a specific file, line, or behaviour — not "looks off."

-

### Resolution notes

What was done about each finding. Fixed, deferred (link follow-up slice), accepted (with rationale), or disputed.

-

### Promote to AI-Memory?

A finding is promoted only if the same root cause appears in **two or more distinct slices**. Single occurrences stay local.

- [ ] No — single occurrence or slice-specific
- [ ] Yes — pattern seen in: [[../Slices/NNNN-other-slice]], [[../Slices/NNNN-another-slice]]
- [ ] Yes — proposed rule for AI-Memory:

## Deployment plan

Environments and the order to promote through. Note any environment-specific config, feature flags, or migrations.

- **Dev:**
- **Test:**
- **Staging:**
- **Prod:**

## Deployment history

| Date | Environment | Outcome | Notes |
|------|-------------|---------|-------|
|      |             |         |       |

## Risks

-

## Tasks

- [ ]

## Links

- Plan: [[../Plans/NNNN-parent-plan]]
- Related slices:
- Related decisions:
- Related specs:
- PRD section:
