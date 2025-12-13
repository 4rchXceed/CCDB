local ccdb_parse = require("src.parser.parser")
local selectcore = require("src.core.select")
local insertcore = require("src.core.insert")
local updatecore = require("src.core.update")
local deletecore = require("src.core.delete")
local runner = {}

function runner.run(query, db)
    serialized_query = ccdb_parse.parse(query)
    if not serialized_query then
        print("[ERROR]: Unable to parse query.")
        return nil; -- I will add error processing later
    end
    if serialized_query.type == "select" then
        return selectcore.select(serialized_query, db)
    elseif serialized_query.type == "insert" then
        return insertcore.insert(serialized_query, db)
    elseif serialized_query.type == "update" then
        return updatecore.update(serialized_query, db)
    elseif serialized_query.type == "delete" then
        return deletecore.delete(serialized_query, db)
    else
        print("[DBG]: Serialized query:")
        print(textutils.serialize(serialized_query))
        print("[ERROR]: Query type '" .. serialized_query.type .. "' not supported yet.")
        return nil; -- I will add error processing later
    end
end

return runner
