# Server API

This document describes the API for the server side of CCDB. This is used when you don't want to create a server, but rather want to use the server functionality in your own code, for example caching some db datas into the client (like with SQLite in a real-world scenario)

## How to install

Same as the server

```bash
bin setup
```

## Usage

To use the server API, you need to require the `src/lib_ccdb.lua` file in your code:

```lua
local runlib = require("src/lib_ccdb")
```

## API Reference

### runlib.opendb

Description:
Open a database.

Args:
- `name`: The name of the database to open

Returns:
- `db`: The opened database object, or nil if the database could not be opened

Errors:
- None (except for internal db errors)

Returns:
- nil

```lua
runlib.opendb("dbtest")
```

### runlib.run

Description:
Run a query on the database.

Args:
- `query`: The query to run, as a string

Returns:
- `result`: The result of the query, as a table
- `nil`: If the query failed, nil is returned, and an error message is printed to the console

Errors:
- None (except for internal db errors). If the query is invalid, an error message is printed to the console.

```lua
local result = runlib.run("SELECT * FROM users")
```

### runlib.safe_val

Description:
Sanitize a value for use in a query. This is used to prevent SQL injection attacks.

Args:
- `val`: The value to convert

Returns:
- `safe_val`: The sanitized value, as a string

Errors:
- None

```lua
local safe_val = runlib.safe_val("O'Reilly")
-- safe_val will be "OReilly"
```