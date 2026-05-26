**Obsidian AI Vault**

User Guide

*How to create projects and use them in Claude sessions*

# What this guide is

This is the operational manual for using the vault you've just set up. It covers the day-to-day workflow — creating projects, doing the one-time bootstrap, and running real work sessions with Claude (or Codex, Cursor, or any other AGENTS.md-aware agent).

This is the *what to do* companion to the Workflow Guide (which covers *why* the vault is structured the way it is). If you want the deeper rationale — durable vs episodic memory, the evaluator loop, when to escalate from simple to complex — read that one. This guide assumes you've read it, or that you're happy to take the workflow on faith and learn by doing.

Structure of this guide:

1.  Choosing the right project mode (local-only, local git, or cloned repo) when creating a new project.

2.  The one-time bootstrap process for a new project: filling in CLAUDE.md and the PRD.

3.  Running real work sessions — what /kickoff, /wrap-up, /handoff, /new-session-log do, and when to invoke each.

4.  A quick reference for slash commands and common patterns.

Keep this guide handy for the first few projects. After three or four real sessions the workflow becomes intuitive; until then, treat the slash commands and prompts as scaffolding.

# Creating a project: choosing the right mode

Every new project starts the same way:

cd <vault>\System\Scripts

.\New-ObsidianProject.ps1 (PowerShell)

python new_project.py (Python — works anywhere)

The script prompts for a project name, type (Work or Personal), and then asks for a repo mode. The repo mode is the most consequential choice — it determines how the project's code (if any) is tracked. The other prompts are easier; you can change most of them later.

## The three modes

Each mode produces a working project. They differ only in how the project interacts with git.

| Mode  | What it does                                                                                                                                                                                                                                                                                |
| --------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **None**  | No git involvement at all. The project folder is created with the _meta/ structure, AGENTS.md, and (depending on skills choice) .claude/skills/ and .agents/skills/. No .git folder. Useful for note-taking projects, exploratory work, anything where you don't expect to track code changes. |
| **Init**  | Creates a fresh git repository at the project root, with all template files staged but not yet committed. Useful when starting a new piece of code from scratch and you want git tracking from day one. A stub README.md is placed at the project root for visibility on git hosting.           |
| **Clone** | Clones an existing git repository into the project folder and then overlays the _meta/ structure on top. Useful when adopting the vault workflow on a repo you already work in. The repo's own files are not touched; _meta/ becomes additional project context alongside the code.           |

## When to use each

### None — for projects without code

If the project is research notes, a planning exercise, a writing project, or anything else that won't have a code repository, use None. The _meta/ folder still gives you all the AI workflow benefits — durable context, session logs, decisions, AI-Memory — without the overhead of a git repo you'll never commit to.

You can switch a None project to Init later if you change your mind: run \`git init\` in the project folder, add a root README.md, and you're in the same state as if you'd chosen Init originally.

### Init — for new code you'll write yourself

Use Init when you're starting a brand-new project and the code will be written from scratch. The script does the git init for you and stubs a root README.md so the repo looks reasonable on GitHub or wherever you push it.

Two things to know about Init mode:

  - The .gitignore at the project root already excludes _meta/AI-Sessions/ and _meta/Meetings/ — these are personal working notes, not deliverables. If you want session logs to be part of your repo (e.g. for a shared team project), edit the .gitignore to allow them.

  - The .claude/skills/ and .agents/skills/ folders are also gitignored by default. These are your personal workflow helpers, not part of the project deliverable. If the project is itself a skill or plugin, remove those gitignore lines.

### Clone — for existing repos you want to add to the workflow

Use Clone when you've decided to adopt the vault workflow on a project you already have code for. The script clones the repository normally, then overlays the _meta/ structure into the project folder. The cloned repo's files are not modified.

Two important behaviours in Clone mode:

  - If the upstream repo already has an AGENTS.md or .gitignore at the root, the script does not overwrite them. The template AGENTS.md is skipped; the template .gitignore is placed at _meta/.gitignore instead. Your upstream repo files are sacred.

  - The .claude/skills/ and .agents/skills/ folders are added to .git/info/exclude (a local-only gitignore that doesn't get committed). This means the skills won't show in git status but you also haven't modified the upstream .gitignore. Clean.

After cloning, decide whether you want _meta/ content to be tracked by the upstream repo. By default it's not (the local _meta/.gitignore handles it). If you do want it tracked — e.g. for a team-shared workflow — merge the _meta/.gitignore into the project's root .gitignore.

## Other prompts during project creation

The script also prompts for:

| Prompt      | What to enter                                                                                                                              |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| **Owner**       | Your name or identifier. Goes into the project README's frontmatter. Defaults to your OS username.                                             |
| **Area**        | A free-text categorisation (e.g. "ServiceNow", "Home automation"). Defaults to the project type.                                               |
| **Status**      | Initial status. Defaults to "Planning". Other useful values: "Active", "Paused", "Done", "Archived".                                           |
| **Target date** | Optional. Press Enter to leave blank. Use YYYY-MM-DD format if you do enter one.                                                               |
| **Skills**      | Which helper skills to import. Default is the four-skill core protocol: kickoff, wrap-up, new-session-log, handoff. See "Skills choice" below. |

### Skills choice

When asked about skills:

  - **Default** — imports the four core protocol skills. This is what most projects need.

  - **None** — imports nothing. Useful for projects where you'll be using paste-able prompts instead of skills.

  - **All** — imports everything, including the optional alignment skills (grill, devils-advocate, brainstorm). Use when you anticipate needing the alignment rituals.

  - **Custom** — interactive picker, choose skill-by-skill.

  - **A comma-separated list** (e.g. "Default,grill") — imports the named skills plus the Default set.

You can change the skills imported into a project later by running repair_project.py or by manually copying skills from 04 - Resources\AI\Skills\ into the project's .claude\skills\ and .agents\skills\ folders.

# The one-time bootstrap process

After the script creates the project, the _meta/ folder is fully scaffolded but the load-bearing files (_meta/CLAUDE.md and _meta/PRD.md) are empty templates. You need to fill them in before doing real work.

This is a one-time step per project. You'd typically do it immediately after creating the project, before the first session.

## Where to find the bootstrap prompts

Open this file in Obsidian:

04 - Resources\AI\Prompts\Project-Bootstrap.md

It contains four prompt blocks, each designed to be pasted into Claude (or another agent) with the project folder open. You only need the first two for most projects. The other two are alternatives for when you have existing material to import or want a structured review.

| Prompt block              | What it does                                                                                                                                                                             |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Scaffold _meta/CLAUDE.md** | Interview-style. The agent asks you 6 structured questions about the project — summary, goal, stack, glossary, conventions, never-dos — and writes the CLAUDE.md file based on your answers. |
| **Author PRD — Build**        | Interview-style. The agent asks about what the project does, who it's for, success criteria, scope. Writes _meta/PRD.md.                                                                    |
| **Author PRD — Import**       | For when you already have a PRD (in a doc, a ticket, an email). You paste it, the agent maps it to the template structure and flags gaps.                                                    |
| **Author PRD — Review**       | Structured completeness check on a PRD you've already drafted. Surfaces ambiguities, missing sections, weak success criteria.                                                                |

## How the bootstrap conversation goes

Here's what a typical CLAUDE.md scaffold conversation looks like:

1.  Open Claude Code (or your AI tool of choice) pointed at the new project folder.

2.  Open Project-Bootstrap.md in Obsidian. Copy the entire "Scaffold _meta/CLAUDE.md" prompt block (between the marked boundaries).

3.  Paste it into Claude. The agent acknowledges and asks the first question.

4.  Answer each question. Keep answers short — three sentences per question is usually enough. The agent will probe if it needs more.

5.  After the last question, the agent writes _meta/CLAUDE.md and confirms.

6.  Review the file. Edit if anything is wrong. Save.

Then repeat the same process for the PRD (Build or Import depending on whether you're starting from scratch or have existing material).

## How much detail to put in

This is the most common question during bootstrap, and the honest answer is: less than you think.

  - CLAUDE.md should be 40-80 lines, not 200. The agent will read it at the start of every session — long files get skimmed, short focused ones get read carefully. Put the load-bearing rules: stack, glossary, never-dos, project-specific conventions. Push deeper documentation into Specs/ or References/.

  - PRD.md should answer: what are we building, why does it matter, who is it for, what does "done" look like. Not architecture decisions (those go in Decisions/), not implementation plans (those go in Plans/), not technical contracts (those go in Specs/).

A useful sanity check: if you removed the bottom third of your CLAUDE.md, would the next session go meaningfully worse? If *no*, the bottom third is decoration. Cut it.

## What if the project doesn't need a PRD?

Many projects don't — especially personal projects, one-off scripts, or exploratory work. In that case skip the PRD bootstrap entirely. Leave _meta/PRD.md as the empty template (or delete it; nothing depends on it existing).

The CLAUDE.md scaffold step is more universally useful — even a one-off script benefits from a few lines of stack and conventions context. Do that one even when PRD doesn't apply.

# Running a Claude session

Once a project has _meta/CLAUDE.md populated, you're ready for real work sessions. The pattern is the same every time: kickoff, do the work, wrap-up. For long pieces of work that span context windows, /handoff bridges between sessions.

## Opening a session

Point your AI tool at the project folder. Two common ways:

  - **Claude Code**: run \`claude\` from inside the project root in a terminal. Claude Code auto-loads any CLAUDE.md at the working directory or above. For us, that means the vault-root CLAUDE.md gets auto-loaded — which is exactly what we want, because that has the global discipline. The project-level _meta/CLAUDE.md is loaded by /kickoff explicitly.

  - **Codex**: Codex looks for AGENTS.md at the working directory. The project root has one, pointing at _meta/. Codex follows the pointer automatically.

  - **claude.ai or other chat-only tools**: use the paste-able prompts in 04 - Resources/AI/Prompts/Project-Session-Kickoff.md instead of slash commands. Same logic, manual invocation.

## The four session skills

If you imported the default skill set (kickoff, wrap-up, new-session-log, handoff), all four are available as slash commands. Here's when to use each:

### /kickoff — start of every session

Type this first, every time. The agent does the following automatically:

  - Reads _meta/CLAUDE.md (project context)

  - Reads _meta/AI-Memory.md (corrections, validated approaches, durable rules)

  - Reads _meta/README.md (project status)

  - Reads the most recent _meta/AI-Sessions/<file> (what happened last time)

  - Scans _meta/Slices/, _meta/Decisions/, _meta/Tasks.md as needed

  - Outputs a recap of the project's state, what's in progress, and the load-bearing constraints

  - Asks: "What should we focus on today?"

If kickoff says something that surprises you — a stale slice, a constraint you didn't remember, a previous session that ended in a confusing place — that's the value of the protocol. Take a moment to deal with it before describing today's work.

### Doing the work

Between kickoff and wrap-up, work normally. The agent has the context. You can iterate freely. For substantial work, consider invoking one of the optional alignment skills before you start coding:

  - /grill — agent interrogates your plan, surfaces assumptions, drives toward a verifiable Slice Contract. Default is Pocock-style interrogation. Best when you have a draft plan you want sharpened.

  - /devils-advocate — agent argues against your plan, finds the strongest case for not doing it. Best when you suspect you're attached to a particular approach and want stress-testing.

  - /brainstorm — agent helps you explore the option space. Best when the goal is clear but the approach isn't yet.

These are optional. For routine work — fixing a bug, writing a short script, making an obvious change — skip them. For non-trivial work where the design isn't fully settled, they pay back the time they cost.

### /wrap-up — end of every session

Type this at the end of every session. The agent does four things in sequence:

1.  Runs the evaluator pass — steps out of implementer mode, reviews the work skeptically, lists concrete findings.

2.  Drafts the session summary and writes it directly to _meta/AI-Sessions/<date>-<topic>.md.

3.  Proposes any AI-Memory updates for your review (corrections, validated approaches, domain quirks). It does not write these automatically — they require your confirmation.

4.  Flags any new decisions worth recording as ADRs in _meta/Decisions/. Same review-first pattern.

The single biggest discipline mistake is skipping /wrap-up because the session felt productive. Six weeks later you can't remember what was decided. /wrap-up takes three minutes; reconstructing context six weeks later takes hours.

### /handoff — when context is filling up

Use /handoff when you're in the middle of work and need to continue in a fresh chat (because the agent is slowing down, because you're switching machines, because you want a clean break). It's different from /wrap-up:

| Skill    | When to use                                                                                                            |
| ------------ | -------------------------------------------------------------------------------------------------------------------------- |
| **/wrap-up** | The slice is done. Evaluator pass, AI-Memory proposals, ADR proposals, session summary.                                    |
| **/handoff** | The slice is NOT done. Just save state cleanly so you can resume in a new chat. No evaluator pass, no AI-Memory promotion. |

/handoff writes an in-progress session log to _meta/AI-Sessions/<date>-<topic>-handoff.md and produces a short continuation prompt you copy into your new chat. The continuation prompt tells the next agent to run /kickoff, which picks up the handoff as the most recent session log. Everything continues seamlessly.

### /new-session-log — optional, for long sessions

Most of the time you don't need this. /wrap-up creates the session summary at the end. /new-session-log is for the case where you'd rather take notes as you go, rather than reconstruct them at wrap-up time. It creates a dated session log file you can update through the session.

Use it when:

  - The session is going to be long (more than an hour) and reconstructing at the end would lose detail.

  - You're doing exploratory work where it's useful to capture intermediate observations.

  - You expect to interleave the session with other work and want a place to come back to.

For short, focused sessions skip it. /wrap-up's after-the-fact summary is fine.

## A typical session, end to end

Here's what a normal session looks like in practice:

> /kickoff

[agent reads files, outputs recap, asks what to focus on]

> I'd like to fix the bug where users with apostrophes in their names

fail validation.

[agent and you work on the fix; agent writes code, runs tests, iterates]

> /wrap-up

[agent runs evaluator pass, writes session summary to disk,

proposes AI-Memory updates for review, flags any decisions]

The work in the middle is the actual project. /kickoff and /wrap-up bracket it. That's it. The protocol is intentionally light.

# Quick reference

## Slash commands

| Command                        | Purpose                                                                           |
| ---------------------------------- | ------------------------------------------------------------------------------------- |
| **/kickoff**                       | Start of every session. Reads project context and reports state.                      |
| **/wrap-up**                       | End of every session. Evaluator pass + session summary + AI-Memory and ADR proposals. |
| **/handoff**                       | Mid-session checkpoint. Save state and continue in a fresh chat.                      |
| **/new-session-log [topic]**     | Create a fresh dated session log for as-you-go note-taking. Optional.                 |
| **/grill**                         | Pre-work interrogation. Agent sharpens your plan into a verifiable contract.          |
| **/grill pocock\|brainstorm\|devils-advocate** | Force a specific grilling style regardless of project setting.                        |
| **/devils-advocate**               | Adversarial review of an existing plan.                                               |
| **/brainstorm**                    | Divergent exploration when the goal is clear but the approach isn't.                  |
| **/prune-memory**                  | Quarterly curation of `_meta/AI-Memory.md` — proposes archive/delete/merge candidates from recent sessions. Drafts a diff; nothing written without approval. |
| **/verify-context**                | Diagnostic — lists which project context files are currently loaded. Use when the agent seems to be guessing at conventions. |

## Common file locations

| Path (project-relative) | Purpose                                                                                                                                                 |
| --------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **_meta/CLAUDE.md**        | Project-specific AI context. Read at every /kickoff. Edit when conventions or constraints change.                                                           |
| **_meta/AI-Memory.md**     | Durable steering rules. Append at /wrap-up for corrections, validated approaches, promoted evaluator learnings. Never rewrite — supersede with new entries. |
| **_meta/AI-Sessions/**     | Session logs, one per session. Most recent is read at /kickoff. Handoff files use the same folder with a -handoff suffix.                                   |
| **_meta/Decisions/**       | ADR-style decision records. One file per decision. Immutable; superseded by new files.                                                                      |
| **_meta/Slices/**          | Vertical slices of work. Use the 0000-template.md as starting point. Each slice has a Contract section.                                                     |
| **AGENTS.md**               | Project-root pointer file. Auto-loaded by Codex and AGENTS.md-aware agents. Tells them to read _meta/.                                                     |

## Common patterns

### Starting a new project

1.  Run New-ObsidianProject.ps1 from <vault>\System\Scripts\.

2.  Pick a project type (Work/Personal), repo mode (None/Init/Clone), and skill set (Default usually).

3.  Open Project-Bootstrap.md and run the "Scaffold _meta/CLAUDE.md" prompt.

4.  Run the "Author PRD" prompt if applicable.

5.  Start your first real session with /kickoff.

### Resuming an existing project

1.  Open the project folder in your AI tool of choice.

2.  Type /kickoff.

3.  Read the recap. If anything is unexpected, address it before continuing.

4.  Describe today's work.

5.  Work normally. End with /wrap-up.

### Repairing a project

If a project was created before a template was added (e.g. a new _meta/ subfolder was introduced in a later vault version), run:

python repair_project.py --project "<path-to-project>"

Repair detects missing files and adds them from the template. It never overwrites existing files — your project content is safe.

Pass --dry-run to see what would be added without writing anything.

### Adding a new skill to an existing project

Copy the skill folder from 04 - Resources\AI\Skills\ into the project's .claude\skills\ and .agents\skills\ folders. Both locations should match — Claude Code reads .claude\skills\, Codex reads .agents\skills\.

## Troubleshooting

| Symptom                                   | What to check                                                                                                                                                                                                       |
| --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **/kickoff says "no _meta/CLAUDE.md found"** | The project wasn't created from the template, or the file was deleted. Run repair_project.py to restore the template, then bootstrap CLAUDE.md.                                                                        |
| **Slash commands not recognised**             | Skills weren't imported, or you're running the agent in a folder that isn't the project root. Check that .claude\skills\ (or .agents\skills\) exists in the project root and contains the skill folders.            |
| **Session log not being written**             | Your agent doesn't have write access to the project folder. Some sandboxes block file writes from the vault path. The agent will tell you the session summary content in chat; save it manually to _meta/AI-Sessions/. |
| **AI-Memory growing too fast**                | Promotion criteria are too loose. Tighten: only promote if the same root cause appears in 2+ distinct slices, and only via the explicit /wrap-up review step. Don't append on impulse.                                  |
| **CLAUDE.md not auto-loaded by Claude Code**  | Claude Code only auto-loads CLAUDE.md from the working directory or its parents. If you launched from outside the vault, that's why. Use /kickoff to load _meta/CLAUDE.md explicitly.                                  |

If something else goes wrong, the most useful diagnostic is the contents of _meta/AI-Sessions/. Each session log tells you what state the project was in last time and what was attempted. Reading the last two or three logs usually reveals what's drifted.
