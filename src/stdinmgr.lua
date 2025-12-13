local runner = require("src.core.run")
local dbmgr = require("src.fs.dbmgr")
local errmgr = require("src.core.errmgr")

local stdinmgr = {}

local db = nil

function stdinmgr.wait_and_run(line)
    if line == nil or line == "exit" then
        return true
    end
    _, _, dbname = string.find(line, "OPEN%((.*)%);") -- OPEN(xyz); command
    if dbname then
        success, dbtemp = pcall(dbmgr.opendb, dbname)
        if not success then
            print(errmgr.generate_report(dbtemp))
            return
        end
        if dbtemp == nil then
            print("Failed to open database '" .. dbname .. "'.")
            return
        end
        io.write("Username: ")
        username = io.read("l")
        io.write("Password: ")
        password = io.read("l")
        if dbtemp.auth(username, password) == false then
            print("Authentication failed for database '" .. dbname .. "'.")
            return
        end
        db = dbtemp
        print("Database '" .. dbname .. "' opened.")
    else
        if db == nil then
            print("No database opened. Use OPEN(dbname); to open a database.")
            return
        end
        local success, result = pcall(runner.run, line, db)

        print("---- RESULT ----")
        if success then
            if result == nil then
                print("No result.")
            else
                print(textutils.serialize(result))
            end
        else
            print(errmgr.generate_report(result))
        end
    end
end

return stdinmgr
