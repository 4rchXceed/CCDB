local wherecore = require("src.core.where")

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
                filtered_row[col] = value
            end
        end
        results[i] = filtered_row
    end
    return results
end

return selectcore
