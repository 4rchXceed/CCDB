local runner = require("src.core.run")
local dbmgr = require("src.fs.dbmgr")

db = dbmgr.opendb("src/examples/db01")

stop = false

while not stop do
    line = io.read("l");
    if line == nil or line == "exit" then
        stop = true
    else
        local success, result = pcall(runner.run, line, db)

        print("---- RESULT ----")
        if success then
            if result == nil then
                print("No result.")
            else
                print(textutils.serialize(result))
            end
        else
            print("[ERROR]: " .. result)
        end
    end
end

-- local ccdb_parse = require("src.parser.parser")
-- local r = ccdb_parse.parse(
--     "SELECT * FROM user WHERE name = 'Lyam Zambaz' OR city = 'Paris' AND age >= 18 ORDER BY age LIMIT 2;")
-- print(textutils.serialize(r))
-- f = fs.open("debug_parse.txt", "w")
-- f.write(textutils.serialize(r))
-- f.close()
