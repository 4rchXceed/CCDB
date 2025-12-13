local wherecore = require("src.core.where")
local tablecheck = require("src.core.tablecheck")
local parseglobals = require("src.parser.parse_globals")

local updatecore = {}

function updatecore.update(query_serialized, db)
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
        for i, data in ipairs(current_table.data) do
            if data["?sysid?"] == row["?sysid?"] then
                for _, set_clause in ipairs(query_serialized.data.set) do
                    local col_name = set_clause.column
                    local new_value = set_clause.value
                    for _, index in ipairs(current_table.schema.indexes) do
                        if index.field == col_name and index.type == "pk" then
                            print("[ERROR]: Cannot update PRIMARY KEY column '" .. col_name .. "'.")
                            return false
                        end
                    end
                    if new_value == parseglobals.NULL then
                        new_value = nil
                    end
                    current_table.data[i][col_name] = new_value
                end
            end
        end
    end

    if not tablecheck.check_table(current_table) then
        print("[ERROR]: Update operation aborted due to table constraint violations (type, not null, etc.).")
        return false
    end

    db.savetable(query_serialized.from, current_table)
    return {
        success = true,
        affected_rows = #results
    }
end

return updatecore

-- {
--     data = {
--         set = {
--             {
--                 value = "none@none.none",
--                 column = "email"
--             }
--         },
--         where = {
--             {
--                 column = "id",
--                 operator = "=",
--                 value = 1
--             }
--         }
--     },
--     from = "users",
--     type = "update"
-- }
