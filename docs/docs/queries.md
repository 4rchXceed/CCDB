# SQL Queries supported by CCDB

## INSERT (view [queries](queries/insert.md))

```sql
INSERT INTO user (username, email) VALUES ('Alice22', 'alice22@example.com');
```

## UPDATE (view [update](queries/update.md))

```sql
UPDATE user SET email = 'none@none.none' WHERE id = 1;
```

## DELETE (view [delete](queries/delete.md))

```sql
DELETE FROM user WHERE id = 1;
```

## SELECT (view [select](queries/select.md))

```sql
SELECT age *2, username, 'I can , even do this!' FROM user WHERE age = age*2-30 OR username = 'admin';
```

## WHERE CLAUSE (view [where](queries/where.md))

```sql
<query SELECT, UPDATE, DELETE> WHERE id = 1 AND (username = 'admin' OR username = 'Alice22');
```

## Values

To view informations about values (ex. literal, calcul, ...), view [values.md](queries/values.md)

## Syntax

EVERY query FINISHES WITH `;`. You can't make two queries at once (this is **not** possible: `query1; query2;`)

## Note

The queries are **case-sensitive**. For example, `SELECT` is valid, but `select` is not. However, the column names and table names are **not** case-sensitive. For example, `user` and `User` refer to the same table.
