# Application usage

## Install CraftOS-PC

[Here](https://www.craftos-pc.cc/)

## Upload bin.lua and runstdin.lua

Drag-and-drop bin.lua and runstdin.lua into craftos-pc

## Install the db server
Run:
```bash
bin.lua setup
```

## Run the db server
Run:
```bash
runstdin.lua
```

## Open a db

In this doc, we will use dbtest, it's bundled with the default software
Run in the CCDB term:
```sql
OPEN(dbtest);
```

Use the default user and pass (admin + adminpass)

Then you can type your queries (see queries.md)

## Create a table

You need to use the JSON-format (see [table schema](schema/table.md)) to create a table.

## Configuration (see [config.md](config.md))
