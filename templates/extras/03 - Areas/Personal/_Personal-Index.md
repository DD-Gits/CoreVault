# Personal Index

## Key areas

- [[Home]]
- [[Health]]
- [[Finance]]

## Active personal projects

```dataview
LIST
FROM "02 - Projects/Personal"
WHERE type = "project" AND status != "archived"
SORT file.mtime DESC
```

## Open personal tasks

```dataview
TASK
FROM "02 - Projects/Personal" OR "03 - Areas/Personal" OR "05 - Tasks"
WHERE !completed
SORT file.mtime DESC
```
