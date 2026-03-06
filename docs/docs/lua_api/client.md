# Client API (lua)

I provide a Lua API for the client side. ! Only works under Minecraft environment !

## How to install

Copy the `client_lib.lua` file to your project and require it in your code:

```lua
local ccdb_client = require("client_lib")
```

## API Reference

### ccdb_client.set_up

Description:
Set up the rednet modem.

Args:
- `modem`: Modem side ("left", "right", "top", "bottom", "front", "back")

Return:
- nil

Errors:
- None

```lua
ccdb_client.set_up("left")
```

### ccdb_client.safe_query

Description:
Sanitize a string to prevent SQL injection. (not really, just a basic implementation)

Args:
- `str`: The string to sanitize

Return:
- The sanitized string

Errors:
- None

```lua
local safe_str = ccdb_client.safe_query("hello'; DROP TABLE users; --")
```

### ccdb_client.connect

Description:
Connect to a server (no db needed). Make sure the server is OK by sending a ping/pong message.

Args:
- `host`: The host to connect to (rednet host)

Return:
- nil

Errors:
- Host not found
- No response from server (timeout: 5s)
- Invalid response from server (not pong)

```lua
ccdb_client.connect(host) -- I don't remember how the host looks like, check the rednet documentation
```

### ccdb_client.login_db

Description:
Log in to a database. Make sure the database exists and the password/username is correct.

Args:
- `db`: The name of the database to log in to
- `username`: The username to log in with
- `password`: The password to log in with

Return:
- nil

Errors:
- No response from server (timeout: 5s)
- Invalid response from server (not success or error), will print the response

```lua
ccdb_client.login_db("dbtest", "admin", "adminpass")
```

### ccdb_client.query

Description:
Send a query to the server. Make sure the query is valid and the server is ready to receive queries.

Args:
- `query`: The query to send (string)

Return:
- The response from the server (object)

Errors:
- No response from server (timeout: 10s)
- Invalid response from server, won't print the response

```lua
local response = ccdb_client.query("SELECT * FROM users WHERE id = 1")
```