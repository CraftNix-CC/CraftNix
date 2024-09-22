-- This is the new and improved init system!
-- I'm trying to make a better system for loading daemons and services like systemd
-- What's an OS without background tasks
local sha256 = dofile("/lib/sha256.lua")

local function main()
	local success = false
	local attempts = 0
	print("")
	print("Login on device "..os.hostname())
	while not success do
		if attempts > 0 then
			printError("Incorrect username or password")
			print("")
		end
		if attempts > 3 then
			printError("Too many login attempts")
			print("")
			sleep(1)
			os.shutdown()
		end
		term.write("Username: ")
		local username = read()
		term.write("Password: ")
		local password = sha256(read("*"))
		success = user.login(username,password)
		attempts = attempts + 1
	end
	os.run({},"/bin/sh.lua")
end

main()
