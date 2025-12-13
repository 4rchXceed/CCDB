local errmgr = require("src.core.errmgr")

local tablecheckcore = {}

function tablecheckcore.check_table(table)
    -- First: check for NOT NULL constraints
    for _, row in ipairs(table.data) do
        for col_name, col_schema in pairs(table.schema.fields) do
            if col_schema.nullable == false and (row[col_name] == nil) then
                errmgr.error("NOT NULL constraint violated for column '" .. col_name .. "'.")
                return false
            end
        end
    end
    -- Second: check for TYPES
    for _, row in ipairs(table.data) do
        for col_name, col_schema in pairs(table.schema.fields) do
            local value = row[col_name]
            if value ~= nil then
                local value_type = col_schema.type[1]

                if value == nil then
                    value_type = "null" -- Handle NULL case
                end

                if value_type == "varchar" then
                    local max_length = col_schema.type[2]
                    if type(value) ~= "string" then
                        errmgr.error("Type constraint violated for column '" .. col_name .. "'. Expected VARCHAR.")
                        return false
                    end
                    if #value > max_length then
                        errmgr.error("Length constraint violated for column '" ..
                            col_name .. "'. Maximum length is " .. max_length .. ".")
                        return false
                    end
                elseif value_type == "int" then
                    if type(value) ~= "number" or value % 1 ~= 0 then
                        errmgr.error("Type constraint violated for column '" .. col_name .. "'. Expected INT.")
                        return false
                    end
                elseif value_type == "float" then
                    if type(value) ~= "number" then
                        errmgr.error("Type constraint violated for column '" .. col_name .. "'. Expected FLOAT.")
                        return false
                    end
                elseif value_type == "boolean" then
                    if type(value) ~= "boolean" then
                        errmgr.error("Type constraint violated for column '" .. col_name .. "'. Expected BOOLEAN.")
                        return false
                    end
                elseif value_type == "null" then
                    if value ~= nil then
                        errmgr.error("Type constraint violated for column '" .. col_name .. "'. Expected NULL.")
                        return false
                    end
                elseif value_type == "text" then
                    if type(value) ~= "string" then
                        errmgr.error("Type constraint violated for column '" .. col_name .. "'. Expected TEXT.")
                        return false
                    end
                end
            end
        end
    end

    -- Check for UNIQUE constraints (and PRIMARY KEY, which is a special case of UNIQUE)

    for i, index_data in ipairs(table.schema.indexes) do
        if index_data.type == "unique" or index_data.type == "pk" then
            local seen_values = {}
            for _, row in ipairs(table.data) do
                local value = row[index_data.field]
                if value ~= nil then
                    if seen_values[value] then
                        errmgr.error("UNIQUE constraint violated for column '" .. index_data.field .. "'.")
                        return false
                    else
                        seen_values[value] = true
                    end
                end
            end
        end
    end
    return true
end

return tablecheckcore
