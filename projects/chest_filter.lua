local sql_mgr = require("client_lib")

local DROP_TEMP_SIDE = "left"

local SQL_CONNECTION_CREDENTIALS = {
    server = "ccdb_server_1",
    database = "item_db",
    username = "ArchXceed",
    password = "Pa$$w0rd",
}

local MODEM_SIDE = "right"

sql_mgr.set_up(MODEM_SIDE)

sql_mgr.connect(SQL_CONNECTION_CREDENTIALS.server)

sql_mgr.login_db(
    SQL_CONNECTION_CREDENTIALS.database,
    SQL_CONNECTION_CREDENTIALS.username,
    SQL_CONNECTION_CREDENTIALS.password
)

local further_chest = sql_mgr.query("SELECT move FROM chest ORDER BY move DESC LIMIT 1;")


if not further_chest[1] then
    print("No chest found in database.")
    return
end

local further_distance = further_chest[1].move or 0

local function get_item(item_id)
    item_id_safe = sql_mgr.safe_query(item_id)
    local res = sql_mgr.query("SELECT chest, id FROM item WHERE item_id = '" .. item_id_safe .. "' LIMIT 1;")
    if not res[1] then
        return nil
    end
    return res[1]
end

local function look_for_item()
    return turtle.suckUp()
end

local function forward()
    r = turtle.forward()
    if not r then
        local old_slot = turtle.getSelectedSlot()
        turtle.select(1)
        if not turtle.getItemDetail(1) or turtle.getItemDetail(1).count < 32 then
            turtle.suckDown(32)
        end
        turtle.refuel(32)
        turtle.forward()
        turtle.select(old_slot)
    end
end

local function put_items()
    turtle.select(1)
    local table_with_move = {}
    local current_slot = 1
    local has_found = false
    while current_slot < 16 do
        current_slot = current_slot + 1
        turtle.select(current_slot)
        local has_item = look_for_item()
        if has_item then
            local details = turtle.getItemDetail()
            if details then
                local item_info = get_item(details.name)
                if item_info then
                    table_with_move[current_slot] = { item_info.chest, auto = false }
                else
                    table_with_move[current_slot] = { math.random(1, further_distance), auto = true }
                end
                has_found = true
            end
        end
    end
    if not has_found then
        return
    end
    current_x = 0
    local sorted_items = {}
    for slot, chest_info in pairs(table_with_move) do
        table.insert(sorted_items, { slot = slot, chest_index = chest_info[1], auto = chest_info.auto })
    end
    table.sort(sorted_items, function(a, b) return a.chest_index < b.chest_index end)
    for _, item in ipairs(sorted_items) do
        local slot = item.slot
        local chest_index = item.chest_index
        local chests = sql_mgr.query("SELECT move, side FROM chest WHERE id = " .. tostring(chest_index) .. " LIMIT 1;")
        if not chests[1] then
            print("Chest info not found in database for chest index " .. tostring(chest_index) .. ".")
            return
        end
        chest = chests[1]
        turtle.select(slot)
        local i = 0
        while i < chest.move - current_x do
            forward()
            i = i + 1
        end
        current_x = chest.move -- Update current_x to the chest's move distance
        local number_of_items = turtle.getItemDetail().count
        if item.auto then
            sql_mgr.query("INSERT INTO item (item_id, chest, item_count) VALUES ('" ..
                sql_mgr.safe_query(turtle.getItemDetail().name) ..
                "', " .. tostring(chest_index) .. ", " .. tostring(number_of_items) .. ");")
        else
            sql_mgr.query("UPDATE item SET item_count = item_count + " .. tostring(number_of_items) ..
                " WHERE item_id = '" .. sql_mgr.safe_query(turtle.getItemDetail().name) .. "' LIMIT 1;")
        end

        if chest.side == "bottom" then
            turtle.dropDown()
        elseif chest.side == "front" then
            turtle.drop()
        end
    end
    while current_x > 0 do
        turtle.back()
        current_x = current_x - 1
    end
    turtle.select(1)
end

local function get_item_from_chest(item, side, number)
    chest = peripheral.wrap(side)
    if not chest then
        print("No chest found.")
        return
    end
    for slot = 1, chest.size() do
        local item_detail = chest.getItemDetail(slot)
        if item_detail and item_detail.name == item then
            droptemp = peripheral.wrap(DROP_TEMP_SIDE)
            chest.pushItems(peripheral.getName(droptemp), slot, number)
            if DROP_TEMP_SIDE == "left" then
                turtle.turnLeft()
                turtle.suck()
                turtle.turnRight()
            else
                turtle.turnRight()
                turtle.suck()
                turtle.turnLeft()
            end
            return
        end
    end
end

local function give_item(item_id, number)
    turtle.select(1)
    local item = get_item(item_id)
    if not item then
        print("Item not found in database.")
        return
    end
    local chests_info = sql_mgr.query("SELECT move, side FROM chest WHERE id = " .. tostring(item.chest) .. " LIMIT 1;")
    if not chests_info[1] then
        print("Chest info not found in database.")
        return
    end
    local chest_info = chests_info[1]
    local i = 0
    while i < chest_info.move do
        forward()
        i = i + 1
    end
    get_item_from_chest(item_id, chest_info.side, number)
    sql_mgr.query("UPDATE item SET item_count = item_count - " .. tostring(number) ..
        " WHERE id = '" .. item.id .. "';") -- LIMIT 1 not supported for UPDATE
    i = 0
    while i < chest_info.move do
        turtle.back()
        i = i + 1
    end
    turtle.select(1)
    turtle.turnLeft()
    turtle.turnLeft()
    turtle.drop()
    turtle.turnLeft()
    turtle.turnLeft()
    sql_mgr.query("DELETE FROM item WHERE item_count <= 0;")
end

local function choose(query)
    local query_safe = sql_mgr.safe_query(query)
    local res = sql_mgr.query("SELECT item_id, item_count FROM item WHERE item_id % '%" .. query_safe .. "%';") -- % = LIKE
    local result_str = "Items found:\n"
    for i, row in ipairs(res) do
        result_str = result_str .. tostring(i) .. ". " .. row.item_id .. " (Count: " .. tostring(row.item_count) .. ")\n"
    end
    print(result_str)
    io.write("Choose item number (c = cancel): ")
    local choice_input = io.read()
    if choice_input == "c" then
        return nil
    end
    local choice = tonumber(choice_input)
    if not choice or choice < 1 or choice > #res then
        print("Invalid choice.")
        return nil
    end
    return res[choice].item_id
end

while true do
    local requ = io.read()
    if requ == "put" then
        put_items()
    elseif string.sub(requ, 1, 4) == "get " then
        local extracted = string.sub(requ, 5)
        local _, _, r_item_id, number = string.find(extracted, "([%a:_%d]+)%s+(%d+)")
        if r_item_id then
            local item_id = choose(r_item_id)
            if item_id then
                print("Getting " .. tostring(number) .. " of item " .. item_id)
                give_item(item_id, tonumber(number))
            end
        end
    elseif requ == "exit" then
        break
    elseif requ == "status" then
        local res = sql_mgr.query("SELECT item_id, item_count FROM item;")
        local result_str = "Items in database:\n"
        for i, row in ipairs(res) do
            result_str = result_str ..
                tostring(i) .. ". " .. row.item_id .. " (Count: " .. tostring(row.item_count) .. ")\n"
        end
        result_str = result_str .. "Total unique items: " .. tostring(#res) .. "\n"
        print(result_str)
        print("Total chests: " .. tostring(further_distance))
        print("Fuel level: " .. tostring(turtle.getFuelLevel()))
    end
end
