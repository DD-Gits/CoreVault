---
name: kickoff
description: Start a fresh session on this project. Reads the project's _meta/CLAUDE.md (if not already auto-loaded), _meta/AI-Memory.md, _meta/README.md, and most recent _meta/AI-Sessions/<file>, then recaps and asks what to focus on. Use at the start of every session, except when resuming in-flight work (use /resume for that).
disable-model-invocation: true
---

You are starting a fresh session on a project tracked in Obsidian. Before discussing anything, do the following in order — do NOT skip any step or guess at content:

1. If `_meta/CLAUDE.md` is not already in your context, read it end to end. (It is auto-loaded when Claude Code is launched at the project root and the project has a root `CLAUDE.md` stub that `@`-references `_meta/CLAUDE.md`. If you can't tell whether it's loaded, read it.) This is the load-bearing project context.
2. Read `_meta/AI-Memory.md`. Treat its "Corrections" section as hard rules. Pay attention to "Promoted evaluator learnings" — those are patterns repeated across past work.
3. Read `_meta/README.md` for status and current focus.
4. List the files in `_meta/AI-Sessions/`. If any exist, read the most recent one (sort by filename descending or by modification time).
5. Skim `_meta/Tasks.md` and the file names under `_meta/Decisions/`.
6. List the files in `_meta/Slices/`. If any are in `status: in-progress`, note them — the user may want to resume one.

Once you've done that, reply with:

- A one-paragraph recap of the project in your own words.
- The 2-3 most relevant constraints or never-dos from CLAUDE.md / AI-Memory.md.
- The state of the last session (what was open, what was decided). If there are no prior sessions, say so.
- Any in-progress slices found in step 6 (filename + title), or "no in-progress slices."
- A "Context read" list — the exact files you loaded in steps 1-6, one per line. This will be copied into the session log later via `/wrap-up`.
- A single question: "What should we focus on today?"

Do not propose work, code, or plans until I answer.
