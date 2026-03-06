# Database creation

## The json schema for database creation is this:

```json
{
  "tables": {
    "table1": "table1.json"
  },
  "login": {
    "username": "password"
  }
}
```

## Explanation

- `tables`: Here, we register the tables of the database. (name-of-table: "name-of-table.json"). For the table schema, see [table.md](table.md)
- `login`: Here, we register the login credentials for the database. The username is the key and the password is the value. (ex. `"admin": "admin123"`)
