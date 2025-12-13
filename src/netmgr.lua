local runner = require("src.core.run")
local dbmgr = require("src.fs.dbmgr")
local errmgr = require("src.core.errmgr")

local connections = {}

local netmgr = {}

function netmgr.cleanup_old()
    for conn_id, data in pairs(connections) do
        if os.time() - data.start_time > 120 then -- 2 minutes timeout
            connections[conn_id] = nil
        end
    end
end

function netmgr.get_conn(obj)
    netmgr.cleanup_old() -- Clean up old connections
    -- Sample message: { type = "init", dbname = "mydb", username = "user", password = "pass" }
    if obj.type and obj.type == "init" then
        local conn_id = math.random(0, 2147483647)
        local db = dbmgr.opendb(obj.dbname)
        local username = obj.username
        local password = obj.password
        if db == nil then
            return { type = "error", message = "Failed to open database '" .. obj.dbname .. "'." }
        end
        if db.auth(username, password) == false then
            return { type = "error", message = "Authentication failed for database '" .. obj.dbname .. "'." }
        end
        connections[conn_id] = { db = db, start_time = os.time() }
        return { type = "init", conn_id = conn_id }
    end
    if obj.conn_id == nil then
        return { type = "error", message = "No connection ID provided." }
    end
    local data = connections[obj.conn_id]
    if data == nil then
        return { type = "error", message = "Invalid connection ID." }
    end
    data.start_time = os.time() -- Refresh connection time
    local db = data.db
    if obj.type and obj.type == "query" then
        local success, result = pcall(runner.run, obj.query, db)
        if success then
            return { type = "result", result = result }
        else
            return { type = "error", error = errmgr.generate_report(result) }
        end
    end
end

return netmgr
