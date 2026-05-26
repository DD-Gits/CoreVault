---
name: grill
description: Pre-work alignment ritual. The agent interrogates you about a plan, design, or change before any code is written, surfacing assumptions and decision points you haven't resolved. Default style is Pocock-inspired interrogation; projects can override via a "Grilling style:" line in _meta/CLAUDE.md. Pass an optional argument to force a specific style for this invocation regardless of project setting — `/grill pocock`, `/grill brainstorm`, or `/grill devil`. Use before starting any non-trivial slice or design choice.
disable-model-invocation: true
argument-hint: "[pocock|brainstorm|devil]"
---

Before any work begins on the topic the user just raised, run a grilling session.

## Step 0: Determine the style

Choose the grilling style by this priority (first match wins):

1. **Explicit argument** — if the user passed `pocock`, `brainstorm`, or `devil` as an argument to `/grill`, use that style. Document at the start of the session: *"Running Pocock-style grilling (forced via argument, overriding any project setting)."*
2. **Project override** — look in `_meta/CLAUDE.md` for a line starting `Grilling style:`. If present, use that style.
3. **Default** — Pocock-style interrogation.

The three styles are:

- **pocock**: adversarial-cooperative interrogation. Agent leads, asks pointed questions to find holes in the plan, drives toward a tight specification before any work begins.
- **brainstorm**: divergent support. Agent helps the user explore the option space; generative rather than interrogative; broadens before narrowing.
- **devil**: argues *against* the plan. Makes the strongest possible case for not doing it; pure adversarial stress test.

(Note: the dedicated `/brainstorm` and `/devils-advocate` skills do these styles standalone — `/grill brainstorm` and `/grill devil` are shortcuts when you want the equivalent behaviour without leaving the `/grill` flow.)

## Pocock style (default)

Your job is to find the holes in the user's thinking *before* they write any code. You are adversarial-cooperative — you are on their side, but you are trying to make their plan fail in conversation so it doesn't fail in production.

### What to ask

Work through the decision tree until every branch is resolved. Cover at least:

- **The actual goal.** What externally-observable outcome means "done"? Not "implement X" but "the user can do X and Y happens." Push back if the goal is internal ("refactor the auth module") rather than observable.
- **The unstated assumptions.** What is the user taking for granted that might not hold? Existing data shape, user behaviour, performance characteristics, downstream dependencies.
- **The alternatives.** What approaches did they consider and reject? If they only considered one, that's a flag — there's almost always more than one way.
- **The boundaries.** What's explicitly NOT in scope? What might a reviewer expect that we're deliberately omitting? Get these on the table so they don't surface as evaluator findings later.
- **The risk surface.** What breaks if this goes wrong? Who notices? What's the rollback?
- **The verification.** How will we know it actually worked? Concrete enough that someone other than the implementer could run through it.

### How to ask

- One question at a time. Wait for the answer before moving on.
- If an answer is vague, sharpen it. *"What does X mean specifically?"*
- If an answer reveals a deeper question, follow it. Don't be in a hurry to finish.
- If the user says *"I don't know,"* surface it as an open question rather than letting it slide.

### When to stop

Stop when every question has a specific, non-vague answer AND you could write a Slice Contract (Done means / Verification plan / Out of contract) without making anything up.

Summarise at the end:

- **Done means:** the externally-observable success criteria.
- **Verification plan:** how we'll check it.
- **Out of contract:** what's explicitly not in scope.
- **Open questions:** anything the user couldn't answer.

Offer to draft the slice contract or update the existing one.

## Brainstorm style (`/grill brainstorm`)

Switch to the behaviour described in `/brainstorm`'s SKILL.md. Briefly: generate 3-5 meaningfully different approaches to the problem, present each with one-sentence description / rough cost / rough benefit / main downside, name what they have in common (the load-bearing assumption), then offer to converge on one before transitioning into Pocock-style grilling on the chosen approach.

## Devil's advocate style (`/grill devil`)

Switch to the behaviour described in `/devils-advocate`'s SKILL.md. Briefly: argue *against* the plan, find the strongest case for not doing it, raise 2-3 sharp objections rather than ten weak ones, concede points cleanly if the user counter-argues effectively. Goal is stress-testing, not winning.

## Anti-patterns

- Don't grill on trivial work. Typo fixes, one-line changes, obvious cleanups don't need this.
- Don't grill after work has started. This is a *pre-work* skill. If the user already has code in progress, use `/wrap-up` or `/handoff` instead.
- Don't soften the questions to be polite. The whole point is that you're harder on the plan than the user would be alone.
- Don't grill forever. If after 5-6 exchanges the plan is clear and verifiable, stop. Over-grilling is its own failure mode.
