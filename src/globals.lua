local buildnumber_file = fs.open("src/.buildnumber", "r")
local buildnumber = buildnumber_file.readAll()
buildnumber_file.close()

local globals = {
    VERSION = "V0.1.0",
    BUILD = buildnumber
}

return globals
