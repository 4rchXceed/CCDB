# Tools

I provide a few devlopment tools to make your life easier when working with CCDB.

## Stress Tester

Tests the performance of the server by sending a lot of queries at once.

Located at `stress_tester.lua`

## Run STDIN

This is used to quickly run some queries on the server without having to create a client. It reads queries from the standard input and prints the results to the console.

Located at `runstdin.lua`

## "Compiler"

This is NOT a compiler, but rather a tool to convert a directory of LUA files into an "installer" file that can be run on the server. This is useful so you can post ccdb pastebin (computercraft uses a lot pastebin to transfer files) and then run the installer to get all the files in the right place.

It also adds a ".buildnumber" file to the output, which contains the build number of the installer. This is useful for versioning and debugging. (it's just the timestamp of the build)

Located at `compiler.lua`.
