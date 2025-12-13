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

    -- Because the results is linked to current_table.data, at the end of the function we will have 0 rows in results
    local nbr_deleted = #results

    local indices_to_delete = {}
    for _, row in ipairs(results) do
        for i = 1, #current_table.data do
            local data = current_table.data[i]
            if data["?sysid?"] == row["?sysid?"] then
                table.insert(indices_to_delete, i)
                break
            end
        end
    end

    for i = #indices_to_delete, 1, -1 do
        table.remove(current_table.data, indices_to_delete[i])
    end

    if not tablecheck.check_table(current_table) then
        print("[ERROR]: Delete operation aborted due to table constraint violations (type, not null, etc.).")
        return false
    end

    db.savetable(query_serialized.from, current_table)
    return {
        success = true,
        affected_rows = nbr_deleted
    }
end

return deletecore
