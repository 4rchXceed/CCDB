root = "/"
root_runtime = "src"
JSON = %JSON%
files = textutils.unserialiseJSON(JSON)

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


require(root_runtime .. "." .. "main")
