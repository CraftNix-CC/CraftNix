local sha256 = dofile("/lib/sha256.lua")

local function main()
  if not user.chkRoot() then print("This command requires root.") return 0 end
	local success = false
	print("")
	term.write("Username: ")
	local username = read()
	term.write("Password: ")
	local password = sha256(read("*"))
	success = user.createUser(username,password)
	if success then print("User created.") else print("User creation failed.") end
	os.run({},"/bin/sh.lua")
end

main()
