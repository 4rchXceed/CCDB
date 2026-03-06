# Minecraft Computercraft integration

This page describes how to use CCDB with Minecraft Computercraft.

Apart from CraftOS-PC, you can also run CCDB on a real Minecraft server.

You will need to upload the `bin.lua` files to your ComputerCraft computer, and then run them to start the database server.

```bash
bin.lua setup
```

Then, connect your client to the server in Minecraft with computercraft's "internet" API (rednet)

## Rednet module configuration

Write the rednet module location (top, left, right, back, front) in the `cfg/rednet_module` file.

## Run the DB

Run the bin.lua file to start the database server.

```bash
bin.lua
```

## Client use

See `lua_api/client.md` for the client API documentation.