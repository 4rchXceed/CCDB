
local is_setup = arg[1] == "setup"

local root = "/"
local root_runtime = "src"
local JSON = %JSON%

if not is_setup then
    print("[RUNNER]: Starting CCDB...")
    require(root_runtime .. "." .. "main")
    return
end
local files = textutils.unserialiseJSON(JSON)

for key, val in pairs(files) do
    if val["t"] == 2 then
        fs.makeDir(fs.combine(root, val["p"]))
    end
    if val["t"] == 1 then
        local file = fs.open(fs.combine(root, val["p"]), "w")
        print("[SETUP]: Writing to " .. val["p"])
        file.write(val["c"])
        file.close()
    end
end

print("[SETUP]: Setup complete. You can now run CCDB without the 'setup' argument.")