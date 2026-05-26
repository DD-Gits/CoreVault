---
name: wrap-up
description: End-of-session capture. Performs a skeptical evaluator pass over the session's work, drafts an AI session summary suitable for _meta/AI-Sessions/, identifies durable learnings for _meta/AI-Memory.md, and flags decisions that warrant a new ADR in _meta/Decisions/. Use at the close of every session.
disable-model-invocation: true
---

We're wrapping up this session. Before we finish, produce four sections — do not ask me to confirm first; I will review and edit.

## 1. Evaluator pass

This is the **lightweight** evaluator pass — the same agent doing the implementation, stepping out of implementer mode to review the work. It's cheaper than a separate evaluator session but biased toward leniency. For high-stakes slices (data integrity, security, public APIs), the user may also run a **full** evaluator pass from a fresh session afterward; that's their call, not yours.

Step out of implementer mode. Adopt the stance of a skeptical reviewer who did not do this work and has no investment in its success. Your job is to find what's wrong, missing, or fragile — not to praise what's right.

Walk through what was done this session and produce findings against:

- **Correctness** — does it actually do what was asked? Test the assertions; don't trust the implementation's own claims.
- **Completeness vs contract** — if work was done against a Slice contract, does the result satisfy every "Done means" item? Flag any silently deferred or stubbed items.
- **Edge cases** — what inputs / states / orderings would break this? Name specific ones, don't gesture at "edge cases" abstractly.
- **Code quality** — coupling, hidden state, error handling, observability. Flag specifics, not vibes.

For each finding, give:

- Where (file, function, line, or behaviour)
- What's wrong
- Why it matters (or "minor — note only")

If genuinely no findings, say so explicitly. Do not invent findings to look thorough. A clean pass is a valid output if the work warrants it.

If this session worked on a specific slice, the findings should be added to that slice's Evaluation section after this wrap-up — note in your output which slice they belong to.

## 2. Session summary

Draft a session summary suitable for `_meta/AI-Sessions/<date>-<topic-slug>.md` using the AI Session template structure:

```
---
type: ai-session
date: <today, YYYY-MM-DD>
tool: <Claude | Codex | ChatGPT | Other>
project: <project folder name>
topic: <short topic>
tags: [ai-session]
---

# AI Session - <date> - <topic>

## Goal

## Context read

<files loaded autonomously at session start (from /kickoff), one per line>

## Context provided

<what the user supplied during the session — pasted code, docs, decisions, etc.>

## Summary

## Decisions

-

## Output created

-

## Files / notes touched

-

## Evaluator findings

<copy the findings from section 1, or "None this session">

## Follow-up actions

- [ ]

## Handoff

Continue from:

Important context:

Next recommended action:
```

Fill each section with what actually happened in this session. Be specific. The Handoff section is what a future agent will read when resuming — make it useful.

## 3. AI-Memory updates

Identify any durable learnings that belong in `_meta/AI-Memory.md`. For each, classify it as one of:

- **Correction** — something the agent got wrong; record so future sessions don't repeat it
- **Validated approach** — non-obvious approach that worked; record so future sessions don't re-derive it or get talked out of it
- **Domain quirk** — non-obvious fact about the codebase, data, or stakeholders
- **Promoted evaluator learning** — *only if* the same root cause appears in evaluator findings from this session AND at least one prior slice. Single-occurrence findings stay in the slice's Evaluation section, not here. Reference both slices explicitly.

Each entry should follow the AI-Memory format: short rule, **Why:** line, **How to apply:** line. Promoted entries additionally include **Seen in:** with slice references.

If nothing durable came out of this session, say so explicitly — don't fabricate entries.

## 4. New decisions

Flag any decisions made today that warrant a new ADR file in `_meta/Decisions/`. For each:

- Suggested filename (e.g. `0003-use-rest-over-graphql.md`)
- One-paragraph context summarising what was decided and why

Don't draft the full ADR — just the title and context. I'll create the file from `_meta/Decisions/0000-template.md`.

If no formal decisions were made, say so.

---

Output all four sections in order. If a section has nothing to capture, write the heading and "None this session" — don't skip the heading.
