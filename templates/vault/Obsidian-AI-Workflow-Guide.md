**Obsidian + AI Assistant**

A Workflow Guide

*Using Obsidian as the persistent context plane*

*for AI-assisted software development*

# Contents

| Section                                             | Page |
| ------------------------------------------------------- | -------- |
| **What this is, and why it exists**                     | 3        |
| **Obsidian vault structure (high level)**               | 4        |
| **The agent context model**                             | 7        |
| **Using it: simple projects**                           | 10       |
| **Using it: complex projects**                          | 12       |
| **The evaluator loop**                                  | 14       |
| **How this fits with plugins, skills, and other tools** | 16       |
| **Operating discipline**                                | 20       |
| **A few things worth knowing**                          | 22       |

# What this is, and why it exists

AI-assisted development has a recurring problem: every new chat is a fresh start. The agent doesn't remember the project. You re-explain the conventions. You re-correct the same mistakes. You re-derive the same approaches. The decisions and learnings from prior sessions live in chat transcripts that nobody reads.

This system treats that problem as one of structure rather than memory. The agents stay stateless and ephemeral. The project becomes the durable entity. Obsidian holds the project's notes, decisions, history, and steering rules as plain markdown files; an AI session is just a process that enters the project, reads the relevant files, does work, writes back what it learned, and leaves.

The result is a workflow that is stateful (because the project files persist), repeatable (because every session follows the same kickoff and wrap-up protocol), and auditable (because every session leaves a written record). Across multiple agents — Claude, Codex, Cursor, ChatGPT — the same project context applies, because the files are read by any agent willing to look at them.

## The problems it solves

Specifically, this approach addresses several common failure modes of AI-assisted development:

  - **Context reset:** every new chat forgets the project. Solved by writing durable context into files that every session reads at startup.

  - **Instruction drift:** agents follow slightly different rules each session. Solved by a single CLAUDE.md per project that defines conventions, glossary, and never-dos.

  - **Repeated corrections:** you keep telling the agent the same project-specific gotchas. Solved by AI-Memory.md, which curates corrections as durable steering rules.

  - **Lost rationale:** decisions get buried in chat or never recorded. Solved by an ADR-style Decisions/ folder, one immutable file per decision.

  - **Poor handoff:** future-you or another agent cannot tell what happened last session. Solved by structured session summaries with explicit Handoff sections.

  - **Multi-agent inconsistency:** Claude, Codex, Cursor each need their own context. Solved by AGENTS.md (an emerging cross-tool standard) that points all of them at the same project files.

  - **Repo/notes split:** code lives in git while project thinking lives elsewhere, disconnected. Solved by placing _meta/ inside the repo, so working context lives alongside the code it informs.

## What it is not

It is not a replacement for git, for issue trackers, or for team-level documentation. It is project-scoped, user-scoped working memory — designed to keep one person (and the agents they work with) coherent over time. If multiple people need to share project state, that state lives in code, in tickets, in shared docs. The vault is the layer underneath those tools, not on top of them.

It is also not a substitute for thinking. The files are scaffolding for human judgement, not a replacement for it. The protocol exists so the agent has somewhere to read from and write to; what gets read and what gets written still depend on the person driving the work.

# Obsidian vault structure (high level)

The vault follows a numbered top-level layout — a lightly modified PARA structure — so navigation is consistent and Dataview queries can rely on stable paths. Only the folders relevant to the AI workflow are described here in detail; the rest are conventional Obsidian organisation.

## Top-level folders

| Folder           | Purpose                                                                                                                               |
| -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| **00 - Inbox**       | Quick captures waiting to be sorted. Triage zone, not long-term storage.                                                                  |
| **01 - Calendar**    | Daily, weekly, monthly notes and reviews. Time-based, not topic-based.                                                                    |
| **02 - Projects**    | Active projects with outcomes and deadlines. Each project is also a (potential) git repo. This is where the AI workflow happens.          |
| **03 - Areas**       | Ongoing responsibilities with no fixed end date.                                                                                          |
| **04 - Resources**   | Reusable reference material, technical docs, and — importantly — the AI prompt library and skill library that get imported into projects. |
| **05 - Tasks**       | Cross-project task lists.                                                                                                                 |
| **06 - Meetings**    | Meeting notes.                                                                                                                            |
| **07 - Messaging**   | Email drafts, Slack/Teams messages, stakeholder updates.                                                                                  |
| **08 - Development** | Cross-project scripts, snippets, experiments — not tied to a specific project.                                                            |
| **09 - Archive**     | Completed projects, retired resources.                                                                                                    |
| **System**           | Vault scaffolding: templates, scripts, dashboards, workflows. The PowerShell scripts that create and repair projects live here.           |

## Inside a project

Each project under 02 - Projects/<Type>/<ProjectName>/ is structured to be both an Obsidian project node and a (potential) git repo. The layout is identical for Work and Personal projects:

<Project>/ ← git repo root

.gitignore

AGENTS.md ← auto-discovery for Codex / AGENTS.md-aware agents

README.md ← repo-facing stub (only in Init mode)

<code, configs, src/, etc.>

_meta/ ← Obsidian-managed working notes

README.md, CLAUDE.md, AI-Memory.md, PRD.md, Scope.md, Tasks.md

Decisions/, Risks-Issues/, Plans/, Slices/, Specs/, References/

AI-Sessions/, Meetings/, Assets/, Development/

The split is deliberate. The project root is the repo root: code, configs, anything a developer working purely in the code would expect. The _meta/ folder is the working-context overlay: Obsidian notes, AI session summaries, project decisions, plans. Both live in the same folder; .gitignore decides what gets committed and what stays local.

## The _meta/ folder in detail

This is the load-bearing structure for AI-assisted work. Each file has a specific job:

| File / folder                   | Job                                                                                                                              |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| **CLAUDE.md**                       | Project-specific AI context: stack, conventions, glossary, never-dos. Read by every kickoff. The single file you'd hand a new agent. |
| **AI-Memory.md**                    | Durable steering memory. Corrections, validated approaches, domain quirks, promoted evaluator learnings. Append-only.                |
| **AI-Sessions/**                    | Episodic memory. One file per session, written at wrap-up. Includes the Handoff section the next session reads.                      |
| **Decisions/**                      | ADR-style records, one immutable file per decision. Superseded by new files, never overwritten.                                      |
| **Risks-Issues/**                   | One file per risk or issue, updated in place.                                                                                        |
| **PRD.md**                          | Product Requirements Document — the business-level what-we're-building.                                                              |
| **Plans/**                          | Implementation plans — how we'll build it, decomposed into phases or slices.                                                         |
| **Slices/**                         | Vertical slices of work, each with contract, evaluation, and per-environment deployment tracking.                                    |
| **Specs/**                          | Technical specs — architecture, data models, API contracts.                                                                          |
| **References/**                     | Mockups, screenshots, examples, related-system docs.                                                                                 |
| **Scope.md, Tasks.md, Handover.md** | Lightweight working files.                                                                                                           |

## The crucial split: durable vs episodic memory

Two of those files solve different problems and must not be confused:

  - **AI-Memory.md** is *durable*. It records corrections, validated approaches, and rules that should change *future agent behaviour*. It's curated. It stays small. A single entry might survive for the life of the project.

  - **AI-Sessions/<date>.md** is *episodic*. It records what happened in one specific session, what was decided, what was left unfinished. Sessions accumulate; old ones don't need to stay relevant.

Conflating these is the most common failure mode in AI-memory systems. AI-Memory should not become a transcript; sessions should not become rules. The promotion path from session findings to AI-Memory rules is deliberate and gated (more on this below).

# The agent context model

Multiple agents need to share the same project context: Claude in claude.ai, Claude Code on a terminal, Codex CLI, Cursor, ChatGPT. Each has different conventions for where it looks at startup. This system handles all of them with a small set of pointer files.

## The pointer files

| File                              | Role                                                                                                                                                                       |
| ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Vault-root CLAUDE.md**              | Global conventions: PARA layout, working-style preferences, never-dos that apply across all projects. Auto-loaded by Claude Code when it starts at or below the vault root.    |
| **Vault-root CODEX.md**               | Same role as the above, for Codex-style agents. Cross-project conventions only.                                                                                                |
| **AGENTS.md (project root)**          | Auto-discovery pointer file. Codex and other AGENTS.md-aware agents read it when launched at the project root. Points at ./_meta/CLAUDE.md.                                   |
| **_meta/CLAUDE.md (per project)**    | Project-specific AI context. NOT auto-loaded — read explicitly via /kickoff, by AGENTS.md-aware agents that follow the pointer, or by running Claude Code from inside _meta/. |
| **_meta/AI-Memory.md (per project)** | Project-specific steering rules. Read by /kickoff.                                                                                                                             |

The important distinction: vault-root CLAUDE.md and CODEX.md are auto-loaded by tools that look at the working directory and its parents. Project-level _meta/CLAUDE.md is one level deeper and is NOT auto-loaded — it has to be read deliberately. The /kickoff skill exists to ensure that read happens consistently at the start of every project session.

## AGENTS.md as the cross-tool bridge

AGENTS.md is an emerging open standard for AI agent context discovery. Tools that support it look for an AGENTS.md in the working directory at startup and read it as a pointer to the substantive project context.

In this system, every project's AGENTS.md sits at the project root (not under _meta/) and contains relative paths into _meta/: it tells the agent to read _meta/CLAUDE.md, _meta/AI-Memory.md, _meta/README.md, _meta/PRD.md, and the most recent session log, in that order. Any AGENTS.md-aware agent gets the same context as a Claude session using /kickoff — without needing to know about this system at all.

This matters because it future-proofs the workflow. New tools that adopt the AGENTS.md convention slot in automatically. The vault doesn't have to be customised per-tool; the standard is the customisation surface.

## Coding discipline (the Karpathy principles)

Vault-root CLAUDE.md includes a "Coding discipline" section that codifies four principles for LLM-assisted coding: think before coding, simplicity first, surgical changes, goal-driven execution. These are adapted from Andrej Karpathy's observations on LLM coding pitfalls and apply during all coding work in the vault.

These principles operate at a different layer from the workflow skills. The skills (kickoff, wrap-up, etc.) tell the agent how to behave at specific moments. The coding discipline tells the agent how to behave during the work itself — between kickoff and wrap-up, while it's writing or editing code.

The four principles, briefly:

  - **Think before coding.** State assumptions explicitly, ask when uncertain, surface trade-offs, push back on overcomplicated approaches. Don't pretend to know what you don't.

  - **Simplicity first.** Minimum code that solves the problem; no speculative abstraction, no flexibility for hypothetical future needs, no error handling for impossible scenarios. "Would a senior engineer say this is overcomplicated?" is the test.

  - **Surgical changes.** Touch only what's necessary. Don't "improve" adjacent code, don't refactor what isn't broken, don't delete files just because they aren't referenced by code (config files, dotfile directories, AGENTS.md, _meta/\* are all valid but invisible to a purely code-centric view).

  - **Goal-driven execution.** Transform tasks into verifiable goals. "Add validation" becomes "write tests for invalid inputs, then make them pass." Strong success criteria let the agent loop independently; weak criteria force constant clarification.

### Precedence: vault-root vs project-level

Vault-root CLAUDE.md is the default discipline that applies everywhere. Project-level _meta/CLAUDE.md can override it — for example, a project might relax "simplicity first" because it requires deliberate logging or audit instrumentation that the global rule would discourage.

The precedence is explicit: if a project's _meta/CLAUDE.md conflicts with the vault-root rules, the project-level rules take priority. This is the same pattern the system uses for the grilling style — the global default is overridable per-project so each project can encode its own constraints without fighting the system.

### How discipline interacts with the workflow

Coding discipline isn't separate from the slice / contract / evaluator workflow — it's the substrate the workflow operates on. The connections:

  - **Think before coding** is what the Contract step of a slice forces. Writing "Done means" before any code is exactly this principle made concrete.

  - **Simplicity first** is what the evaluator pass at /wrap-up checks for. "Could this be smaller?" is one of the most common evaluator findings.

  - **Surgical changes** is enforced by the slice's Scope section (In / Out / Files touched). If a change isn't in the slice, it shouldn't happen — discipline at design time prevents drift at implementation time.

  - **Goal-driven execution** is what the slice's Verification plan operationalises. Strong success criteria are the difference between a useful contract and a vague one.

For simple work that doesn't warrant a slice, the principles apply directly without that scaffolding. They're the always-on guidance; the slice structure makes them externally visible and reviewable on bigger work.

# Using it: simple projects

For a small piece of work — a script, a bug fix, a one-off utility — the workflow is intentionally light. Three steps, with everything else inferred.

## Step 1: Create the project

Run the project creation script from inside the vault:

cd <vault>\System\Scripts

.\New-ObsidianProject.ps1 (PowerShell, Windows-native)

python new_project.py (Python, works anywhere)

Answer the prompts: project name, type (Work / Personal), repo mode (None / Init / Clone), and a few metadata fields. The script creates the project folder under 02 - Projects/<Type>/<Name>/, scaffolds _meta/ from the template, places AGENTS.md at the project root, optionally initialises or clones a git repo, and imports the standard helper skills (/kickoff, /wrap-up, /new-session-log, /handoff) into .claude/skills/ and .agents/skills/.

For a quick script that doesn't need git tracking, RepoMode None is fine. The .gitignore is still placed at the root in case you later run git init.

## Step 2: Optional — bootstrap the project

For very small work you can skip this. For anything you might come back to, take five minutes to fill in _meta/CLAUDE.md and _meta/PRD.md. The Project-Bootstrap prompts in 04 - Resources/AI/Prompts/ are interview-style and walk you through it.

What goes in CLAUDE.md: stack, conventions, glossary, never-dos. Forty lines, not two hundred. The instinct is to over-document; resist it. A short, focused CLAUDE.md gets read; a long one gets skimmed.

What goes in PRD.md: what we're building and why, in business terms. The technical how lives in Specs/ and Plans/ if needed.

## Step 3: Work the session loop

Open Claude Code (or your AI tool of choice) pointed at the project folder, then:

1.  /kickoff — agent reads the project context and reports back what it loaded, what the last session was, and what's in progress. Asks: "What should we focus on today?"

2.  **Describe the work.** The agent does it. Iterate normally.

3.  /wrap-up — agent runs a skeptical-reviewer evaluator pass on its own work, writes a session summary to disk, identifies durable learnings for AI-Memory, and flags any decisions worth an ADR.

That's the full loop. For genuinely small work — a single script, a typo fix — this is all you ever need. The session summary goes into _meta/AI-Sessions/, so next time you (or another agent) opens the project, /kickoff loads it and the context survives.

**Mid-session continuation.** If a session is running long and you need to start a fresh chat without losing state, invoke /handoff instead of /wrap-up. The agent writes an in-progress session log to _meta/AI-Sessions/, marked as in-progress and including a "What to do next" section. The next agent runs /kickoff in the new chat and picks up the handoff naturally as the most recent session log. Distinct from /wrap-up: no evaluator pass, no AI-Memory promotion, because the slice isn't done.

## An example: building a one-off PowerShell script

A real first-test session in this workflow went like this. The user asked for a script that listed running processes with CPU, memory, and ports. The agent:

  - Wrote the script as a single file at the project root

  - Ran inline smoke tests on the underlying cmdlets (the sandbox blocked direct .ps1 execution, so this was the fallback)

  - On /wrap-up, produced six concrete evaluator findings against its own work — including subtle issues like the UDP-endpoint conceptual bug and divide-by-zero in the parameter validation

  - Correctly declined to promote anything to AI-Memory (single occurrence, not a pattern)

  - Correctly declined to draft an ADR (implementation defaults, not load-bearing decisions)

Total time: about three minutes of agent work plus the wrap-up. The session log contains the findings as follow-up actions, so if someone modifies the script later, the known weaknesses are already documented.

# Using it: complex projects

For multi-component builds, longer projects, or anything where individual pieces of work need their own scope and verification, the system has additional structure. The light loop above still applies; complex projects layer more on top of it.

## The full structure for complex work

A complex project uses three additional layers beyond the simple loop:

### Plans: how we'll build it

A Plan in _meta/Plans/NNNN-<name>.md describes the approach for a meaningful piece of work — usually a phase, a feature, or a coherent body of work. It captures the strategy, the decomposition into slices, dependencies, and how it ladders up to the PRD. Plans evolve through statuses (draft → accepted → in-progress → complete) or are superseded by newer plans.

A small project might have zero plans (work goes straight to slices). A complex project might have one plan per major feature.

### Slices: vertical units of work

A Slice in _meta/Slices/NNNN-<name>.md is a deliverable, demonstrable unit. Each slice has a goal, scope, files-touched list, contract, acceptance criteria, test plan, evaluation, deployment tracking, and links to parent plan and related decisions.

The crucial structural piece in a slice is the Contract section: a negotiated agreement between the implementer and the reviewer about what "done" looks like for this slice, before any code is written. The contract has three parts:

  - **Done means:** specific, externally observable behaviour. Not "implement X" but "the user can do X and Y happens."

  - **Verification plan:** how "done" will actually be checked. Concrete enough that someone else could run through it.

  - **Out of contract:** things explicitly not in scope for this slice, that a reviewer might otherwise expect.

The contract step prevents the most common failure in agentic implementation: the agent writes code that technically responds to the prompt but doesn't actually do what was needed. By forcing externally-observable "done" criteria up front, the contract makes the divergence visible at the design step rather than discovery at the wrap-up step.

### Evaluation: the slice's quality-control record

After implementation, the slice's Evaluation section records the evaluator pass findings, what was done about each finding (resolution notes), and whether any of those findings should be promoted to AI-Memory as a project-wide rule. See "The evaluator loop" section below for the full mechanism.

## The complex-project session loop

Sessions still open with /kickoff and close with /wrap-up, but the work in between has more structure:

1.  /kickoff — same as simple. Agent loads context, reports state, notes any in-progress slices.

2.  **Pick a slice.** Either continue an in-progress one or create a new one from the slice template.

3.  **Negotiate the contract.** Have the agent propose the "Done means" and verification plan. Iterate until both of you agree it's the right scope and is verifiable. This is the design conversation; it's much cheaper here than after code is written.

4.  **Implement.** The agent writes the code against the contract.

5.  /wrap-up — the evaluator pass now has a contract to verify against, which makes its job concrete instead of abstract. Findings land in the slice's Evaluation section.

6.  **Resolution.** For each finding, decide: fix now, defer to a follow-up slice, accept with rationale, or dispute. Record in Resolution notes.

7.  **Promotion decision.** If any finding reflects a pattern seen in a previous slice, promote it to AI-Memory with explicit references to both slices.

## When to escalate from simple to complex

Three rough signals that a project needs the heavier structure:

  - More than one person will work on it (including a future-you who has forgotten everything)

  - It will live for more than a week, so context preservation actually matters

  - It has parts that depend on each other, so explicit scope and contracts prevent the parts from disagreeing

Most one-session work doesn't meet any of those bars. Don't add structure for its own sake — the simple loop exists for a reason and is usually correct.

# The evaluator loop

The single biggest quality lever in this workflow is treating evaluation as a separate role from implementation. The agent that wrote the code is the worst possible reviewer of that code — it's invested in the work, biased toward seeing it as done, prone to praising its own choices. A skeptical reviewer with no investment finds different things.

## Two tiers of evaluator pass

The system supports two forms of evaluator pass with the same goal — finding what's wrong, missing, or fragile — but different levels of rigour and cost.

### Lightweight (default)

The implementing agent runs the evaluator pass at /wrap-up, explicitly stepping out of implementer mode. The wrap-up skill prompts the agent to adopt the stance of a skeptical reviewer who did not do this work and has no investment in its success.

This is cheap (no extra session, no extra context) and runs every time. It catches obvious issues and reasonable proportions of subtle ones, but it is biased toward leniency — the agent reviewing its own work has structural reasons to be soft.

In practice on real work, the lightweight pass has produced six concrete, substantive findings on a ~100-line script — including conceptual bugs (UDP endpoints having no listen state) and minor correctness issues (silent zero values for unreadable CPU readings). Useful, not theatrical. But this is one data point; the bias will be worse on judgement-heavy or architectural work.

### Full (preferred for high-stakes slices)

A fresh agent or session with no investment in the work reviews the slice and its code. The implementer hands over the slice file and points at the changed code; the evaluator reads, reviews, reports findings back. Slower, more expensive in tokens and effort, but the bias-toward-leniency goes away.

Use the full evaluator pass when the slice touches anything load-bearing: data integrity, security, public APIs, anything where shipping something broken is expensive. For most slices, lightweight is enough; the protocol gives you the option to escalate when warranted.

## Promotion: findings to durable rules

A single finding in a single slice is local information. A finding that recurs across multiple slices is a pattern, and patterns belong in AI-Memory as durable steering rules that change future agent behaviour.

The promotion rule is deliberate and strict: a finding is only promoted to AI-Memory if the same root cause appears in two or more distinct slices. The slice template has explicit checkboxes for this; the wrap-up skill prompts the agent to consider promotion only with that two-occurrence threshold. Single occurrences stay in the slice's Evaluation section.

This is the curation step that keeps AI-Memory high-signal. Without it, AI-Memory would fill up with one-off observations and become noise. With it, AI-Memory becomes a small, focused set of rules that genuinely change how new work gets done.

The Promoted evaluator learnings section in AI-Memory.md requires every entry to reference at least two slices. The references aren't optional decoration — they're the evidence that the rule represents a pattern rather than a single incident.

## The learning loop, end to end

Pulling it together, the full closed-loop sequence:

Evaluator finds an issue in slice N

→ finding recorded in slice N's Evaluation section

→ resolution decided (fix / defer / accept / dispute)

→ if pattern (also seen in earlier slice M):

→ promoted to AI-Memory with Seen in: [slice N, slice M]

→ next /kickoff reads AI-Memory

→ future generator avoids that class of issue

This loop is what turns the evaluator from a checking system into a learning system. Without the promotion step, the same class of issue gets caught forever; with it, the generator gets gradually better-steered over time.

# How this fits with plugins, skills, and other tools

The AI-assisted development ecosystem is full of tools that overlap with parts of this system. Understanding where each fits — and where it conflicts — is important to avoid duplicating effort or fighting one of them against another.

## Anthropic Skills (the project skill library)

Skills are Claude Code's native mechanism for reusable, named instructions. A skill is a directory containing a SKILL.md file with frontmatter (name, description, disable-model-invocation) and a body that gets sent to the model when the user invokes the matching slash command.

This system ships nine skills in three conceptual groups: four core protocol skills that ship by default in every project, three optional alignment skills (pre-work), and two optional maintenance skills (curation and diagnosis). The optional groups are available on demand — import them per-project at creation time.

### Core protocol skills (default in every project)

These four implement the workflow's load-bearing protocol — start of session, end of session, mid-session checkpoint, optional as-you-go logging. Every project gets them automatically.

  - /kickoff — enforces the read order at session start. Reads CLAUDE.md, AI-Memory.md, README.md, the most recent session log, Tasks.md, Decisions/, Slices/. Outputs a recap, constraints, last-session state, in-progress slices, and a Context-read list.

  - /wrap-up — runs the lightweight evaluator pass, writes the session summary to _meta/AI-Sessions/, proposes AI-Memory updates and new ADRs for human review. The closure event for a session.

  - /handoff — mid-session checkpoint. The slice isn't done; you just need to continue in a fresh chat. Writes a well-formed in-progress session log; the next agent runs /kickoff (which picks up the handoff naturally as the most recent session log). Distinct from /wrap-up: no evaluator pass, no AI-Memory promotion.

  - /new-session-log — creates a fresh dated session log file for as-you-go logging rather than after-the-fact summarising. Optional. Use when the work is long enough that capturing as you go is more reliable than reconstructing at the end.

### Alignment skills (optional, available on demand)

These three are pre-work skills that fire before implementation begins. They address misalignment — the failure mode where you and the agent think you're aligned but aren't. Not included in the default set because most work doesn't need them; import them when you anticipate needing pre-work discipline.

  - /grill — the agent interrogates your plan, surfaces unstated assumptions, drives toward a verifiable Slice Contract. Default style is Pocock-inspired interrogation (find the holes in the user's thinking before code is written). Projects can override the default style via a "Grilling style:" line in _meta/CLAUDE.md. Accepts an optional argument to force a specific style: /grill pocock, /grill brainstorm, /grill devil.

  - /devils-advocate — the agent argues against the plan you just described, finding the strongest case for not doing it. Stress-tests an existing approach. Different from /grill (which interrogates to sharpen): devil's advocate attacks to demolish, then concedes cleanly when you successfully defend.

  - /brainstorm — divergent exploration before any plan exists. The agent generates a spread of meaningfully different approaches and presents trade-offs. Use when the goal is clear but the approach isn't yet.

The pattern across the alignment skills: they're invoked when the cost of misalignment is high (substantial work, design uncertainty, attachment to a particular approach). For routine work, skip them and proceed directly to implementation.

### Maintenance skills (optional, on demand)

Two skills cover the long-lived-project failure modes — runaway AI-Memory and silent auto-load failures. Like the alignment skills, they're not in the default set; import them when you anticipate needing them, or run them ad hoc from a fully-imported vault.

  - /prune-memory — curation pass over _meta/AI-Memory.md. Reads the file plus recent session logs and proposes entries to archive, delete, or merge based on whether each rule is still load-bearing. Drafts a diff for review; nothing is written without explicit approval. Use quarterly, or whenever AI-Memory crosses ~200 lines and starts becoming its own context cost.

  - /verify-context — diagnostic pass that asks the agent to list which project context files are currently loaded in this session. Catches the silent failure mode where the auto-load chain (project-root CLAUDE.md → _meta/CLAUDE.md → stack preset) didn't fire and the agent is guessing at conventions. Reports loaded / not loaded per file and gives a one-line verdict.

### Where skills fit in the picture

Skills are the right home for stage-specific behaviour: the rules for how to start a session, how to wrap up, how to write an evaluator pass, how to interrogate a plan. They are NOT the right home for orchestration of the whole pipeline — that's the job of the file structure and the protocols built on top of it. A skill encodes a specific named ritual; the vault encodes the overall workflow.

## Superpowers (and similar plugins)

Superpowers is a plugin that gives Claude richer agentic capabilities — file management, complex multi-step execution, broader tool access. It is well suited to the implementation stage of work: doing the actual coding, running commands, managing files.

In this system's terms: Superpowers is a generator tool. It executes work; it does not plan, scope, or evaluate. The right way to use it is to run it inside a project that has been set up with this vault structure — Superpowers does the work, but kickoff/wrap-up still bracket the session, the slice still provides the contract, and the evaluator pass still runs at the end.

The common mistake is to use Superpowers (or similar) as the only structure: have it do everything from understanding requirements through implementation. It can technically do this, but you lose the artifact-driven memory layer entirely. Sessions don't get logged, decisions don't get recorded, learnings don't get curated. The work happens, but it disappears into chat history when the session ends.

Use Superpowers for what it's good at — the execution layer — and let the vault structure handle context, planning, evaluation, and memory.

## Native Claude planning mode

Claude has a planning mode that produces a structured plan before executing. This is roughly the same shape as a Plan in _meta/Plans/, but ephemeral and chat-bound.

Two ways to use them together:

  - **Treat native planning mode as the drafting tool.** Run it, get the plan, then save the result into _meta/Plans/NNNN-<name>.md so it becomes durable.

  - **Decompose the plan into slices.** The plan covers the strategy; the slices implement it one demonstrable unit at a time. The plan stays high-level; the slices carry the contracts and evaluation records.

Don't run native planning mode in isolation and then close the chat — the plan vanishes. Always commit the result to a file before moving on.

## MCP servers (connectors)

MCP (Model Context Protocol) servers expose external systems to the agent: GitHub, Jira, Linear, Notion, ServiceNow, Slack, and many others. They're the bridge between the agent and live systems it needs to read from or write to.

In this workflow:

  - **MCPs are read-mostly during kickoff and execution.** The agent might query Jira for the current ticket, GitHub for the relevant repo, ServiceNow for the incident details. These are inputs to the work, not outputs of it.

  - **Outputs still land in the vault.** Even if the agent is reading from external systems, decisions, learnings, and session summaries get written back into _meta/. The vault is the durable record; the MCPs are the live data sources.

A common anti-pattern is using MCPs to write project state into external systems (Jira comments, GitHub issue updates) without recording any of it in the vault. The next session has to re-fetch all of it; the agent doesn't have the project's local context. Keep the vault as the primary record; use external systems as the publishing surface.

## Custom skills

The nine skills shipped with the vault cover the load-bearing protocol, the alignment rituals, and the long-lived-project maintenance helpers. The skill library at 04 - Resources/AI/Skills/ is where additional skills can live and get imported per-project at creation time. Examples of skills you might add as your workflow matures:

  - /resume — continue an in-progress slice rather than starting a new session. Lighter weight than /kickoff.

  - /evaluate — a separate full evaluator pass that loads only the slice and code, with the explicit skeptical-reviewer system prompt. Run from a fresh chat for high-stakes slices when the lightweight pass at /wrap-up isn't enough.

  - /promote — review accumulated evaluator findings across slices and propose AI-Memory promotions for any pattern that's appeared in two or more.

  - **Project-type skills** — e.g. a /servicenow-impact-check that loads the ServiceNow-specific evaluation criteria for changes to ServiceNow integrations.

Resist building these too early. Each skill encodes assumptions about how the work happens; without real session data, the assumptions are guesses. Build a skill after the third or fourth time you find yourself doing the same thing manually.

## How everything fits together (summary table)

| Layer                                               | Role                                                                                                   |
| ------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| **Anthropic Skills**                                    | Stage-specific behaviour (start session, end session, log session). Per project, imported at creation.     |
| **Superpowers / agentic plugins**                       | Execution layer. Does the actual work. Runs inside a vault-managed project, doesn't replace its structure. |
| **Native Claude planning**                              | Drafting tool for plans. Capture the result into _meta/Plans/ to make it durable.                         |
| **MCP servers**                                         | Bridges to live external systems. Read-mostly inputs; outputs still land in the vault.                     |
| **Vault structure (_meta/, slices, plans, AI-Memory)** | The durable context plane. Survives sessions. Read by every agent.                                         |
| **The protocol (kickoff → work → wrap-up)**             | The connective tissue. Ensures every session starts from durable state and leaves durable state behind.    |

# Operating discipline

A few rules and habits that the system depends on to stay useful over time. None of them are enforced by the scripts — they're discipline, not automation.

## Keep CLAUDE.md short

Forty lines, not two hundred. The instinct is comprehensive coverage; the reality is that long CLAUDE.md files get skimmed by agents and humans alike. Put the truly cross-cutting rules there. Push project-specific or domain-specific content into more focused files (AI-Memory, Specs, References).

Test: if you removed the bottom third of CLAUDE.md, would the next session go meaningfully worse? If no, the bottom third is decoration.

## Append to AI-Memory, never rewrite

Each AI-Memory entry should record what triggered it (a correction, an incident, a confirmed approach) and how to apply it. Old entries stay; they don't get edited. If a rule turns out to be wrong, write a new entry that supersedes the old one. The history matters.

If AI-Memory grows past about 30 entries, it's probably accumulating noise. Review and consolidate — that's curation work, not deletion.

## Don't fabricate session content

The wrap-up skill explicitly says: if nothing durable came out of this session, say so. Don't invent corrections, validated approaches, or decisions to look thorough. A wrap-up that says "None this session" three times is honest output; a wrap-up that invents three rules is noise that future sessions will treat as real.

Same applies to evaluator findings. A clean pass on small work is a valid output. Inventing findings to demonstrate thoroughness pollutes the slice's record and the AI-Memory promotion pipeline.

## Read your own session logs

If you never read past sessions, you're getting half the value of the system. Before starting work on something, open the last 2-3 sessions on that project and skim them. /kickoff does this for you in the loop, but doing it as a human at the start of a complex piece of work is fast and informative.

Session logs also surface stale state: "this slice was meant to be wrapped up last week, what happened?"

## Re-examine the protocol when models change

This workflow encodes assumptions about model weakness. The lightweight evaluator pass exists because models tend not to review their own work skeptically; the kickoff read-order exists because models drift if they don't have explicit context. As models improve, some of these assumptions get stale.

On each significant model release, run a session and ask honestly: which parts of the harness are still load-bearing, and which have become decoration? Strip the decoration. Don't add scaffolding that the current generation of model doesn't need.

## Trust the protocol over enthusiasm

The most common failure mode is skipping /wrap-up because the session felt productive and you want to move on. Six weeks later you can't remember what was decided or why a specific choice was made. The protocol is the answer to that future regret. /wrap-up takes three minutes; reconstructing context six weeks later takes hours.

If you find yourself routinely skipping a step, that's diagnostic information. Either the step isn't actually pulling its weight (consider removing it) or you're under-investing in the discipline (consider why).

# A few things worth knowing

## This system is still maturing

The vault structure, the skills, the protocols documented here are the result of several rounds of design, review, and one round of real first-session testing. They are not the final form. Some pieces will turn out to be load-bearing; some will turn out to be decoration; some new patterns will emerge that nobody has thought of yet.

The right disposition is treating the system as a working hypothesis. Use it. Observe what works and what creates friction. Adjust. The scripts make the structure cheap to regenerate, so refactoring the vault layout is genuinely viable when the data suggests it.

## Single-user, not team

This system was designed for an individual operator and their AI agents. Team usage would require additional thought: how merges work when two people edit AI-Memory, how Decisions get reviewed, whether session logs from different team members get cross-read. None of those problems are solved here.

If you're using this with a team, the safest pattern is per-person _meta/ trees with a shared Specs/ and Decisions/ that get merged through the normal git workflow. But that's untested in this design.

## The install-package model

The vault is built by a bootstrapper (create_vault.py or Create-ObsidianAiVault.ps1) that reads templates from a templates/ folder in the install package. The bootstrapper lives outside the vault — you run it once to create the vault, and then never use it again. The operational scripts (new_project, repair_project) get copied into the vault's System/Scripts/ folder and run from there.

This split exists for a reason: it makes the templates folder the single source of truth. When you create a new vault, the bootstrapper reads from its own templates/. Once the vault exists, the operational scripts read from <vault>/System/Templates/, which is the vault's own copy. Edits made in either place are visible to the relevant runtime; both Python and PowerShell read the same files.

One subtlety worth knowing: if you maintain both the install package and a working vault, edits made in your working vault don't automatically propagate back to the install package. To keep them in sync, edit the install package's templates/ folder first and re-run the bootstrapper, or copy specific files between the two. For single-user use this is rarely a problem; the working vault is where you'd typically edit, and the install package is the seed for fresh vaults you might create later.

## Backups matter more than usual

Because the system makes the vault the primary record — not chat history, not external trackers — losing the vault is losing the project memory. Make sure the vault is backed up the way you'd back up code. If you're using the Init or Clone repo modes, _meta/ is in a git repo and that's most of the protection you need. For projects in None mode, ensure another backup mechanism covers them.

## Where to go from here

Two concrete next steps for someone new to this system:

1.  Run the simple loop (kickoff → work → wrap-up) on something small for a real session. The protocol becomes intuitive after one round; reading about it doesn't substitute for using it.

2.  Read one or two AI-Sessions logs from prior work after you've accumulated them. The format becomes much more useful once you experience it as the reader rather than just the writer.

Then the system tells you what it needs. The third round of refinement comes from observation, not design.
