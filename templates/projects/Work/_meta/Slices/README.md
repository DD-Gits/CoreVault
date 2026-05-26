---
type: slices-index
project:
---

# Slices

Implementation slices — vertical units of work that deliver value end-to-end. Each slice can be planned, implemented, tested, and deployed independently. Slices roll up to one or more plans ([[../Plans/README|Plans index]]).

Slices also track **deployment status per environment** (dev / test / staging / prod) so this folder doubles as a deployment dashboard.

## How to add a slice

1. Copy `0000-template.md` to `NNNN-short-title.md`.
2. Fill in goal, scope, acceptance criteria, test plan.
3. Set `plan: NNNN-parent-plan` to link the parent plan.
4. As work and deployment progress, update `status` and the `deploy_*` fields.

## Deployment dashboard

```dataview
TABLE
  status as Status,
  deploy_dev as Dev,
  deploy_test as Test,
  deploy_staging as Staging,
  deploy_prod as Prod
FROM "02 - Projects"
WHERE type = "slice" AND project = this.project
SORT file.name ASC
```

## Slices ready to promote

```dataview
TABLE deploy_test, deploy_staging, deploy_prod
FROM "02 - Projects"
WHERE type = "slice"
  AND project = this.project
  AND deploy_test = "deployed"
  AND deploy_staging != "deployed"
SORT file.name ASC
```

### Manual list

- [[0000-template|0000 — Template]] (template, not a real slice)
