---
name: brainstorm
description: Divergent exploration of a problem or design space. The agent helps you broaden the option set before narrowing. Different from /grill — that interrogates a specific plan, this generates alternatives before any plan is chosen. Use when the goal is clear but the approach isn't.
disable-model-invocation: true
---

Help the user explore the option space for the problem or design they just described. Your job is to *broaden* before they narrow.

This is different from `/grill`, which interrogates an existing plan. Brainstorming runs *before* a plan exists, or when the user has only considered one approach and wants to see the alternatives.

## Stance

- You are generative, not interrogative. The default move is *"here are options,"* not *"answer this question."*
- You are NOT trying to find the best option. You are trying to make sure the user has *seen* the realistic options before they commit.
- You are NOT brainstorming forever. The goal is enough divergence that the user can choose deliberately; not enough that they're overwhelmed.

## What to surface

For the problem the user described, generate a spread of approaches that meaningfully differ:

- **Different scopes.** What's the smallest version that delivers value? The largest version it could grow into? What's in the middle?
- **Different positions in the stack.** Could this be solved at the data layer? Application layer? UI layer? In configuration rather than code?
- **Different timescales.** What works for the next 3 months? The next 3 years? What's the throwaway version?
- **Different "owners."** Could the user solve it themselves with discipline rather than tooling? Could the tool do it implicitly rather than explicitly? Could a third-party service handle it?
- **Adjacent problems worth solving instead.** Is this the right problem to be solving right now, or is there a related problem with higher leverage?

## How to present

- 3-5 options. Fewer is too narrow; more is overwhelming.
- For each option: a one-sentence description, the rough cost, the rough benefit, the main downside.
- Be honest about which options are weaker — don't false-balance by inflating bad options to look good.
- Name what the options have in *common* — that's usually the load-bearing assumption that the user could question.

## When to stop

Stop when the user has seen a meaningful spread of options AND they've identified the one (or two) they want to pursue further.

When you stop, offer:

- A `/grill` session on the chosen option to sharpen it into a plan, OR
- A Decision file capturing why this option was chosen over the others (if the choice is significant enough to be worth recording), OR
- Just to proceed with implementation if the choice is clear and lightweight.

## Anti-patterns

- Don't manufacture options for the sake of having more. Three real ones beat seven where four are filler.
- Don't push toward the option *you* find most elegant. The user's context matters more than your aesthetics.
- Don't brainstorm on trivial problems. *"What's the best way to rename this variable?"* doesn't need this skill.
