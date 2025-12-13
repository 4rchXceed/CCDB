local errmgr = require("src.core.errmgr")

local safecalc = {}

function safecalc.safe_calc(expr, kv_table)
    local str = expr;
    for k, v in pairs(kv_table) do
        str = string.gsub(str, k, tostring(v))
    end
    -- Put space bewteen numbers and operators to avoid concatenation issues
    str = string.gsub(str, "([%d%.]+)([%+%-%*/%%])", "%1 %2")
    str = string.gsub(str, "([%+%%-%*/%%])([%d%.]+)", "%1 %2")
    if string.find(str, "[^%d%.%+%-%*/%% ]") then
        errmgr.error("Unsafe characters detected in expression '" .. expr .. "'.")
        return nil
    end
    local func, err = load("return " .. str)
    if not func then
        errmgr.error("Error compiling expression '" .. expr .. "': " .. err)
        return nil
    end
    local success, result = pcall(func)
    if not success then
        errmgr.error("Error evaluating expression '" .. expr .. "': " .. result)
        return nil
    end
    return result
end

return safecalc
