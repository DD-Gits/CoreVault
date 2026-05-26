---
name: new-session-log
description: Create a fresh dated AI session log file in _meta/AI-Sessions/ using the AI Session template structure. Use at the start of a session if you want to log as you go (instead of writing the summary at the end via /wrap-up). Takes an optional topic argument.
disable-model-invocation: true
argument-hint: [topic]
---

Create a new AI session log file in `_meta/AI-Sessions/`.

Steps:

1. Determine today's date in YYYY-MM-DD format.
2. The topic is: `$ARGUMENTS`. If no topic was provided, use `session`. Otherwise, kebab-case the topic (lowercase, spaces and underscores → hyphens, strip punctuation).
3. Filename: `_meta/AI-Sessions/<date>-<topic-slug>.md`.
4. If a file with that exact filename already exists, **error out — do not overwrite**. Tell me the conflict and suggest either:
   - Adding a suffix to the topic (e.g. `<topic>-2`)
   - Using `/wrap-up` instead if I want to update the existing session log
5. Otherwise, write the file with this content:

```
---
type: ai-session
date: <date>
tool: <Claude | Codex | ChatGPT | Other>
project: <project folder name derived from current working directory>
topic: <topic, from the argument>
tags: [ai-session]
---

# AI Session - <date> - <topic>

## Goal

## Context read

## Context provided

## Summary

## Decisions

-

## Output created

-

## Files / notes touched

-

## Evaluator findings

## Follow-up actions

- [ ]

## Handoff

Continue from:

Important context:

Next recommended action:
```

Fields are intentionally left blank for me to fill in as the session progresses (other than the frontmatter which should be populated).

6. After creating the file, reply with:
   - One line: "Created `_meta/AI-Sessions/<filename>`"
   - Nothing else. Do not propose work or ask what to focus on — that's a `/kickoff` concern.
