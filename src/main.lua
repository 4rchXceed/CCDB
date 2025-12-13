local stdinmgr = require("src.stdinmgr")
local rednet_mod = require("src.utils.rednet")
local netmgr = require("src.netmgr")

local rednet_module_loc = ""

if fs.exists("cfg/rednet_module") then
    local f = fs.open("cfg/rednet_module", "r")
    rednet_module_loc = f.readLine()
    f.close()
else
    rednet_module_loc = "top"
    print("No rednet module configured, defaulting to '" .. rednet_module_loc .. "'")
    local f = fs.open("cfg/rednet_module", "w")
    f.writeLine(rednet_module_loc)
    f.close()
end

rednet_mod.rednet_setup(rednet_module_loc)


rednet_mod.server(
    netmgr.get_conn,
    stdinmgr.wait_and_run
)

-- stop = false

-- while not stop do
--     io.write("ccdb> ")
--     line = io.read("l")
--     stop = stdinmgr.wait_and_run(line)
-- end
