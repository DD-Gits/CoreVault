---
type: plans-index
project:
---

# Plans

Implementation plans for this project. One file per plan, numbered sequentially. Plans describe **how** we'll build something — the approach, the phases, the order of work. They are not immutable like decisions: a plan can move from `draft → accepted → in-progress → complete`, or be superseded by a revised plan when the situation changes.

Plans link down to **slices** ([[../Slices/README|Slices index]]) and reference **specs** ([[../Specs/README|Specs index]]) and **decisions** ([[../Decisions/README|Decisions index]]) that constrain the work.

## How to add a plan

1. Copy `0000-template.md` to `NNNN-short-title.md` (next free number, kebab-case).
2. Fill in goal, context, approach, phases/slices.
3. Set `status: accepted` once you're committing to it.
4. As work begins, create matching slice files in `../Slices/` and link them.
5. If a major rethink is needed, write a new plan with `supersedes: NNNN-old-title` and set the old plan's `superseded_by`.

## Index

```dataview
TABLE status, date
FROM "02 - Projects"
WHERE type = "plan" AND project = this.project
SORT file.name ASC
```

### Manual list

- [[0000-template|0000 — Template]] (template, not a real plan)
