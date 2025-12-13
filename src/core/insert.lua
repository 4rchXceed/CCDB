local tablecheck = require("src.core.tablecheck")
local parseglobals = require("src.parser.parse_globals")

local insertcore = {}

function insertcore.insert(serialized_query, db)
    local table_name = serialized_query.from
    local current_table = db.opentable(serialized_query.from)
    if not current_table then
        print("[ERROR]: Table '" .. table_name .. "' does not exist.")
        return nil
    end

    local columns = serialized_query.data.columns
    local values = serialized_query.data.values
    for _, value_set in ipairs(values) do
        local new_row = {}
        for i, column in pairs(current_table.schema.fields) do
            local col_name = i
            local col_index = nil
            for j, col in ipairs(columns) do
                if col == col_name then
                    col_index = j
                    break
                end
            end
            if col_index then
                if value_set[col_index] == parseglobals.NULL then
                    new_row[col_name] = nil
                else
                    new_row[col_name] = value_set[col_index]
                end
            else
                if column.default ~= nil and column.default ~= nil then
                    new_row[col_name] = column.default
                else
                    local stop = false
                    local index = 1
                    while not stop and index <= #current_table.schema.indexes do
                        local idx = current_table.schema.indexes[index]
                        if idx.field == col_name and idx.type == "ai" then
                            new_row[col_name] = idx.current
                            idx.current = idx.current + 1
                            stop = true
                        end
                        index = index + 1
                    end
                end
            end
        end
        new_row["?sysid?"] = current_table.schema.current_sysid
        current_table.schema.current_sysid = current_table.schema.current_sysid + 1
        table.insert(current_table.data, new_row)
    end

    if not tablecheck.check_table(current_table) then
        print("[ERROR]: Table '" ..
            table_name .. "' integrity check failed after INSERT operation. (Rolling back changes.)")
        return nil
    end
    db.savetable(table_name, current_table)
    return {
        success = true,
        affected_rows = #values
    }
end

return insertcore
