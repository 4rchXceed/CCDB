# Select query

The select query works like this:

```sql
SELECT <col-name>, <other-col-name> FROM <table-name> WHERE <condition> ORDER BY <col-name> ASC|DESC LIMIT <limit-nbr>;
```

- `SELECT <col/other-col-name>`: The name of the columns (ex. `col1, col2`)
- `<table-name>`: The name of the table
- `<condition>`: See [where.md](where.md)
- `ORDER BY <col-name> ASC|DESC`: Sort by col. You can use multiple cols (ex. `ORDER BY col1 ASC, col2 DESC`)
- `LIMIT <limit-nbr>`: Limit to X objects (ex. `LIMIT 1`)

## Examples

```sql
SELECT name, age FROM users WHERE age > 18 ORDER BY age DESC LIMIT 10;
```

This will select the name and age of users where the age is greater than 18, order them by age in descending order, and limit the results to 10 users.
