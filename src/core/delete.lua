local wherecore = require("src.core.where")
local tablecheck = require("src.core.tablecheck")

local deletecore = {}

function deletecore.delete(query_serialized, db)
    current_table = db.opentable(query_serialized.from)
    if current_table == nil then
        print("[ERROR]: Table '" .. query_serialized.from .. "' does not exist.")
        return false
    end

    if query_serialized.data.where and next(query_serialized.data.where) then
        local where_filtered = wherecore.appy_where(query_serialized.data.where, current_table.data)
        results = where_filtered
    else
        results = current_table.data
    end

    for _, row in ipairs(results) do
        local i = 0
        local stop = false
        while not stop and i < #current_table.data do
            i = i + 1
            local data = current_table.data[i]
            if data["?sysid?"] == row["?sysid?"] then
                table.remove(current_table.data, i)
            end
        end
    end

    if not tablecheck.check_table(current_table) then
        print("[ERROR]: Delete operation aborted due to table constraint violations (type, not null, etc.).")
        return false
    end

    db.savetable(query_serialized.from, current_table)
    return {
        success = true,
        affected_rows = #results
    }
end

return deletecore
