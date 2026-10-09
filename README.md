# CCDB

ComputerCraftDB (CCDB) is a very lightweight SQL-like database management system. It's written 100% in Lua and designed to run within the ComputerCraft mod for Minecraft.

## Specs

- Language: Lua
- CLI + Bundler into 1 file
- Runs on PC with craftos-pc
- Runs on Minecraft with ComputerCraft mod

## Features

- Queries : `SELECT`, `INSERT`, `UPDATE`, `DELETE`
- Conditions : `WHERE` with operators `<`, `>`, `<=`, `>=`, `!=`, `=`, `%` (like)
- Values : `STRING`, `FLOAT`, `INTEGER`, `BOOLEAN`, `CALCULATED`, `NULL`

## Not supported

- SCHEMA modification (CREATE, DROP, ALTER), made with a .json file
- JOINs (and foreign keys)

## Note on security

This app is **NOT** designed to be secure. It is supposed to be used in a minecraft server, which is a trusted environment.

For example, the string sanitation is very bad. It works... but it is not secure.

## Note

If you see a "could not aquire lock" error, simply remove the path/to/your/db/table.json.lock file and try again. This is a known issue that happens when the server crashes while a lock is active, but it can also happen if the server is killed while a lock is active.

## Note 2

Due to json serialization issues, you cannot save more than ~700 entries in a table. I can't do anything about this, it's a limitation of ComputerCraft's json library. If you need to save more than 700 entries, you can split your data into multiple tables. !! 700 entries is for the example `users` table, which has 4 fields. If you have a table with more fields, the limit will be lower.
