---
type: workflow
tags: [workflow, project, archive]
---

# Archive a project workflow

How to close out a project once it's done, paused indefinitely, cancelled, or otherwise no longer active.

## Two archive modes

You have a choice. Default to **Status-only**. Move to **Physical archive** only when `02 - Projects/` gets too crowded to navigate.

| Mode | Action | Wins | Costs |
|------|--------|------|-------|
| Status-only | Set `status: archived` in `_meta/README.md` | Dashboards/indexes filter it out automatically. Links keep working. Trivial to un-archive. | Folder still visible in file tree. |
| Physical archive | Move the project folder to `09 - Archive/Projects/<Project>/` | Clean file tree. Clear separation between live and historical. | Breaks any wiki-links by path. Slightly more friction to un-archive. |

## Status-only archive (default)

1. **Finish the handover.** Fill in `_meta/Handover.md` if anyone is inheriting the work (or future-you in 6 months). Capture: current status, completed work, outstanding work, key decisions, known risks, important links, recommended next step.
2. **Write a final AI-session summary** to `_meta/AI-Sessions/` if AI sessions were involved. This is the last load-bearing artefact before things go cold.
3. **Update `_meta/README.md` frontmatter:**
   ```yaml
   status: archived
   target_date: <leave as-was or set to actual close date>
   ```
4. **Optional fields to add to frontmatter** (nice for future you):
   ```yaml
   archived_date: 2026-05-15
   archive_reason: completed     # completed | cancelled | paused-indefinitely | superseded
   superseded_by:                # link to replacement project if any
   ```
5. **Update any dashboards** that filter on `status` to confirm the project drops out of the active list. Most queries in this vault use `WHERE status != "archived"` so it should be automatic.

That's it. The folder stays in place. Cross-project links keep working.

## Physical archive (when the file tree gets noisy)

1. Do all the status-only steps first.
2. **Move the project folder:**
   ```powershell
   Move-Item `
     "$env:USERPROFILE\Obsidian\Vault\02 - Projects\Work\<Project>" `
     "$env:USERPROFILE\Obsidian\Vault\09 - Archive\Projects\<Project>"
   ```
3. **Watch for broken wiki-links.** Obsidian's "Files and Links → Automatically update internal links" should keep most wiki-links intact when you move via Obsidian's file explorer. If you move via PowerShell, run a vault-wide search for `[[02 - Projects/Work/<Project>` and fix any path-qualified links manually.
4. **Dataview queries that hard-code `FROM "02 - Projects"`** won't pick up archived projects. If you want them to, broaden the source — e.g. `FROM "02 - Projects" OR "09 - Archive/Projects"`. Usually you *don't* want them to, which is the point.

## Git considerations (for projects with a repo)

Independent of which archive mode you pick.

- **`.git/` follows the folder.** Moving the project folder moves its git history too. No reset needed.
- **Push final state before archiving.** If the repo has a remote, push `main` (and any unmerged branches you want to preserve) before the project goes cold. After archival you might forget what's local-only.
- **Tag the close.** Optional but useful: `git tag archived -m "Archived YYYY-MM-DD"` then `git push --tags`. Makes the close point easy to find later.
- **Decide what to do with the GitHub/Azure DevOps remote:**
  - **Archive the upstream repo** (GitHub: repo settings → "Archive this repository") — read-only, clear signal it's closed, can be unarchived.
  - **Leave it active** if anyone might still need to file an issue or contribute occasionally.
  - **Delete the remote** only if it was experimental and you're certain it won't be needed.
- **Don't delete the local folder.** Even if you delete the remote, the local archive folder retains the full git history.

## Un-archiving

Reverse of either mode. Status-only is trivial: set `status: active` (or `planning` / `paused`). Physical-archive: move back, fix links, set status.

## Related

- [[New-Project|New project workflow]]
- Vault-root [[CLAUDE]] for the canonical project layout
