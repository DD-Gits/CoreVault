---
type: specs-index
project:
---

# Specs

Technical specifications for this project. One file per spec. Specs sit between the PRD (what we're building, business-level) and the code (how it's actually implemented) — covering architecture, data models, API contracts, edge cases, and non-functional requirements.

Specs are referenced by **plans** ([[../Plans/README|Plans index]]) and **slices** ([[../Slices/README|Slices index]]), and may be constrained by **decisions** ([[../Decisions/README|Decisions index]]).

## How to add a spec

1. Copy `0000-template.md` to `NNNN-short-title.md`.
2. Fill in summary, context, architecture, data model, API.
3. Set `status: accepted` once stable.
4. Update `superseded_by` if revised significantly later; create the new spec file with the next number.

## Index

```dataview
TABLE status, date
FROM "02 - Projects"
WHERE type = "spec" AND project = this.project
SORT file.name ASC
```

### Manual list

- [[0000-template|0000 — Template]] (template, not a real spec)
