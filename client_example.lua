local client = require("client_lib")

io.write("Enter modem side to use (e.g., 'left', 'right'): ")

client.set_up(io.read("l"))

io.write("Enter CCDB server host name: ")
host = io.read("l")
client.connect(host)

io.write("Enter database name: ")
dbname = io.read("l")
io.write("Enter username: ")
username = io.read("l")
io.write("Enter password: ")
password = io.read("l")
client.login_db(dbname, username, password)
print("Connected to database '" .. dbname .. "' as user '" .. username .. "'.")
stop = false

while not stop do
    io.write("ccdb> ")
    line = io.read("l")
    if line == nil or line == "exit" then
        stop = true
    else
        local result_or_error = client.query(line)
        print("---- RESULT ----")
        if type(result_or_error) == "string" then
            print("Error: " .. result_or_error)
        else
            if result_or_error == nil then
                print("No result.")
            else
                print(textutils.serialize(result_or_error))
            end
        end
    end
end
