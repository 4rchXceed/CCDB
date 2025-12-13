local rednet_mod = {}

local host = nil

if fs.exists("cfg/rednet_host") then
    local f = fs.open("cfg/rednet_host", "r")
    host = f.readLine()
    f.close()
else
    host = "ccdb_server_" .. tostring(math.random(1000, 9999))
    print("Generated rednet host ID: " .. host)
    local f = fs.open("cfg/rednet_host", "w")
    f.writeLine(host)
    f.close()
end

rednet_cfg_module = nil
function rednet_mod.rednet_setup(module_loc)
    rednet_cfg_module = module_loc
    rednet.open(module_loc)
    rednet.host("ccdb", host)
end

function rednet_mod.safe_json(str)
    local success, result = pcall(function() return textutils.unserializeJSON(str) end)
    if success then
        return result
    else
        print("[ERROR]: Failed to parse JSON: " .. tostring(result))
        return nil
    end
end

function rednet_mod.server(callback, stdin_callback)
    if not rednet_cfg_module then
        print("Tried to run a server without rednet_setup() called first")
        return
    end
    local stop = false
    local function server_callback_wrapper()
        clientid, r = rednet.receive("ccdb")
        obj         = rednet_mod.safe_json(r)
        if obj and obj.type and obj.type == "ping" then -- Used to counter the problem if two clients try to connect at once
            rednet.send(clientid, textutils.serializeJSON({ type = "pong" }), "ccdb")
            return
        end
        _, res = pcall(callback, obj)
        if type(res) ~= "table" then
            res = { type = "error", message = res or "Unknown error" }
        end
        rednet.send(clientid, textutils.serializeJSON(res), "ccdb")
    end
    local function stdin_callback_wrapper()
        io.write("ccdb> ")
        local input = io.read("l")
        _, stop = pcall(stdin_callback, input)
    end
    while not stop do
        parallel.waitForAny(server_callback_wrapper, stdin_callback_wrapper)
    end
end

return rednet_mod
