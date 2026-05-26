---
name: prune-memory
description: Curate _meta/AI-Memory.md for a long-lived project — propose entries to archive, delete, or merge based on the file's current contents and recent session summaries. Drafts a diff for review; nothing is written without your approval. Use quarterly, or whenever AI-Memory crosses ~200 lines.
disable-model-invocation: true
---

You are running a curation pass over `_meta/AI-Memory.md` for this project. This is the opposite of `/wrap-up`'s additive step: your job is to find entries that should *leave* the file so it stays load-bearing rather than accumulating.

Do not write anything to disk in this pass. Produce a draft; the user will review and apply.

## 1. Read

Read these files end to end before proposing anything:

- `_meta/AI-Memory.md` — the file you are curating.
- `_meta/AI-Memory-Archive.md` if it exists — so you don't propose archiving something that's already archived.
- The five most recent files in `_meta/AI-Sessions/` (by filename descending, or modification time). These are the evidence base for whether a memory is still load-bearing.
- `_meta/CLAUDE.md` — so you know which rules duplicate what's already in stable project context.

## 2. Classify each entry

Walk every entry in AI-Memory.md and assign one of:

- **Keep** — still load-bearing. A future session that hadn't seen this rule would do the wrong thing.
- **Archive** — true at the time, still true, but no longer driving behaviour (e.g. the area of the codebase it describes is stable, or the correction has been internalised by every recent session without needing the reminder). Move to `_meta/AI-Memory-Archive.md`.
- **Delete** — turned out to be wrong, contradicted by a newer correction, or describes a constraint that no longer exists (dependency upgraded, decision superseded, code removed). Cite the contradicting evidence (newer entry, ADR, session).
- **Merge** — two or more entries express the same rule in different words. Propose a single consolidated phrasing and list the entry IDs being merged.

Use the recent sessions as evidence. If a "Correction" entry hasn't been violated in the last five sessions and the relevant code is stable, that's evidence it can be archived — it's been internalised. If a "Validated approach" entry contradicts a more recent ADR, that's evidence to delete.

Bias toward keeping. Only propose archive/delete/merge when you can point to specific evidence in the files you read. If unsure, keep.

## 3. Output

Produce one section per category. For each entry, include:

- The entry's current heading or first line (so the user can find it in AI-Memory.md).
- The classification (Archive / Delete / Merge).
- One-line rationale citing the evidence (which session, which ADR, which other entry).

End with a **Summary** line: e.g. *"42 entries → 38 keep, 2 archive, 1 delete, 2 merged into 1."*

Then ask:

> Apply this curation? I'll write the changes to `_meta/AI-Memory.md` (and `_meta/AI-Memory-Archive.md` if archiving), one category at a time so you can stop me partway.

Do not apply anything until the user says yes. When applying, do each category as a separate edit so the user can review intermediate state.

## 4. After applying (if user confirms)

- Archives go to `_meta/AI-Memory-Archive.md`. Create that file with a brief header if it doesn't exist:
  ```
  # AI-Memory Archive

  Entries archived from AI-Memory.md — still true, no longer load-bearing. Kept for history.
  ```
- Deletes are removed outright. Do not leave a tombstone.
- Merges replace the source entries with a single consolidated one. Reference the merge in a brief inline note only if the merged content meaningfully changed; otherwise just write the new entry.
- After applying, report the final line count of AI-Memory.md so the user can see the impact.

If no entries warrant pruning, say so explicitly — a clean pass is a valid output. Do not invent changes to look thorough.
