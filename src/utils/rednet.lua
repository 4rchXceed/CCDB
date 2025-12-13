local rednet_mod
rednet_cfg_module = nil
function rednet_mod.rednet_setup(module_loc)
    rednet_cfg_module = module_loc
    rednet.open(module_loc)
end

function rednet_mod.server(callback, api)
    if not rednet_cfg_module then
        print("Tried to run a server without rednet_setup() called first")
        return
    end
    stop = false
    while not stop do
        res = rednet.receive()
        stop = not callback(res)
    end
end

return rednet_mod
