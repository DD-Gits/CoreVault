# Project Dashboard

## Active work projects

```dataview
TABLE status, area, owner, target_date
FROM "02 - Projects/Work"
WHERE type = "project" AND status != "archived"
SORT file.mtime DESC
```

## Active personal projects

```dataview
TABLE status, area, owner, target_date
FROM "02 - Projects/Personal"
WHERE type = "project" AND status != "archived"
SORT file.mtime DESC
```

## Open project tasks

```dataview
TASK
FROM "02 - Projects"
WHERE !completed
SORT file.mtime DESC
```
