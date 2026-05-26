# Work Index

## Key areas

- [[ServiceNow]]
- [[LogicMonitor]]
- [[Azure]]
- [[AI-Agents]]

## Active projects

```dataview
LIST
FROM "02 - Projects/Work"
WHERE type = "project" AND status != "archived"
SORT file.mtime DESC
```

## Recent work notes

```dataview
LIST
FROM "03 - Areas/Work"
SORT file.mtime DESC
LIMIT 20
```

## Open tasks

```dataview
TASK
FROM "02 - Projects/Work" OR "03 - Areas/Work" OR "05 - Tasks"
WHERE !completed
SORT file.mtime DESC
```
