-- http://lua-users.org/wiki/StringTrim

local strutils = {}

function strutils.str_trim(stri)
    return stri:match("^%s*(.-)%s*$")
end

-- Source - https://stackoverflow.com/a
-- Posted by user973713, modified by community. See post 'Timeline' for change history
-- Retrieved 2025-12-12, License - CC BY-SA 4.0

function strutils.strsplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

-- From me
-- Safely replaces a pattern in a string by escaping all non-word characters in the pattern
function strutils.safe_replace(str, pattern, replacement)
    local escaped_pattern = pattern:gsub("(%W)", "%%%1")
    return str:gsub(escaped_pattern, replacement)
end

-- Ik, it's not the best way to do it, but whatever.
-- This is not by me. I don't remember where I found it.
-- It basically splits a string on multiple separators, ignoring those inside quotes.
function strutils.split_on_separators(str, seps, keep_seps)
    local sep_lookup = {}
    for _, s in ipairs(seps) do
        sep_lookup[s] = true
    end

    local result = {}
    local current = {}

    local in_single = false
    local in_double = false

    for token in str:gmatch("%S+") do
        for i = 1, #token do
            local char = token:sub(i, i)
            if char == "'" then in_single = not in_single end
            if char == '"' then in_double = not in_double end
        end

        local inside_quotes = in_single or in_double
        if not inside_quotes and sep_lookup[token] then
            if keep_seps then
                table.insert(result, table.concat(current, " "))
                current = {}
                table.insert(current, token .. " ")
            else
                table.insert(result, table.concat(current, " "))
                current = {}
            end
        else
            table.insert(current, token)
        end
    end

    if #current > 0 then
        table.insert(result, table.concat(current, " "))
    end

    return result
end

function strutils.split_on_single_char(str, char)
    local result = {}
    local current = {}

    local in_single = false
    local in_double = false

    for k, token in pairs(strutils.totable(str)) do
        if token == "'" then in_single = not in_single end
        if token == '"' then in_double = not in_double end

        local inside_quotes = in_single or in_double

        if not inside_quotes and token == char then
            table.insert(result, table.concat(current))
            current = {}
        else
            table.insert(current, token)
        end
    end

    if #current > 0 then
        table.insert(result, table.concat(current))
    end

    return result
end

function strutils.totable(str)
    local t = {}
    str:gsub(".", function(c) table.insert(t, c) end)
    return t
end

return strutils
