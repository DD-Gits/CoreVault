---
type: prompt
purpose: bootstrap
tags: [prompt, ai, bootstrap]
---

# Project bootstrap prompts

Paste-ready prompts for **scaffolding a brand-new project** — filling in `_meta/CLAUDE.md` and authoring `_meta/PRD.md` in three different modes (import, build, review).

**Agent-agnostic.** These prompts work with any AI agent: Claude (Claude.ai, Claude Code, Claudian), Codex, Cursor, ChatGPT, others. Just paste the relevant block into your chosen tool. Where a block assumes file access (the agent can read/write files in the project folder), it says so at the top.

Use these *once* per project to get the foundations in place. After that, switch to the [[Project-Session-Kickoff]] prompts for ongoing work.

## 1. Scaffold `_meta/CLAUDE.md`

Use this right after creating a new project to populate the project-level AI context file. Interview-style: the agent asks you a structured set of questions, then writes the file.

```
You are helping me scaffold the _meta/CLAUDE.md file for a new project I just created. _meta/CLAUDE.md is the load-bearing AI context file for this project — every future AI session on this project will read it first.

Before asking me anything:

1. Read the vault-root CLAUDE.md (and CODEX.md if it exists) to understand my general working conventions.
2. If you have file access AND the project root contains code (this is a cloned repo or has files at the root that aren't in _meta/), scan the top-level files (README.md, package.json, pyproject.toml, *.csproj, *.sln, manifest.json, etc.) to infer the tech stack. Note what you found.

Then interview me in this order. ASK ONE QUESTION AT A TIME. Wait for my answer before moving on.

1. **One-line summary** — "In one sentence, what is this project?"
2. **Goal** — "What does 'done' look like? What would you point at and say 'we did it'?"
3. **Tech stack** — language(s), runtime/platform, key services/APIs, repo locations. (If you inferred any from the scan, propose them and ask me to confirm or correct.)
4. **Domain glossary** — "What are 2-5 terms specific to this domain that a fresh agent wouldn't know? Give me the term and a one-line definition each."
5. **Project-specific conventions** — "Any rules that override or extend my vault-level conventions for this project? Code style, naming, branching, review process, etc. If none, say 'use vault defaults'."
6. **Never-dos** — "Anything you already know an agent will get wrong on this project? Common mistakes, dead-ends, things to avoid? Fine to say 'none yet, we'll learn'."

After I've answered all 6, write the file at _meta/CLAUDE.md using the existing template's section headings (One-line summary / Goal / Tech stack and tools / Domain glossary / Conventions for this project / Never do / common mistakes / Key context files / Handoff pattern). Preserve the Key context files and Handoff pattern sections from the template — don't rewrite them. Fill in the `project:` frontmatter field with the project's folder name.

If I haven't given you enough for a section, leave a clear `<!-- TODO: ... -->` placeholder rather than inventing content.

Show me the result before saving (or, if you can't show diffs, summarise what you're about to write and ask me to confirm).
```

## 2. Author PRD — Import from another tool

Use this when you already have requirements written somewhere (Notion, Linear, Aha!, a doc, an email, a slack thread). Agent maps source content into the PRD structure and flags gaps.

```
You are helping me author _meta/PRD.md for a project by importing content from another source.

Steps:

1. Read the existing _meta/PRD.md template to understand the section structure I expect (Problem, Goals, Non-goals, Users/stakeholders, Requirements - Functional / Non-functional, User stories, Acceptance criteria, Assumptions, Dependencies, Open questions).
2. I will paste source content from another tool in my next message. It may be unstructured, may use different headings, may be missing fields.
3. Map the source content into the PRD template structure. Be conservative — if the source doesn't clearly cover a section, leave it as a `<!-- TODO: ... -->` placeholder. Do not invent goals, acceptance criteria, or non-goals.
4. Show me a draft PRD with:
   - All sections filled or marked TODO
   - A "Gaps" list at the end summarising what was missing in the source
   - A "Questions for you" list with the 3-5 most important things you'd need to clarify before this is shippable as a PRD
5. After I confirm, save to _meta/PRD.md.

Wait for me to paste the source content. Don't ask anything else first.
```

## 3. Author PRD — Build from scratch (interview)

Use this when you have an idea but nothing written down yet. Agent interviews you to build the PRD.

```
You are helping me author _meta/PRD.md for a project by interviewing me. There is no existing source material — we'll build it together from a problem statement.

Before asking anything:

1. Read the existing _meta/PRD.md template and _meta/CLAUDE.md so you understand the project shape.
2. Read the vault-root CLAUDE.md for my general conventions.

Then interview me in this order. ASK ONE QUESTION AT A TIME. Wait for my answer before moving on. Push back gently if my answers are vague — a vague PRD is the problem we're trying to avoid.

1. **Problem** — "What problem are we solving? Who feels the pain, and what does the current bad day look like for them?"
2. **Users / stakeholders** — "Who are the users? Who else has a stake in this (approvers, ops, security, support)?"
3. **Goals** — "What are the 2-4 outcomes that would mean this project succeeded? State them as outcomes, not features."
4. **Non-goals** — "What are we *deliberately* not doing? What scope creep should we resist?"
5. **Functional requirements** — "What does the system need to *do*? Walk me through the user flow at a high level."
6. **Non-functional requirements** — "Performance, scaling, security, compliance, observability, accessibility — any of these load-bearing? Which?"
7. **User stories** — "Let's frame 3-6 user stories in 'As a X, I want Y, so that Z' form. I'll suggest some based on your answers; you correct me."
8. **Acceptance criteria** — "What concrete tests or observations would prove each goal was met? Be specific."
9. **Assumptions** — "What are we assuming is true that, if wrong, would invalidate the plan?"
10. **Dependencies** — "What does this depend on — other teams, services, decisions, vendors?"
11. **Open questions** — "What don't we know yet that we need to resolve?"

After all answers, write the PRD using the template's sections. Fill `project:` frontmatter. Show me the draft before saving (or summarise and ask to confirm if you can't show diffs).
```

## 4. Author PRD — Review an existing draft

Use this when you (or someone else) has written a PRD draft and you want a sanity check before locking it in.

```
You are reviewing a draft PRD for completeness, clarity, and rigour.

Read _meta/PRD.md.

Produce a structured review with these sections:

1. **Summary** — One paragraph: what this PRD is asking for, in your own words. If you struggle to summarise it, that itself is feedback.

2. **Completeness check** — For each template section (Problem, Goals, Non-goals, Users/stakeholders, Functional reqs, Non-functional reqs, User stories, Acceptance criteria, Assumptions, Dependencies, Open questions): is it present, sufficient, or weak? Use ✅ / ⚠️ / ❌ markers and one-line explanations.

3. **Clarity issues** — Vague terms, undefined acronyms, unmeasurable outcomes. Quote the specific text and suggest a sharper version.

4. **Missing acceptance criteria** — For each Goal that doesn't have an obviously corresponding acceptance criterion, flag it and propose one.

5. **Risks the PRD glosses over** — Things the PRD treats as obvious that probably aren't (timeline, dependencies, who's the decision-maker on X, what "done" means).

6. **Top 3 questions** — The three things you'd most want answered before committing engineering effort to this PRD.

Do not modify the PRD. Output the review only. I'll decide what to apply.
```

## Notes on running these

- **File-access prompts vs paste-only:** Prompts 1 and 4 assume the agent can read/write files in the project folder (Claude Code, Claudian, Cursor, etc.). Prompts 2 and 3 work paste-only too — just paste the existing PRD template into the chat as context.
- **Working directory:** if your agent honours a working directory, launch it inside the project folder (e.g. `02 - Projects/Work/<Project>/`) so relative paths resolve.
- **Iteration:** none of these are one-shots. Run, review, edit, run again. The CLAUDE.md scaffold prompt is especially worth re-running once you've completed a few sessions and have real never-dos to add.
- **For a brand new project, the typical sequence is:** create project via `New-ObsidianProject.ps1` → run prompt 1 (CLAUDE.md) → run prompt 2 or 3 (PRD) → optionally run prompt 4 to sanity-check → start real work using [[Project-Session-Kickoff]].
