local s = require("src.stdinmgr")

print("Default user/pass: admin/adminpass")

s.wait_and_run("OPEN(dbtest);")
local i = 0

local x = os.clock()

while i < 700 do
	s.wait_and_run("INSERT INTO user (username, email, age) VALUES ('ArchXceed" .. i .. "', 'lyam.zambaz@gmail.com');")
	i = i + 1
end

print("Time taken: " .. (os.clock() - x) .. " seconds")

print("Purging database...")

s.wait_and_run("DELETE FROM user;")
