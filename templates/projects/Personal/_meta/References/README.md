---
type: references-index
project:
---

# References

Reusable reference material for this project: mockups, screenshots of current/target state, example implementations from elsewhere, architecture diagrams from related systems, sample data, third-party docs you keep coming back to.

Distinct from `../Assets/` — `Assets/` holds inline note attachments (the image you embed in a meeting note). `References/` holds material you'll look up *repeatedly* while working on the project.

## Suggested subfolders

Add subfolders as needed; this list is a starting point, not a contract.

- `Mockups/` — UI mockups, wireframes
- `Screenshots/` — screenshots of the existing or target system
- `Examples/` — example implementations from elsewhere (anonymise as needed)
- `Architecture/` — system diagrams, sequence diagrams, related-system architecture
- `Data/` — sample data, response payloads, fixtures
- `External/` — links to third-party docs you reference often (link, don't copy — unless the doc moves frequently)

## Index

List references here as you add them, or query by tag if you tag them.

```dataview
LIST
FROM "02 - Projects"
WHERE startswith(file.folder, this.file.folder)
  AND file.name != "README"
SORT file.path ASC
```
