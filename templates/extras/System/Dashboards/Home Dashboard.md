# Home Dashboard

## Today

```dataview
LIST
FROM "01 - Calendar/Daily"
SORT file.name DESC
LIMIT 1
```

## Open work tasks

```dataview
TASK
FROM "02 - Projects/Work" OR "03 - Areas/Work" OR "05 - Tasks"
WHERE !completed
SORT file.mtime DESC
LIMIT 25
```

## Active work projects

```dataview
LIST
FROM "02 - Projects/Work"
WHERE type = "project" AND status != "archived"
SORT file.mtime DESC
```

## Recently modified

```dataview
LIST
FROM ""
SORT file.mtime DESC
LIMIT 20
```
