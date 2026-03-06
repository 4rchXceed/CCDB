# Insert query

The insert query works like this:

```sql
INSERT INTO <table-name> (col1, col2) VALUES (val1, val2);
```

- `col1, col2`: 

## Special cases

- Calc values aren't supported in insert queries, so you can't do something like this:

```sql
INSERT INTO <table-name> (col1, col2) VALUES (val1, val2 + 1);
```

(see [values.md](values.md) for values)

## Example

```sql
INSERT INTO user (username, email) VALUES ('Alice22', 'alice22@example.com');
```
