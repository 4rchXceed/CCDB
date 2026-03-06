# Where conditions

Conditions are used in the `WHERE` clause of a query. They allow you to filter the results based on specific criteria.

## Supported conditions

# < (less than)

# > (greater than)

# <= (less than or equal to)

# >= (greater than or equal to)

# != (not equal to)

# = (equal to)

# % (like)

The like operator allows you to search for a specified pattern in a column. You can use the `%` wildcard to represent any sequence of characters. For example, `name % 'John%'` will match any name that starts with "John". And you can use `_` to represent a single character. For example, `name % 'J_n%'` will match any name that starts with "J", followed by any single character, and then "n".

## Examples

```sql
SELECT name FROM users WHERE age > 18;
```

This will select the name of users where the age is greater than 18.

```sql
SELECT name FROM users WHERE name % 'John%';
```

This will select the name of users where the name starts with "John".

## Concatenation of conditions

You can concatenate conditions using `AND` and `OR`. For example:

```sql
SELECT name FROM users WHERE age > 18 AND name % 'John%' OR name = 'admin';
```

AND has a higher priority than OR. (First: `age > 18 AND name % 'John%'`, then `OR name = 'admin'`)
