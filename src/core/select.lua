local wherecore = require("src.core.where")
local safecalc = require("src.utils.safecalc")

local selectcore = {}

function selectcore.select(query_serialized, db)
    current_table = db.opentable(query_serialized.from)
    local results = {}
    if query_serialized.data.where and next(query_serialized.data.where) then
        local where_filtered = wherecore.appy_where(query_serialized.data.where, current_table.data)
        results = where_filtered
    else
        results = current_table.data
    end

    table.sort(results, function(a, b)
        for _, order_rule in ipairs(query_serialized.data.order_by or {}) do
            local col = order_rule.column
            local order = order_rule.order
            if a[col] ~= b[col] then
                if order == "ASC" then
                    return a[col] < b[col]
                else
                    return a[col] > b[col]
                end
            end
        end
        return false
    end)

    if query_serialized.data.limit then
        local limited_results = {}
        for i = 1, math.min(query_serialized.data.limit, #results) do
            table.insert(limited_results, results[i])
        end
        results = limited_results
    end
    for i, row in ipairs(results) do
        local filtered_row = {}
        for col, value in pairs(row) do
            if col ~= "?sysid?" then
                if not query_serialized.data.return_cols_all then
                    for _, select_col in ipairs(query_serialized.data.return_cols) do
                        if col == select_col.value then
                            filtered_row[col] = value
                        end
                    end
                else
                    filtered_row[col] = value
                end
            end
        end
        for _, select_col in ipairs(query_serialized.data.return_cols or {}) do
            if type(select_col) ~= "table" or select_col.type ~= "column" then
                value = select_col
                if type(value) == "table" and value.type == "calculation" then
                    value = safecalc.safe_calc(value.value, row)
                end
                filtered_row["col_" .. tostring(#filtered_row + 1)] = value -- AS not supported yet
            end
        end
        results[i] = filtered_row
    end
    return results
end

return selectcore
