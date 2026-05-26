---
type: risks-index
project:
---

# Risks and Issues

One file per risk or issue. Risks are *potential* problems with likelihood and mitigation; issues are *active* problems with a status and next action.

## How to add an entry

1. Copy `0000-template.md` to `NNNN-short-title.md` (next free number).
2. Set `kind: risk` or `kind: issue`.
3. Fill in fields. Update `status` as it evolves.
4. Link from related notes / decisions / sessions with `[[NNNN-short-title]]`.

## Index

```dataview
TABLE kind, status, likelihood, impact, owner
FROM "02 - Projects"
WHERE type = "risk-issue" AND project = this.project
SORT status ASC, file.name ASC
```

### Manual list

- [[0000-template|0000 — Template]] (template, not a real entry)
