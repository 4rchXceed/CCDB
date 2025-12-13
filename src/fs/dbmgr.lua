local errmgr = require("src.core.errmgr")


local dbmgr = {}

local base_path = nil

function dbmgr.opendb(path)
    if not string.find(path, "[%a_]+") then
        errmgr.error("Invalid database name: '" .. path)
        return nil
    end
    if not base_path and fs.exists("cfg/dblocation.cfg") then
        local f = fs.open("cfg/dblocation.cfg", "r")
        base_path = f.readAll()
        f.close()
        path = fs.combine(base_path, path)
    elseif not fs.exists("cfg/dblocation.cfg") and not base_path then
        base_path = "src/examples/"
        path = fs.combine(base_path, path)
    else
        path = fs.combine(base_path, path)
    end
    local db = {}
    if not fs.exists(fs.combine(path, "ccdb.json")) then
        errmgr.error("Database path '" .. path .. "' does not exist.")
        return nil
    end
    f = fs.open(fs.combine(path, "ccdb.json"), "r")
    db.settings = textutils.unserialiseJSON(f.readAll())
    db.path = path
    f.close()
    db.tables = db.settings.tables or {}
    db.login = db.settings.login or {}
    function db.opentable(table_name)
        if not db.tables[table_name] then
            errmgr.error("Table " .. table_name .. " does not exist in database.")
            return nil
        end
        f = fs.open(fs.combine(db.path, db.tables[table_name]), "r")
        local table = textutils.unserialiseJSON(f.readAll())
        f.close()
        if #table.data == 0 then
            table.data = {} -- Else we have "attempt to mutate textutils.empty_json_array"
        end
        return table
    end

    function db.auth(login, password)
        if db.login[login] and db.login[login] == password then
            return true
        else
            return false
        end
    end

    function db.savetable(table_name, table)
        local waited = 0
        while fs.exists(fs.combine(db.path, db.tables[table_name]) .. ".lock") == true and waited < 100 do
            sleep(0.1)
            waited = waited + 1
        end

        if waited >= 100 then
            errmgr.error("Could not acquire lock for table " .. table_name .. ".")
            return nil
        end

        f = fs.open(fs.combine(db.path, db.tables[table_name]) .. ".lock", "w")
        f.write("lock")
        f.close()

        if not db.tables[table_name] then
            errmgr.error("Table " .. table_name .. " does not exist in database.")
            return nil
        end
        f = fs.open(fs.combine(db.path, db.tables[table_name]), "w")
        f.write(textutils.serialiseJSON(table))
        f.close()

        fs.delete(fs.combine(db.path, db.tables[table_name]) .. ".lock")
        return true
    end

    return db
end

return dbmgr
