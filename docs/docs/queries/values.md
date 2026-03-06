# CCDB Values

## Literals

### STRING

The string literal is a string value. (Enclosed in single quotes '...'). THE STRING SHOULDN'T CONTAIN SINGLE QUOTES. You can't store a string with single quotes in it. If you need to store a string with single quotes, you'll need to replace single quotes with a different character, such as a double quote... Use safe_val to sanitize the string before using it in a query. (see [server API](../lua_api/server.md) and [client API](../lua_api/client.md) for more information on safe_val)

### FLOAT

The float value is a number with a decimal point. (Ex. `3.9`)

### INTEGER

The integer value is a whole number. (Ex. `39`)

### BOOLEAN

The boolean value can be: `TRUE` or `FALSE` (needs to be in uppercase)

### CALCULATED

A calculated value is a value that is calculated from other values. For example, `age + 1` is a calculated value that adds 1 to the age value.

### NULL

The null value represents the column value that is not defined. Writen as `NULL` (needs to be in uppercase).
