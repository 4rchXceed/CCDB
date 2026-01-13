local globals = require("src.globals")

local err = {}
local cfg = {} -- {dbg = true/false, log = true/false, log_path = "path/to/logfile"}

local errmgr = {}

if fs.exists("config/log.json") then
    local file = fs.open("config/log.json", "r")
    local content = file.readAll()
    file.close()
    cfg = textutils.unserializeJSON(content)
else
    cfg = { dbg = false, log = true, log_path = "logs/error.log" }
    local file = fs.open("config/log.json", "w")
    file.write(textutils.serializeJSON(cfg))
    file.close()
end

function errmgr.error(message)
    local full_msg = message
    if cfg.dbg then
        full_msg = debug.traceback(message, 2)
    end
    if cfg.dbg then
        print("[ERROR]: " .. full_msg)
    end
    if cfg.log then
        local log_message = "[" .. os.date("%Y-%m-%d %H:%M:%S") .. "] " .. full_msg .. "\n"
        local file = fs.open(cfg.log_path, "a")
        file.write(log_message)
        file.close()
    end
    table.insert(err, #err + 1, full_msg)
    error(
        "An error occurred during execution. Check logs for details. (A report should be generated and sent)",
        0)
end

function errmgr.generate_report(error)
    local report = "-------- ERROR REPORT --------\nThe following errors were recorded during execution:\n"
    for i, message in ipairs(err) do
        report = report .. "[" .. i .. "] " .. message .. "\n"
    end
    err = {}
    report = report .. "[" .. (#err + 1) .. "] " .. tostring(error) .. "\n"
    report = report .. "Environment Info:\n"
    report = report .. "CCDB Version: " .. globals.VERSION .. "\n"
    report = report .. "CCDB Server Build: " .. globals.BUILD .. "\n"
    return report
end

return errmgr
