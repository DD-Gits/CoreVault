---
type: reference
tags: [ai, workflow, rituals]
---

# Session Rituals

The rituals you follow when working on a vault project with Claude. Each one is here because skipping it has a specific cost — listed under **Why it matters**.

The structure of the vault (PRD, Specs, Plans, Slices, Decisions, AI-Memory, AI-Sessions) only stays useful if these rituals stay habitual. The folders by themselves do nothing.

See also: [[Vault-Guide#The session loop|Vault-Guide § The session loop]], [[CLAUDE]], [[04 - Resources/AI/Prompts/Project-Session-Kickoff]], [[04 - Resources/AI/Skills/README|Skills library]].

## At a glance

| Phase | Ritual | Frequency | Skill / Prompt |
|---|---|---|---|
| One-time per project | Scaffold `_meta/CLAUDE.md` | Once at project creation | [[04 - Resources/AI/Prompts/Project-Bootstrap]] |
| One-time per project | Author PRD | Once at project creation | [[04 - Resources/AI/Prompts/Project-Bootstrap]] |
| Session start | **Kickoff** (full / light / resume) | Every session | `/kickoff` or [[04 - Resources/AI/Prompts/Project-Session-Kickoff]] |
| Pre-work alignment | Explore options before a plan exists | When approach is unclear | `/brainstorm` |
| Pre-work alignment | Sharpen a draft plan into a slice contract | Before non-trivial code | `/grill` (Pocock by default; per-project override) |
| Pre-work alignment | Stress-test a plan you're attached to | When you suspect attachment bias | `/devils-advocate` |
| Mid-session | Append to `_meta/Tasks.md` | As work happens | n/a |
| Mid-session | Supersede `_meta/Decisions/` — never overwrite | When a decision changes | n/a |
| Mid-session | Checkpoint when context fills up | When the chat is long but the slice isn't done | `/handoff` |
| Session end | **Wrap-up** | Every session that reached closure | `/wrap-up` |
| Session end | Approve AI-Memory edits | Every session | n/a — review the agent's proposal |
| Session end | Approve new ADRs | When a decision was made | n/a — review the agent's proposal |
| Periodic | Promote repeated evaluator findings into AI-Memory | Monthly-ish | n/a |
| Periodic | Archive completed slices and stale plans | When a milestone ships | [[System/Workflows/Archive-Project|Archive-Project workflow]] |
| Periodic | `Repair-ObsidianProject.ps1` | When the vault template changes | [[System/Workflows/Repair-Project|Repair-Project workflow]] |

Bold rituals are the load-bearing two. If you only do two things, do those.

The pre-work alignment skills are *optional* and not part of the default skill set — install them per project via `New-ObsidianProject.ps1 -Skills All` or `-Skills Custom`. The bold rituals (kickoff, wrap-up) plus `/handoff` and `/new-session-log` ship by default.

---

## One-time per project

### Scaffold `_meta/CLAUDE.md`

**When.** Immediately after creating the project with `New-ObsidianProject.ps1`. The file exists but is an empty template until you do this.

**What happens.** You paste the *Scaffold `_meta/CLAUDE.md`* block from [[04 - Resources/AI/Prompts/Project-Bootstrap]]. The agent interviews you with six structured questions (summary, goal, stack, glossary, conventions, never-dos) and writes the file.

**Why it matters.** `_meta/CLAUDE.md` is the load-bearing context file that every future kickoff reads. If it's empty or vague, every session starts cold and the agent guesses at conventions. The interview format forces you to name your stack version, your glossary, and — most importantly — the never-dos *before* the agent has a chance to violate them.

**Cost of skipping.** Every future session burns the first ten minutes re-explaining what the project is and what not to do. Mistakes that an explicit "never-do" would have caught will instead get caught (at best) in review.

**Tip.** If you have a preferred grilling style for this project (Pocock interrogation, brainstorm-first, or devil's advocate), add a `Grilling style: <style>` line to `_meta/CLAUDE.md` at scaffold time. `/grill` will respect it.

### Author PRD

**When.** Right after scaffolding `CLAUDE.md`. The PRD captures *what we're building* at the business level — distinct from technical Specs.

**What happens.** Three flavours in [[04 - Resources/AI/Prompts/Project-Bootstrap]]: **Import** (you have a source doc from another tool — agent maps it to the template and flags gaps), **Build** (interview from scratch when there's no source material), **Review** (completeness/clarity check on an existing draft).

**Why it matters.** Without a PRD, "what we're building" lives implicitly across plans, specs, and your head. When the project pivots (and it will), there's no single anchor to update — you end up with `rev7-spec-contradictions.md` and a `Pivot/` folder full of parallel truths. With a PRD, the pivot is one file change plus a Decision ADR explaining why.

**Cost of skipping.** Specs and plans drift apart because there's no shared business-level anchor. Doc sprawl follows.

---

## Every session start: pick one kickoff mode

The kickoff is the most important ritual in the loop. It loads project context into the agent so the rest of the session is grounded. Pick the mode that matches the situation; never start a non-trivial session without one.

### Full kickoff (default)

**When.** Fresh session, or any session after more than a day or two away. Agent has file access (Claude Code, Cowork, AGENTS.md-aware Codex from project root).

**What happens.** Invoke `/kickoff` or paste the *Full kickoff* block from [[04 - Resources/AI/Prompts/Project-Session-Kickoff]]. The agent reads `_meta/CLAUDE.md` → `_meta/AI-Memory.md` → `_meta/README.md` → the most recent `_meta/AI-Sessions/<file>` in that order, then recaps the project, names the 2–3 most relevant constraints from CLAUDE.md / AI-Memory.md, summarises where the last session left off, lists any in-progress slices, and asks a single question: *"What should we focus on today?"*

**Crucially, the agent does not propose work yet.** It loads, recaps, waits.

**Why it matters.** Two reasons. First, the agent now knows your never-dos and recent corrections, so it won't reintroduce mistakes you already caught. Second, the recap is your sanity check — if the agent's one-paragraph summary is wrong, you find out in 30 seconds instead of after it writes 200 lines of code based on a misunderstanding.

**Cost of skipping.** The agent will gladly start working from defaults that aren't yours. Every "wait, no, we don't do it that way" you say later is a kickoff you should have run.

### Light kickoff

**When.** Same situation as full kickoff but the agent has no file access — chat-only (Claude.ai web, ChatGPT, anywhere without filesystem tools).

**What happens.** You paste the *Light kickoff* block from [[04 - Resources/AI/Prompts/Project-Session-Kickoff]], then paste `_meta/CLAUDE.md`, `_meta/AI-Memory.md`, `_meta/README.md`, and the latest session log manually. Same recap-and-wait behaviour as the full version.

**Why it matters.** Removes the convenience but not the discipline. Skipping the kickoff because you're in a chat-only tool produces the same drift as skipping it anywhere.

### Resume in-flight work

**When.** You were on this project yesterday or this morning. The full recap is overkill; you just need to pick up where you left off.

**What happens.** Paste the *Resume in-flight work* block. The agent reads only the latest `_meta/AI-Sessions/<file>` (specifically the Handoff section) and asks for go-ahead. No full project recap.

**Why it matters.** Keeps the ritual cheap when the context is already fresh. Without this mode, you'd be tempted to skip kickoff entirely on quick returns — which defeats the purpose. *Resume* gives you a low-friction alternative to skipping.

**Cost of skipping (and starting cold instead).** You re-read project context that's already in your head, costing time. Worse, you may not notice that an open question from the last session is still open, because nothing prompted you to check Handoff.

---

## Pre-work alignment (optional skills)

These fire *between* kickoff and the first line of implementation. They're optional — most work doesn't need all three, and trivial work doesn't need any. Their value is preventing the slice from being committed to before its weaknesses are visible.

Roughly: brainstorm → grill → devils-advocate. Most work uses one of them, not all three.

These skills aren't part of the default project skill set. Install them per project via `New-ObsidianProject.ps1 -Skills All`, `-Skills Custom`, or `-Skills <comma-list>`.

### `/brainstorm` — explore the option space

**When.** The goal is clear but the approach isn't. You've only considered one option and you suspect there are others worth seeing.

**What happens.** Invoke `/brainstorm`. The agent generates 3–5 meaningfully different approaches (different scopes, different positions in the stack, different timescales, different "owners," and possibly adjacent problems worth solving instead), with one-sentence cost/benefit/downside for each.

**Why it matters.** The first approach an agent (or you) thinks of is usually not the best one — it's just the most obvious one. `/brainstorm` forces you to *see* the realistic alternatives before committing. The point is not to find the optimal option; it's to commit deliberately rather than by default.

**Cost of skipping.** Premature commitment to whichever option came to mind first. The cost shows up later as "I wish we'd done it the other way" — usually too late to switch cheaply.

### `/grill` — sharpen the plan

**When.** You have a draft plan or design and you want it interrogated before writing code. Default skill for the slice-contract step.

**What happens.** Invoke `/grill`. The agent adopts an adversarial-cooperative stance (Pocock-style interrogation by default), asks pointed questions about assumptions, edge cases, and unresolved decisions, and drives the plan toward a tight contract with explicit "Done means," "Verification plan," and "Out of contract" sections.

The style can be overridden three ways: (1) the project's `_meta/CLAUDE.md` can set a `Grilling style: <pocock|brainstorm|devil>` line; (2) you can pass an explicit argument: `/grill pocock`, `/grill brainstorm`, `/grill devil`; (3) the dedicated `/brainstorm` and `/devils-advocate` skills do styles 2 and 3 standalone.

**Why it matters.** The slice contract is the agent's success criteria — strong enough to let it loop independently against without constant clarification (the *goal-driven execution* principle from [[CLAUDE#4. Goal-driven execution|coding discipline]]). "Make it work" is weak; "When `pnpm test:rls` passes and the smoke covers tenant X reading tenant Y's data and getting empty results" is strong. `/grill` is what gets you from the first to the second.

**Cost of skipping.** The agent declares victory at the wrong point — you find the gap later when something breaks in a way the slice would have caught. Out-of-scope creep, because there's no Out-of-contract section saying "this slice does NOT change RBAC."

### `/devils-advocate` — argue against the plan

**When.** You have a draft plan and you suspect you're attached to it. You want a genuine counter-position, not just sharpening.

**What happens.** Invoke `/devils-advocate`. The agent takes a purely adversarial stance and makes the strongest possible case for *not* doing the work. It argues over hidden costs, wrong abstractions, false premises, sequencing, and failure modes. The point is to demolish — if the plan survives, it survives stronger.

**Why it matters.** `/grill` interrogates to sharpen; `/devils-advocate` attacks to stress-test. Different stances, different outputs. If you can't defend the plan against the devil, it shouldn't be built yet.

**Cost of skipping.** Confirmation bias ships. You and the agent are both invested in the work happening — neither of you is reliably the person who'll talk you out of it.

---

## Mid-session rituals

These are smaller and more situational than the bookend rituals, but they're what keep a single session from becoming the next mess.

### Append to `_meta/Tasks.md` as work happens

**When.** When new work surfaces mid-session (a follow-up bug, a deferred TODO, a question to answer next time).

**What happens.** The agent (or you) adds a line to Tasks.md. Keep it short — Tasks.md is the short-horizon to-do list, not a project plan.

**Why it matters.** If it's not written down it's lost. The wrap-up ritual will pick it up and surface it in the next session's kickoff.

**Cost of skipping.** Follow-ups evaporate. You rediscover the same TODOs three sessions later, having done duplicate work in between.

### Supersede Decisions — never overwrite

**When.** A previous decision (ADR in `_meta/Decisions/`) is no longer right.

**What happens.** Write a *new* ADR file (e.g. `0007-switch-to-postgres-rls.md`) that explicitly states which prior ADR it supersedes and why. The old file stays in place.

**Why it matters.** ADRs are valuable not for the current decision (you can always read the code for that) but for the *history of decisions and why they changed*. Overwriting destroys the history. The "why we tried X and then moved to Y" trail is what stops you (and the agent) from reverting to X six months later for reasons that already failed.

**Cost of skipping.** Loss of institutional memory. The agent will helpfully suggest something you tried and abandoned, and you won't remember why you abandoned it.

### `/handoff` — checkpoint mid-work

**When.** The chat has gotten long, context is filling up, or you want a clean break — but the slice isn't done yet. Continuation, not closure.

**What happens.** Invoke `/handoff`. The agent writes a checkpoint file to `_meta/AI-Sessions/<date>-<topic-slug>-handoff.md` (suffixed `-2`, `-3` if a same-named file exists) capturing the in-progress state: what was done, what's next, what assumptions hold, what's unfinished. The next agent runs `/kickoff` in a fresh chat and picks up the handoff file as the most recent session log.

**Why it matters.** `/handoff` is explicitly *not* `/wrap-up`. Wrap-up runs the evaluator pass, proposes AI-Memory updates, flags new ADRs — closure work. Handoff does none of that because the work isn't done. Conflating the two means either you wrap up prematurely (writing a session summary for incomplete work, which pollutes future kickoffs) or you don't checkpoint at all and lose state when the chat hits a limit.

**Cost of skipping.** When context fills mid-slice and you have to start a fresh chat without `/handoff`, you reconstruct state by hand — slowly, incompletely, often with errors. Or worse, you call it done because the chat is over.

---

## Every session end: wrap-up

### `/wrap-up`

**When.** Every session that *reached closure on something*. If the work is in-progress and you're checkpointing for continuation, use `/handoff` instead (see above).

**What happens.** Invoke `/wrap-up`. The agent produces four sections without waiting for confirmation:

1. **Evaluator pass** — the agent steps out of implementer mode and adopts a skeptical reviewer stance. Findings against correctness, completeness vs the slice contract, edge cases, and code quality. A clean pass is a valid output — invented findings to look thorough are not.
2. **Session summary** — drafted directly into `_meta/AI-Sessions/<date>-<topic-slug>.md` with the standard AI Session template (goal, context read, decisions, output created, evaluator findings, follow-up actions, handoff).
3. **Proposed AI-Memory updates** — durable learnings discovered this session, formatted as additions to `_meta/AI-Memory.md`. **The agent does not write these to disk.** You review and apply.
4. **Proposed new ADRs** — any decisions that warrant their own file in `_meta/Decisions/`. Again, proposed only, not written.

**Why it matters.** This is what makes the vault *durable across sessions*. The session log is the bridge between today's work and the next kickoff. AI-Memory is the long-term correction store — without it, the same mistake gets re-corrected every project. Proposed-but-not-written for AI-Memory and ADRs is deliberate: those files are curated, and the agent has been wrong often enough that auto-writing to them would pollute them.

**Cost of skipping.** Sessions become disposable transcripts. The next kickoff has nothing recent to read. Corrections you gave the agent this session will need to be given again next session. Decisions you made vanish into chat history.

### Approve AI-Memory edits

**When.** Right after `/wrap-up` produces its proposals.

**What happens.** Read what the agent proposed. Edit if needed. Apply to `_meta/AI-Memory.md`. Be choosy — AI-Memory is high-value precisely because it's curated.

**Why it matters.** AI-Memory is the file that pays compounding dividends across sessions. Adding noise to it makes it less useful for the next kickoff. Adding signal to it makes every future session faster.

**Rule of thumb.** Add to AI-Memory only if: (a) you'd want a future agent to know this, (b) it's not already obvious from CLAUDE.md or the code, and (c) it's not session-specific trivia.

### Approve new ADRs

**When.** When `/wrap-up` proposes one.

**What happens.** Read the proposal. Decide if it's a real decision worth preserving in `_meta/Decisions/`. If yes, write it (don't let the agent — these are immutable once committed and benefit from your own framing). Number sequentially.

**Why it matters.** Decisions are the immutable record. Anything you write to `Decisions/` you're committing to keep forever. Better to write five real ADRs than fifty half-baked ones.

---

## Periodic maintenance

These aren't per-session — they're maintenance you do every few weeks, or when a trigger event happens.

### Promote repeated evaluator findings into AI-Memory

**When.** Roughly monthly, or when a session log shows the *same evaluator finding* you've seen before.

**What happens.** When the wrap-up evaluator catches the same pattern across multiple sessions ("forgot to wrap the write in `scoped()`," "added a feature flag without an ADR"), that pattern has earned a permanent home. Add it to `_meta/AI-Memory.md` in a "Promoted evaluator learnings" section.

**Why it matters.** Evaluator findings are session-specific by default. The repeated ones are signal — they're telling you about a recurring blind spot that needs to be load-bearing context, not a one-off catch.

### Archive completed slices and stale plans

**When.** When a milestone or feature ships, or when a plan is clearly dead.

**What happens.** Move shipped slices to an `_archive/` subfolder within the project, or to vault `09 - Archive/` if it's significant. See [[System/Workflows/Archive-Project|Archive-Project workflow]]. Update README to reflect.

**Why it matters.** Active folders should show active work. A `_meta/Slices/` folder with 40 files where 35 are done makes it hard to find the 5 that matter. The vault is precisely designed to absorb churn by archiving rather than by leaving everything in place.

**Cost of skipping.** The slow drift toward what the original E8-App `docs/superpowers/` became — 79 dated files with no living index.

### `Repair-ObsidianProject.ps1`

**When.** When the vault project template changes (new files added, structure updated) and you want existing projects to catch up.

**What happens.** Run [[System/Scripts/Repair-ObsidianProject.ps1|the repair script]] against the project folder. It diffs against the current template and adds missing files/folders without overwriting your content. See [[System/Workflows/Repair-Project|Repair-Project workflow]].

**Why it matters.** The vault evolves. Without `Repair-`, old projects are stuck with the template they were created from, and tooling that assumes new files won't find them.

**Skills caveat.** `Repair-ObsidianProject.ps1` adds missing template files; it does not re-import the skill set into the project's `.claude/skills/` or `.agents/skills/`. If the skill library has been updated (e.g. `/handoff` added to the default set), refresh by copying the relevant skill folders manually from `04 - Resources/AI/Skills/<skill>/` into the project's `.claude/skills/` and `.agents/skills/`, or re-run `New-ObsidianProject.ps1` against a throwaway location to see the current default set and copy across.

---

## Common failure modes

A few patterns to watch for. Each one is the negative space around a ritual.

**Starting work without kickoff.** Most common failure. Symptom: the agent suggests something you'd already ruled out, or violates a never-do, or describes the project in a way that doesn't match what you're building. Fix: stop, run `/kickoff`, retry.

**Wrap-up performed but proposals not applied.** Second most common. The agent dutifully proposes AI-Memory and ADR updates; you don't review them; the proposals die with the chat. Fix: treat the wrap-up output as a *to-do for you*, not as a finished artefact. Apply within 24 hours or it won't happen.

**Wrap-up used when handoff was the right call.** You ran `/wrap-up` on incomplete work because it was the end of the session. The result is a session summary that says "done" when nothing is. Future kickoffs read it as closure. Fix: if the slice isn't done, use `/handoff`. Save `/wrap-up` for when you've reached a real stopping point.

**Decisions written in chat, not in `Decisions/`.** "We decided to go with X" said in the session, never captured. Six weeks later nobody remembers why. Fix: at wrap-up, ask the agent to flag *every* decision-shaped statement from the session. Promote the real ones.

**Spec / plan churn (the original E8-App pattern).** New dated spec or plan generated each session, never updating or archiving old ones. Symptom: the folder grows monotonically and has no living index. Fix: before writing a new plan, ask "does this update an existing plan or supersede it?" If supersede, archive the old one. If neither, it's probably scope creep. Better: run `/grill` *before* generating a new plan and let it tell you whether you actually need one.

**AI-Memory turning into AI-journal.** Adding session-specific narrative to AI-Memory ("today we worked on X"). Symptom: the file grows but stops being scannable. Fix: AI-Memory is for *corrections and validated approaches that future agents need*, not for what happened. Session-specific narrative goes in AI-Sessions.

**Brainstorming endlessly.** `/brainstorm` is useful as a divergence step; if you keep invoking it instead of choosing, the option space gets wider and decisions don't happen. Fix: brainstorm once, then `/grill` the chosen direction. Move on.

---

## Priority if you only do some of this

If the full discipline is too much to start with, here's the descending priority:

1. **`/kickoff` at the start of every session.** Non-negotiable. The single biggest source of value in the vault.
2. **`/wrap-up` at the end of every completed session, with AI-Memory and ADR proposals actually applied within 24 hours.** Closes the loop.
3. **`/handoff` mid-session when context fills up.** Cheap to invoke, prevents state loss. Pairs with `/kickoff` in the next chat.
4. **`/grill` (or the slice contract pattern manually) for non-trivial work.** Stops the "is this done?" arguments.
5. **Supersede-don't-overwrite for Decisions.** Cheap, high-value, easy habit.
6. **Periodic archive of completed slices.** Stops sprawl.
7. **`/brainstorm` and `/devils-advocate`** when the situation specifically calls for them (unclear approach, attachment bias). Optional.

Everything else compounds these. If 1, 2, and 3 aren't habits yet, the others won't save you.
