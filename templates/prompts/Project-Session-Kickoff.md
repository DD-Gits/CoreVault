---
type: prompt
purpose: kickoff
tags: [prompt, ai, kickoff]
---

# Project session kickoff prompt

Paste-ready prompts for starting a fresh Claude / Codex / ChatGPT session on a project. They tell the agent which files to read, in what order, and what to do before asking you what to focus on.

## Full kickoff (Claude Code / Claudian / agent with file access)

Use this when the agent can read files directly from the project folder.

```
You are joining a project I'm tracking in Obsidian. Before we discuss what to do today, do the following in order — do NOT skip any step or guess at content:

1. If `_meta/CLAUDE.md` is not already in your context, read it end to end. (It is auto-loaded when Claude Code is launched at the project root and the project has a root `CLAUDE.md` stub that `@`-references `_meta/CLAUDE.md`. If you can't tell whether it's loaded, read it.) This is the load-bearing project context.
2. Read `_meta/AI-Memory.md`. Treat its "Corrections" section as hard rules. Pay attention to "Promoted evaluator learnings" — those are patterns repeated across past work.
3. Read `_meta/README.md` for status and current focus.
4. List the files in `_meta/AI-Sessions/` and read the most recent one (the last session summary).
5. Skim `_meta/Tasks.md` and the file names under `_meta/Decisions/`.
6. List the files in `_meta/Slices/`. Note any with `status: in-progress` — I may want to resume one.

Once you've done that, reply with:

- A one-paragraph recap of the project in your own words.
- The 2-3 most relevant constraints or never-dos from CLAUDE.md / AI-Memory.md.
- The state of the last session (what was open, what was decided).
- Any in-progress slices found in step 6 (filename + title), or "no in-progress slices."
- A "Context read" list — the exact files you loaded in steps 1-6, one per line. This will be copied into the session log later.
- A single question: "What should we focus on today?"

Do not propose work, code, or plans until I answer.
```

## Light kickoff (chat-only, paste files manually)

Use this when the agent can't read files — you paste the relevant context yourself.

```
I'm starting a fresh session on a project I track in Obsidian. I will paste 3 files for context:

1. CLAUDE.md (project context, conventions, never-dos)
2. AI-Memory.md (corrections and learnings from prior sessions)
3. The most recent AI session summary

After reading them, reply with:
- A one-paragraph recap.
- The top constraints or never-dos.
- A single question: "What should we focus on today?"

Do not propose work until I answer.

--- CLAUDE.md ---
<paste here>

--- AI-Memory.md ---
<paste here>

--- Last AI session summary ---
<paste here>
```

## Resume in-flight work

Use this when you were working on the project recently and just want to pick up the same thread. Skips the full project recap (you don't need it — you were here yesterday).

```
We're resuming in-flight work on this project. Do the following — keep it tight:

1. Find the most recent file in `_meta/AI-Sessions/` (sort by filename descending or modification time).
2. Read it end to end. Pay particular attention to the Handoff section (Continue from / Important context / Next recommended action).
3. If `_meta/AI-Memory.md` has been updated more recently than that session file, read AI-Memory too — there may be corrections from a session that wasn't logged separately.

Then reply with:

- One sentence: "Last session, we were [continue-from], and next we planned to [next-recommended-action]."
- Any blockers or open questions flagged in the Handoff.
- "Proceed?" — and wait for me before doing any work.

Do not propose work, code, or plans until I say go.
```

## End-of-session wrap-up

Use at the close of a session to make sure the agent leaves useful artefacts behind.

```
We're wrapping up. Before we finish, produce four sections — don't ask me to confirm first; I'll edit:

1. **Evaluator pass.** Step out of implementer mode. Adopt the stance of a skeptical reviewer who did not do this work. Walk through what was done and produce findings against: correctness, completeness vs contract (if a slice contract exists), edge cases, and code quality. For each finding: where (file/function/line/behaviour), what's wrong, why it matters. If genuinely no findings, say so — do not invent findings to look thorough. If the session worked on a specific slice, note which slice the findings belong to.

2. **Session summary** suitable for `_meta/AI-Sessions/` using the AI Session template (Date, Tool, Goal, Context read, Context provided, Summary, Decisions, Output created, Files touched, Evaluator findings, Follow-up actions, Handoff with continue-from / important-context / next-recommended-action).

3. **AI-Memory updates** for `_meta/AI-Memory.md`. Classify each as Correction / Validated approach / Domain quirk / Promoted evaluator learning. Promoted entries are only valid if the same root cause appears in this session's findings AND at least one prior slice — single-occurrence findings stay in the slice, not in AI-Memory. Each entry: short rule, **Why:**, **How to apply:**. Promoted entries also list **Seen in:** with slice references.

4. **New decisions** that warrant a new ADR file in `_meta/Decisions/`. Provide a draft filename and a one-paragraph context.

Output all four sections. If a section has nothing to capture, write the heading and "None this session" — don't skip the heading.
```

## Notes

- The full kickoff assumes the agent's working directory is the project folder (i.e. `02 - Projects/<Type>/<Project>/`). Adjust the paths if you launch the agent from the vault root.
- For Claudian sessions, point Claudian at the project folder before pasting the prompt so file paths resolve.
- If the project has no prior AI sessions, the agent will note that and proceed.
