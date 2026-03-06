# Delete query

The delete query works like this:

```sql
DELETE FROM <table-name> WHERE <condition>;
```

## Special cases

You can delete all the rows of a table by omitting the `WHERE` clause:

```sql
DELETE FROM <table-name>;
```

(view [where](where.md) for conditions)

## Example

```sql
DELETE FROM user WHERE id = 1;
DELETE FROM user;
```
