---
type: decisions-index
project:
---

# Decisions

Architecture / project decisions for this project. One file per decision, numbered sequentially. Decisions are immutable — to change one, write a new decision that supersedes it and update the old one's `status` to `superseded` with a link to the replacement.

## How to add a decision

1. Copy `0000-template.md` to `NNNN-short-title.md` (next free number, kebab-case title).
2. Fill in context, decision, consequences.
3. Set `status: accepted` once decided.
4. Link to it from related notes with `[[NNNN-short-title]]`.

## Index

If you have the Dataview plugin, this query will list decisions automatically. Otherwise list them manually below.

```dataview
TABLE status, date
FROM "02 - Projects"
WHERE type = "decision" AND project = this.project
SORT file.name ASC
```

### Manual list

- [[0000-template|0000 — Template]] (template, not a real decision)
