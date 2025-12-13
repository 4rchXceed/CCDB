local parser = {}

local strutils = require("src.utils.strutils")
local parser_globals = require("src.parser.parse_globals")

function parser.analyze_value(value, noerrors)
    for name, pattern in pairs(parser_globals.VALUE_TYPES) do
        local _, _, captured = string.find(value, pattern)
        if captured then
            if name == "STRING" then
                return captured
            elseif name == "FLOAT" then
                return tonumber(captured)
            elseif name == "INTEGER" then
                return tonumber(captured)
            elseif name == "BOOLEAN_TRUE" then
                return true
            elseif name == "BOOLEAN_FALSE" then
                return false
            elseif name == "NULL" then
                return parser_globals.NULL
            elseif name == "CALC" then
                return {
                    type = "calculation",
                    value = captured
                }
            end
        end
    end
    if noerrors then
        return nil
    end
    print("[ERROR]: Unable to analyze value: " .. value)
    return nil
end

function parser.where(query)
    local where_clause = string.match(strutils.str_trim(query), parser_globals.WHERE)
    if where_clause then
        local where_conditions = strutils.split_on_separators(where_clause, { "AND", "OR" }, true)
        local conditions = {}
        for k, where_condition in pairs(where_conditions) do
            local condition = strutils.str_trim(where_condition)
            local condition_type = nil
            if string.sub(condition, 1, 3) == "AND" then
                condition_type = "AND"
                condition = string.sub(condition, 4)
            elseif string.sub(condition, 1, 2) == "OR" then
                condition_type = "OR"
                condition = string.sub(condition, 3)
            end
            condition = strutils.str_trim(condition)
            _, _, col, operator, value = string.find(condition, parser_globals.WHERE_PATTERN)
            if col and operator and value then
                value = parser.analyze_value(strutils.str_trim(value), false)
                if not value then
                    print("[ERROR]: Unable to analyze value in WHERE condition: " .. condition)
                    return nil
                end
                conditions[k] = {
                    type = condition_type,
                    column = col,
                    operator = operator,
                    value = value
                }
            else
                print("[ERROR]: Invalid WHERE condition: " .. condition)
                return nil
            end
        end
        return conditions
    end
    return {}
end

function parser.end_section(query_end)
    local limit_number = nil
    local collumns = {}
    local trimmed_end = strutils.str_trim(query_end)
    if trimmed_end == "" then
        return {
            order_by = collumns,
            limit = limit_number
        }
    end
    trimmed_end = strutils.strsplit(trimmed_end, "LIMIT")[1] -- Remove LIMIT part if present
    local _, _, orders = string.find(trimmed_end, parser_globals.SELECT_ORDER_BY)
    if orders then
        local order_columns = strutils.strsplit(strutils.str_trim(orders), ",")
        for k, col in pairs(order_columns) do
            local column = strutils.str_trim(col)
            local _, _, col_name, order = string.find(column, parser_globals.SELECT_ORDER_BY_SINGLE)
            if col_name and order then
                if order == "" then
                    order = "ASC"
                else
                    if order ~= "ASC" and order ~= "DESC" and order ~= "" then
                        print("[ERROR]: Invalid ORDER BY order: " .. order)
                        return nil
                    end
                    if order == "" then
                        order = "ASC"
                    end
                end

                collumns[k] = {
                    column = col_name,
                    order = order
                }
            else
                print("[ERROR]: Invalid ORDER BY part: " .. column)
            end
        end
    end
    local _, _, limit = string.find(strutils.str_trim(query_end), parser_globals.SELECT_LIMIT)
    if limit then
        limit_number = tonumber(strutils.str_trim(limit))
        if not limit_number then
            print("[ERROR]: Invalid LIMIT number: " .. limit)
            return nil
        end
    end
    return {
        order_by = collumns,
        limit = limit_number
    }
end

function parser.parse_select(query)
    local returned = {}
    local query_filtred = strutils.str_trim(query):gsub("\n[^\n]*$", "")
    _, _, indexes, sqltable = string.find(query_filtred, parser_globals.SELECT_FROM)
    if indexes and sqltable then
        indexes_clean = indexes
        returned = {
            type = "select",
            data = {},
            from = sqltable
        }
        if indexes_clean == "*" then
            indexes_clean = ""
            returned["data"]["return_cols_all"] = true
        else
            local indexes = strutils.split_on_single_char(indexes_clean, ",")
            local cleaned_indexes = {}
            for k, col in pairs(indexes) do
                if string.find(strutils.str_trim(col), parser_globals.COLUMN_NAME) then
                    cleaned_indexes[k] = {
                        type = "column",
                        value = strutils.str_trim(col)
                    }
                else
                    index = parser.analyze_value(strutils.str_trim(col), true)
                    if index == nil then
                        print("[ERROR]: Unable to analyze SELECT index: " .. col)
                        return nil
                    else
                        cleaned_indexes[k] = index
                    end
                end
            end
            returned["data"]["return_cols"] = cleaned_indexes
        end
    else
        print("[ERROR]: Unable to parse SELECT indexes and FROM table.")
        return nil
    end
    local query_cleaned = query_filtred:gsub(parser_globals.SELECT_FROM_ONLY, ""):gsub(";$", ""); -- Remove processed parts and semicolon
    if query_cleaned == "" then
        returned["data"]["where"] = {}
        returned["data"]["limit"] = nil
        return returned
    end
    local where_clause = strutils.split_on_separators(query_cleaned, { "ORDER", "LIMIT" }, false)[1]; -- Remove end section if present
    if string.find(where_clause, parser_globals.WHERE) ~= nil then
        local where_parsed = parser.where(where_clause)
        if not where_parsed then
            print("[ERROR]: Unable to parse WHERE clause.")
            return nil
        end
        returned["data"]["where"] = where_parsed
    else
        returned["data"]["where"] = {}
    end
    query_cleaned = strutils.safe_replace(query_cleaned, where_clause, ""):gsub(";$", ""); -- Remove processed WHERE part and semicolon
    query_cleaned = strutils.str_trim(query_cleaned)
    local ending_parsed = parser.end_section(query_cleaned)
    if not ending_parsed then
        print("[ERROR]: Unable to parse END section.")
        return nil
    end
    returned["data"]["limit"] = ending_parsed["limit"]
    returned["data"]["order_by"] = ending_parsed["order_by"]
    return returned
end

function parser.parse_insert(query)
    local returned = {}
    local query_filtred = strutils.str_trim(query):gsub("\n[^\n]*;$", "")
    _, _, sqltable, columns, values = string.find(query_filtred, parser_globals.INSERT_INTO)
    if sqltable and columns and values then
        local columns_list_raw = strutils.strsplit(strutils.str_trim(columns), ",")
        local values_lists_raw = strutils.split_on_single_char(values, ")")
        local values_lists = {}
        for k, value in pairs(values_lists_raw) do
            local _, _, cleaned_value = string.find(value, parser_globals.INSERT_CLEANUP)
            if cleaned_value then
                local value_items_raw = strutils.split_on_single_char(strutils.str_trim(cleaned_value), ",")
                local value_items = {}
                for _, item in pairs(value_items_raw) do
                    local analyzed_value = parser.analyze_value(strutils.str_trim(item), false)
                    if analyzed_value.type == "calculation" then
                        print("[ERROR]: Calculations are not supported in INSERT values: " .. item)
                        return nil
                    end
                    if analyzed_value == nil then
                        print("[ERROR]: Unable to analyze value in INSERT: " .. item)
                        return nil
                    end
                    table.insert(value_items, analyzed_value)
                end
                table.insert(values_lists, value_items)
            end
        end
        for k, col in pairs(columns_list_raw) do
            columns_list_raw[k] = strutils.str_trim(col:gsub("%(*", ""):gsub("%)*", ""))
        end
        returned = {
            type = "insert",
            data = {
                columns = columns_list_raw,
                values = values_lists
            },
            from = sqltable
        }
    end
    return returned
end

function parser.parse_update(query)
    local returned = {}
    local query_filtred = strutils.str_trim(query):gsub("\n[^\n]*;$", "")
    _, _, sqltable, other_parts = string.find(query_filtred, parser_globals.UPDATE)
    if sqltable and other_parts then
        local query_cleaned = query_filtred:gsub(parser_globals.UPDATE_ONLY, ""):gsub(";$", "")
        local parts = strutils.split_on_separators(query_cleaned, { "WHERE" }, false); -- Remove WHERE if present
        local set_clause = parts[1]
        local set_parts_raw = strutils.split_on_single_char(set_clause, ",")
        local set_parts = {}
        for k, part in pairs(set_parts_raw) do
            local _, _, col, value = string.find(strutils.str_trim(part), parser_globals.UPDATE_PART)
            if col and value then
                local analyzed_value = parser.analyze_value(strutils.str_trim(value), false)
                if analyzed_value == nil then
                    print("[ERROR]: Unable to analyze value in UPDATE SET: " .. value)
                    return nil
                end
                set_parts[k] = {
                    column = col,
                    value = analyzed_value
                }
            else
                print("[ERROR]: Invalid UPDATE SET part: " .. part)
                return nil
            end
        end
        if #parts < 2 then
            parts[2] = ""
        end
        local where_clause = parts[2]:gsub(";$", ""); -- Remove semicolon if present
        local where_parsed = nil
        if where_clause then
            where_parsed = parser.where("WHERE " .. where_clause)
            if not where_parsed then
                print("[ERROR]: Unable to parse WHERE clause in UPDATE.")
                return nil
            end
        end
        returned = {
            type = "update",
            data = {
                set = set_parts,
                where = where_parsed
            },
            from = sqltable
        }
    end
    return returned
end

function parser.parse_delete(query)
    local returned = {}
    local query_filtred = strutils.str_trim(query):gsub("\n[^\n]*;$", "")
    _, _, sqltable, where = string.find(query_filtred, parser_globals.DELETE)
    if sqltable and where then
        local where_parsed = parser.where(where)
        if not where_parsed then
            print("[ERROR]: Unable to parse WHERE clause in DELETE.")
            return nil
        end
        returned = {
            type = "delete",
            data = {
                where = where_parsed
            },
            from = sqltable
        }
    end
    return returned
end

function parser.parse(query)
    local query_type = string.match(strutils.str_trim(query), parser_globals.QUERY_TYPE)
    if query_type == "SELECT" then
        return parser.parse_select(query)
    elseif query_type == "INSERT" then
        return parser.parse_insert(query)
    elseif query_type == "UPDATE" then
        return parser.parse_update(query)
    elseif query_type == "DELETE" then
        return parser.parse_delete(query)
    else
        print("[ERROR]: Unknown query type.")
        return nil
    end
end

return parser
