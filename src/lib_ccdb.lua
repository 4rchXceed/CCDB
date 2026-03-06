-- This is a module used for local database, so no networking
local runner = require("src.core.run")
local dbmgr  = require("src.fs.dbmgr")

local runlib = {}

local db     = nil

function runlib.opendb(name)
    db = dbmgr.opendb(name)
end

function runlib.run(query)
    local _, result = pcall(runner.run, query, db)
    if not result then
        print("Error executing query: " .. tostring(result))
        return nil
    end
    return result
end

function runlib.safe_val(val)
    return val:gsub("'", "")
end

return runlib
