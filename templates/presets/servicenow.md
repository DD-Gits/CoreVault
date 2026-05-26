---
type: stack-preset
stack: servicenow
status: draft
last-reviewed: 2026-05-25
---

# ServiceNow stack rules

Standing rules for any project that runs JavaScript inside ServiceNow.

> [!info] Draft — please fact-check before relying on it.
> This preset captures rules I'm reasonably confident about for current ServiceNow versions (Washington / Xanadu era), but some details (exact Rhino version pinning, what ES2015+ features the platform may now polyfill, your team's own conventions) need your eyes. Treat as a starting point and trim or extend per project.

## How to reference

From a project's `_meta/CLAUDE.md`, add:

```
@../../../../04 - Resources/AI/Presets/servicenow.md
```

The four `../` climb out of `02 - Projects/<Type>/<Project>/_meta/` to the vault root, then descend into `04 - Resources/AI/Presets/`. Claude Code resolves the reference at session start. Other agents (Codex, ChatGPT) need to follow the link manually.

## Language

- Server-side scripts (Business Rules, Script Includes, Scheduled Jobs, Fix Scripts, Background Scripts, UI Actions running server-side) run on **Rhino** — historically Rhino 1.7.x. Use **ES5-compatible JavaScript only** unless you've explicitly confirmed the target instance supports ES2021 mode (toggle exists in Now Platform but isn't universally on).
- Forbidden under ES5: `const`, `let`, arrow functions (`=>`), template literals, destructuring, `for...of`, spread/rest (`...`), default parameters, optional chaining (`?.`), nullish coalescing (`??`), `Promise`, `async`/`await`, `Array.prototype.includes` / `find` / `findIndex` / `fill`, `Array.from`, `Object.assign`, `Object.values` / `Object.entries`, class syntax.
- Allowed: `var`, function expressions, `for(var i=0; …)` loops, `Array.prototype.indexOf` / `forEach` / `map` / `filter` / `reduce`, `JSON.parse` / `JSON.stringify`, classic `try`/`catch`/`finally`, prototype-based inheritance.
- Use strict equality (`===` / `!==`) by default.

## Logging

- Use `gs.log()` for plain messages, `gs.info()` / `gs.warn()` / `gs.error()` when severity matters.
- Never `console.log` — there is no console in the Rhino runtime; the call silently does nothing useful.
- For interactive debugging during development, `gs.print()` writes to the script execution output panel.
- For user-facing surface, `gs.addInfoMessage()`, `gs.addErrorMessage()` from server-side; `g_form.addInfoMessage()` from client-side.

## GlideRecord

- Always check the return value of `next()` (or use `hasNext()` for lookups that should match zero or one row).
- Use `gr.getValue('field_name')` over `gr.field_name` when the field may be undefined — `getValue` returns `null`, direct access returns the field's display value (a string), which surprises people when the field is empty.
- Use `setLimit(1)` when you only need the first match.
- Avoid `setWorkflow(false)` unless you have a documented reason; it suppresses Business Rules, which can mask real issues.
- `current` is the GlideRecord context inside Business Rules — don't reuse the name as a variable elsewhere.
- Prefer `gr.update()` with a specific field set over `gr.update()` after multiple field assignments when you only meant to change one field — Business Rules see everything that changed.

## Server vs client context

- **Server-side scripts** (Business Rules, Script Includes, Scheduled Jobs, UI Actions with "Client" unchecked) can use `GlideRecord`, `GlideAggregate`, `gs.*` helpers.
- **Client-side scripts** (`onLoad`, `onChange`, `onSubmit`, UI Pages, UI Actions with "Client" checked) cannot use server objects. Use `GlideAjax` to call a server-side Script Include.
- Don't mix the two — `GlideRecord` from a client script throws; `g_form.*` from a Business Rule throws.

## Script Includes

- One class per Script Include unless you have a strong reason otherwise.
- `Accessible from: All application scopes` only when other scopes need it.
- `Client callable: true` only when client-side scripts will call it via `GlideAjax` — otherwise leave false.
- Public methods exposed to `GlideAjax` should be added to the type's `prototype` and prefixed with the standard ServiceNow naming (often `_` prefix means private).

## Conventions

- camelCase for variables and functions; PascalCase for Script Include class names.
- Custom tables: `u_` prefix on table API names.
- Custom fields: `u_` prefix on field names.
- Use descriptive variable names — the script debugger's introspection is limited.
- Wrap blocks of mutations inside Business Rules with `current.setWorkflow(true)` / `false` deliberately, never as a habit.

## Never do

- Never modify out-of-box (OOB) records without a Decision ADR explaining why. OOB changes break upgrades and Update Sets.
- Never use `eval()` — it's technically available but behaves unpredictably in ServiceNow's compiled script context.
- Never hard-code secrets in script content — use System Properties (`gs.getProperty('your.property.name')`) and store the secret value there. For genuinely secret material, use the Credentials table, not plain System Properties.
- Never run untested code in production via Background Scripts — use Scoped Application Studio or Update Sets.

## Project-specific extensions

Per-project rules that don't apply universally should live in that project's `_meta/CLAUDE.md` under "Conventions for this project" or "Never do / common mistakes", not here. This preset is for what's true across *every* ServiceNow project.
