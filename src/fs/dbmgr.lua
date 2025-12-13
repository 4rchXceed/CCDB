local dbmgr = {}

function dbmgr.opendb(path)
    local db = {}
    f = fs.open(fs.combine(path, "ccdb.json"), "r")
    db.settings = textutils.unserialiseJSON(f.readAll())
    db.path = path
    f.close()
    db.tables = db.settings.tables or {}
    function db.opentable(table_name)
        if not db.tables[table_name] then
            print("[ERROR]: Table " .. table_name .. " does not exist in database.")
            return nil
        end
        f = fs.open(fs.combine(db.path, db.tables[table_name]), "r")
        local table = textutils.unserialiseJSON(f.readAll())
        f.close()
        return table
    end

    function db.savetable(table_name, table)
        local waited = 0
        while fs.exists(fs.combine(db.path, db.tables[table_name]) .. ".lock") == true and waited < 100 do
            sleep(0.1)
            waited = waited + 1
        end

        if waited >= 100 then
            print("[ERROR]: Could not acquire lock for table " .. table_name .. ".")
            return nil
        end

        f = fs.open(fs.combine(db.path, db.tables[table_name]) .. ".lock", "w")
        f.write("lock")
        f.close()

        if not db.tables[table_name] then
            print("[ERROR]: Table " .. table_name .. " does not exist in database.")
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
