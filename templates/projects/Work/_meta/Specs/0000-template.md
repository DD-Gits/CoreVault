---
type: spec
project:
status: draft        # draft | accepted | superseded
date:
supersedes:
superseded_by:
related_decisions: []
tags: [spec]
---

# NNNN — Spec title

## Summary

One paragraph: what this spec covers and the boundaries it imposes.

## Context

Why this spec exists. The PRD requirement, plan, or slice it supports.

## Architecture

Component breakdown, data flow, integration points. Link Excalidraw diagrams from `../Assets/` or `../References/Architecture/` where relevant.

## Data model

Entities, relationships, schemas. Mention storage choice if it's non-obvious (DB, blob, queue).

## API / interface

For services: endpoints, request/response shapes, status codes, auth, idempotency.
For libraries: function signatures, error types, lifecycle.

## Edge cases

-

## Non-functional requirements

- **Performance:**
- **Scaling:**
- **Observability:** what we log, what we trace, what we alert on
- **Security:** auth, data handling, secrets
- **Reliability:** SLAs, error budgets, retry policy

## Open questions

-

## Links

- PRD section:
- Plan:
- Related decisions:
- Reference material: [[../References/README|References]]
