local client = {}

function client.set_up(modem)
    rednet.open(modem)
end

-- Sanitize query to prevent injection attacks
function client.safe_query(query)
    return query:gsub("'", "")
end

function client.connect(host)
    client_id = rednet.lookup("ccdb", host)
    if not client_id then
        error("Could not find CCDB server for host '" .. host .. "'.")
    end
    rednet.send(client_id, textutils.serializeJSON({ type = "ping" }), "ccdb")
    local sender_id, message = rednet.receive("ccdb", 5)
    if not sender_id then
        error("No response from CCDB server.")
    end
    local obj = textutils.unserializeJSON(message)
    if obj.type ~= "pong" then
        error("Invalid response from CCDB server.")
    end
    client.srv_host = host
    client.srv_id = sender_id
end

function client.login_db(db, username, password)
    rednet.send(client.srv_id,
        textutils.serializeJSON({ type = "init", dbname = db, username = username, password = password }), "ccdb")
    local sender_id, message = rednet.receive("ccdb", 5)
    if not sender_id then
        error("No response from CCDB server.")
    end
    local obj = textutils.unserializeJSON(message)
    if obj.type ~= "init" then
        error("Invalid response from CCDB server: " .. (obj.message or "unknown error"))
    end
    client.conn_id = obj.conn_id
end

function client.query(query)
    rednet.send(client.srv_id,
        textutils.serializeJSON({ type = "query", conn_id = client.conn_id, query = query }), "ccdb")
    local sender_id, message = rednet.receive("ccdb", 10)
    if not sender_id then
        error("No response from CCDB server.")
    end
    local obj = textutils.unserializeJSON(message)
    if obj.type == "error" then
        return obj.error
    elseif obj.type ~= "result" then
        error("Invalid response from CCDB server.")
    end
    return obj.result
end

return client
