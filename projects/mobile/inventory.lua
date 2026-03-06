print("MC Inventory Mobile Application")
local sql_mgr = require("client_lib")
local ccdb_local = require("src.lib_ccdb") -- Used to cache item data locally

if not fs.exists("cfg/dblocation.cfg") then
    print("Rewriting configuration file...")
    file = fs.open("cfg/dblocation.cfg", "w")
    file.writeLine("/db_cache")
    file.close()
else
    file = fs.open("cfg/dblocation.cfg", "r")
    local path = file.readLine()
    file.close()
    if path ~= "/db_cache" then
        print("Updating configuration file...")
        file = fs.open("cfg/dblocation.cfg", "w")
        file.writeLine("/db_cache")
        file.close()
    end
end

if not fs.exists("/db_cache") then
    print("Creating local database cache...")
    fs.makeDir("/db_cache")
    fs.makeDir("/db_cache/cache")
    file = fs.open("/db_cache/cache/ccdb.json", "w")
    file.writeLine('{"tables":{"item":"item.json"},"login":{"root":"root"}}')
    file.close()
    file = fs.open("/db_cache/cache/item.json", "w")
    file.writeLine(
        '{"schema":{"current_sysid":1,"name":"item","indexes":[{"field":"id","type":"pk"},{"field":"id","type":"ai","start":1,"current":1}],"fields":{"id":{"type":["integer"],"nullable":false,"default":null},"item_id":{"type":["varchar",50],"nullable":false,"default":null},"item_count":{"type":["integer"],"nullable":true,"default":0}}},"data":[]}')
    file.close()
end

local SQL_CONNECTION_CREDENTIALS = {
    server = "homeserver_db_01",
    database = "item_db",
    username = "ArchXceed",
    password = "Pa$$w0rd",
}

local MODEM_SIDE = "back" -- For mobile robots, the modem is usually on the back

ccdb_local.opendb("cache")

sql_mgr.set_up(MODEM_SIDE)

local success = pcall(function()
    sql_mgr.connect(SQL_CONNECTION_CREDENTIALS.server)
end)

local connected = success

if connected then
    sql_mgr.login_db(
        SQL_CONNECTION_CREDENTIALS.database,
        SQL_CONNECTION_CREDENTIALS.username,
        SQL_CONNECTION_CREDENTIALS.password
    )
end

print("Connected to database successfully.")

local function cache_items()
    print("Caching item data locally...")
    ccdb_local.run("DELETE FROM item;")
    local all_items = sql_mgr.query("SELECT item_id, item_count FROM item;")
    print("Caching " .. tostring(#all_items) .. " items...")
    local query = "INSERT INTO item (item_id, item_count) VALUES "
    for _, item in ipairs(all_items) do
        query = query .. "('" ..
            ccdb_local.safe_val(item.item_id) .. "', " .. tostring(item.item_count) .. "), "
    end
    query = query:sub(1, -3) .. ";"
    ccdb_local.run(query)
end

if connected then
    cache_items()
else
    print("\n\n")
    print("Could not connect to remote database. Using local cache only.")
    print("\n\n")
end

local function print_help()
    print("Available commands:")
    print("1. help - Show this help message")
    print("2. e - Exit the application")
    print("3. s - Search for an item by its ID")
end

print_help()

local function search()
    print("Enter e to stop searching.")
    io.write("ID:")
    local item_id = io.read()
    if item_id == "e" then
        return true
    end
    local item_id_safe = sql_mgr.safe_query(item_id)
    if connected then
        print("Searching remote database...")
    else
        print("Searching local cache database...")
    end
    local srv_fun = connected and sql_mgr.query or ccdb_local.run
    local res = srv_fun("SELECT item_count, item_id FROM item WHERE item_id % '%" .. item_id_safe .. "%';")
    print("------ Items found ------")
    if res == nil or not res[1] then
        print("No items found with ID containing: " .. item_id)
    else
        for i, item in ipairs(res) do
            print(i ..
                ". ID: " ..
                item.item_id ..
                " | Amount: " .. item.item_count .. " = " .. math.floor(item.item_count / 64 * 10) / 10 .. " stacks")
        end
    end
    print("-------------------------\n")
    return false
end

local stop = false
while not stop do
    io.write("Enter command: ")
    local command = io.read()
    if command == "help" then
        print_help()
    elseif command == "e" then
        stop = true
    elseif command == "s" then
        local stop_search = false
        while not stop_search do
            stop_search = search()
        end
    else
        print("Unknown command. Type 'help' for a list of commands.")
    end
end
