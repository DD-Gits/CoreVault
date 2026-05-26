---
name: handoff
description: Mid-session compaction. Writes a well-formed in-progress session log to _meta/AI-Sessions/<date>-<topic>-handoff.md and produces a small continuation prompt for resuming in a fresh chat. The next agent runs /kickoff (which picks up this handoff as the most recent session log). Use when context is filling up or you want a clean break mid-work.
disable-model-invocation: true
---

The user wants to compact this session so they can continue in a fresh chat. They are NOT done with the work — they want to save state and resume later. Treat this as a mid-work checkpoint, not a closure event.

Important: this is different from `/wrap-up`.

- `/wrap-up` is closure. It runs the evaluator pass, identifies durable learnings, flags new decisions. Do NOT do any of that here.
- `/handoff` is continuation. The slice isn't done; we're saving state and resuming later.

The design is intentionally simple: the next agent will run `/kickoff` in the new chat. `/kickoff` reads `_meta/CLAUDE.md`, `_meta/AI-Memory.md`, and the most recent session log — which will be the handoff file you write here. So you don't need to duplicate project rules or steering memory into the handoff; `/kickoff` will load them. Your only job is to write a complete, accurate record of the in-progress state.

## Step 1: Write the handoff file

Write a file at `_meta/AI-Sessions/<date>-<topic-slug>-handoff.md` where `<date>` is today in `YYYY-MM-DD` and `<topic-slug>` is a kebab-cased version of the current work topic. If the user has not named the topic, derive it from the work in progress.

If a file with that exact name already exists, append `-2`, `-3`, etc. until you find a free filename. Do not overwrite.

File contents:

```
---
type: ai-session
date: <date>
tool: <Claude | Codex | ChatGPT | Other>
project: <project folder name>
topic: <short topic>
status: in-progress
tags: [ai-session, handoff]
---

# Handoff - <date> - <topic>

## Status

**In progress.** This is a mid-session checkpoint, not a completed session. The next agent should run `/kickoff` and resume from "What to do next" below.

## Goal

<One-sentence statement of what we are trying to accomplish in this slice/session.>

## What's done this session

- <Completed step 1>
- <Completed step 2>
- ...

## What's in progress

<The specific thing the next session should continue. Be precise — file paths, function names, exact state of the work. If a file was being edited and is half-done, say so.>

## What's been decided this session

<Anything settled in this session that the next agent must respect. Not durable AI-Memory material — just session-local decisions that affect the immediate work.>

## What's open

<Explicit questions or branches not yet resolved. The agent should ask the user before deciding any of these.>

## Files touched

- `<path>`: <what changed>
- ...

## What to do next

<Concrete next action for the resuming agent. As specific as possible — not "continue the slice" but "edit `src/auth.ts:42` to add the missing null check that we identified just before stopping."

If multiple actions are reasonable next steps, list them in priority order.>
```

## Step 2: Produce the continuation prompt in chat

After writing the file, also display a small continuation prompt directly in the chat so the user can copy it easily. The continuation prompt should be deliberately short — it just tells the next agent how to resume.

Format:

```
I'm continuing in-progress work on <project name>.

Please run /kickoff. The most recent session log is the handoff file
I just created — it has the current state, what to do next, and any
open questions. Read it carefully before doing anything destructive.

If anything is ambiguous, ask me before proceeding.
```

That's it. No embedded project rules, no AI-Memory subset, no CLAUDE.md excerpts. `/kickoff` loads all of that natively. Keeping the continuation prompt small makes it reliable.

## What to tell the user when done

Confirm:

1. The full path of the handoff file you wrote.
2. The continuation prompt (which they can copy-paste into the new chat).
3. A reminder that they can edit the handoff file before starting the new session if they want to add anything.

## Anti-patterns

- Don't run the evaluator pass. That's `/wrap-up`'s job. The slice isn't done; evaluating now is premature.
- Don't propose AI-Memory updates or new decisions. Those are closure activities.
- Don't embed CLAUDE.md or AI-Memory.md content in the handoff. `/kickoff` will load those naturally. Duplicating them invites drift.
- Don't write a vague "continue the work" handoff. The next agent (which might be you, six weeks from now) needs a *specific* next action. If you can't write one, the session probably isn't at a clean handoff point — consider doing one more focused step before handing off.
- Don't omit the file path when reporting to the user. They need to know where it was saved so they can edit it if needed.
