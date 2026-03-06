## Update query

The update query works like this:

```sql
UPDATE <table-name> SET <col-name> = <value>, <other-col-name> = <other-value> WHERE <condition>;
```

- `UPDATE <table-name>`: The name of the table
- `SET <col-name> = <value>, <other-col-name> = <other-value>`: The name of the columns and the new values (ex. `col1 = 'new value', col2 = 42`)
- `<condition>`: See [where.md](where.md)

## Special case: update with no condition

The update query can also be used without a condition. In this case, all the rows of the table will be updated with the new values. For example:

```sql
UPDATE users SET age = age + 1;
```

## Note: The update values **can** use calculations. For example:

```
UPDATE user SET age = 0 WHERE age = NULL;
```
