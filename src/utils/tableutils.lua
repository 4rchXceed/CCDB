-- Table utils

local tableutils = {}

function tableutils.extend(list, otherlist)
    for _, v in ipairs(otherlist) do
        table.insert(list, v)
    end
    return list
end

-- Source - https://stackoverflow.com/a
-- Posted by Chris
-- Retrieved 2025-12-12, License - CC BY-SA 3.0

function tableutils.compare(one, two)
    if type(one) == type(two) then
        if type(one) == "table" then
            if #one == #two then
                -- If both types are the same, both are tables and
                -- the tables are the same size, recurse through each
                -- table entry.
                for loop = 1, #one do
                    if tableutils.compare(one[loop], two[loop]) == false then
                        return false
                    end
                end

                -- All table contents match
                return true
            end
        else
            -- Values are not tables but matching types. Compare
            -- them and return if they match
            return one == two
        end
    end
    return false
end

return tableutils
