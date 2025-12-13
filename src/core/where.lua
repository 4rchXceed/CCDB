local parse_globals = require("src.parser.parse_globals")

local wherecore = {}

function wherecore.appy_where(conditions, current_table)
    local results = {}

    for _, row in ipairs(current_table) do
        local conditions_met = {}

        -- First evaluate all conditions, no matter the type
        for _, condition in ipairs(conditions) do
            local column_value = row[condition.column]
            local condition_value = condition.value
            local operator = condition.operator
            local condition_met = false

            if condition_value == parse_globals.NULL then
                condition_value = nil
            end

            if operator == "=" then
                condition_met = (column_value == condition_value)
            elseif operator == "!=" then
                condition_met = (column_value ~= condition_value)
            elseif operator == ">" then
                condition_met = (column_value > condition_value)
            elseif operator == "<" then
                condition_met = (column_value < condition_value)
            elseif operator == ">=" then
                condition_met = (column_value >= condition_value)
            elseif operator == "<=" then
                condition_met = (column_value <= condition_value)
            elseif operator == "%" then
                ---@diagnostic disable-next-line: need-check-nil
                local pattern = condition_value:gsub("%%", ".*"):gsub("_", ".")
                condition_met = string.match(tostring(column_value), "^" .. pattern .. "$") ~= nil
            else
                print("[ERROR]: Unknown operator '" .. operator .. "' in WHERE clause.")
            end
            table.insert(conditions_met, {
                met = condition_met,
                type = condition.type
            })
        end

        local groups = {}
        local current_and = true
        local first = true

        for i, cond in ipairs(conditions_met) do
            if first then
                current_and = cond.met
                first = false
            else
                if cond.type == "AND" then
                    current_and = current_and and cond.met
                elseif cond.type == "OR" then
                    table.insert(groups, current_and)
                    current_and = cond.met
                end
            end
        end

        -- push last AND group
        table.insert(groups, current_and)

        -- OR all groups
        local stop = false
        local i = 1
        while not stop and i <= #groups do
            if groups[i] then
                table.insert(results, row)
                stop = true
            end
            i = i + 1
        end
    end
    return results
end

return wherecore
