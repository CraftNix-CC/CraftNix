if shell then
	print("Nested shells detected!")
	print("Exiting...")
	return 
end
term.clear()
term.setCursorPos(1,1)
local function splitString(str,toMatch)
	if not toMatch then
		toMatch = "%S"
	end
	local words = {}
	for w in str:gmatch(toMatch.."+") do
		table.insert(words,w)
	end
	return words
end
local function removeFirstIndex(t)
	local newTable = {}
	for i,v in pairs(t) do
		if i ~= 1 then
			table.insert(newTable,v)
		end
	end
	return newTable
end
local romPrograms = {
	edit = "/rom/programs/edit.lua",
	pastebin = "/rom/programs/http/pastebin.lua",
	wget = "/rom/programs/http/wget.lua",
	import = "/rom/programs/import.lua",
	lua = "/rom/programs/lua.lua",

	--aliases
	dir = "/bin/ls.lua",
	mv = "/bin/move.lua",
	cp = "/bin/copy.lua",
}

local makeRequire = (compat and compat.isCapy64) and compat.makeRequire or dofile("rom/modules/main/cc/require.lua").make
local interpret
local runProgram
local parsePath
local runningProgram = ""
local shell = {
	run = function(...)
		local args = {...}
		local command = ""
		for i,v in pairs(args) do
			if type(v) == "string" then
				if i ~= 1 then
					command = command.." "
				end
				command = command..v
			end
		end
		interpret(command)
	end,
	execute = function(progName,...) 
		local program = parsePath(progName)
		runProgram(progName,program,...)
		return 
	 end,
	exit = function(...) return end, --no
	dir = fs.getDir,
	setDir = fs.setDir,
	path = function() return ".:/rom/programs:/rom/programs/http:/bin:/usr/bin" end,
	setPath = function(...) return end,
	resolve = function(progName)
		return parsePath(progName)
	end,
	getRunningProgram = function()
		return runningProgram
	end,
}
function parsePath(progName)
	local name = splitString(progName,"%P")
	local program = ""
	--removed /sbin from this as it isnt in a normal user's path
	if fs.isProgramInPath("/bin/",progName) then
		program = fs.isProgramInPath("/bin/",progName)
	elseif fs.isProgramInPath("/usr/bin/",progName) then
		program = fs.isProgramInPath("/usr/bin/",progName)
	elseif romPrograms[string.lower(progName)] then --move it down so we can add custom versions of ROM programs
		program = romPrograms[string.lower(progName)]
	elseif string.sub(progName,1,1) == "/" then -- if you are trying to use absolute paths you probably know exact filenames
		program = fs.resolvePath(progName)
	elseif name[2] or not fs.exists(fs.getDir()..progName..".lua") then
		program = fs.resolvePath(fs.getDir()..progName)
	else
		program = fs.resolvePath(fs.getDir()..progName..".lua")
	end
	return program
end
function runProgram(name,program,...)
	if name == nil then
		name = program
	end
	local args = {...}
	args[0] = name
	local fakeGlobals = {shell=shell, arg=args}
	fakeGlobals.require, fakeGlobals.package = makeRequire(fakeGlobals,fs.getDir(program))
	_G.os.pullEvent = os.pullEventOld
	runningProgram = program
	local success, response = pcall(os.run,fakeGlobals,program,table.unpack(args))
	runningProgram = ""
	term.fixColorScheme()
	_G.os.pullEvent = os.pullEventRaw
	if not success then
		print(response)
	end
end
function interpret(command)
	if command == "" then return end
	local splitcommand = splitString(command,"%S")
	local args = removeFirstIndex(splitcommand)
	local progName = splitcommand[1]
	local program = parsePath(progName)
	if fs.exists(program) then
		runProgram(progName,program,table.unpack(args))
	else
		print("File not found!")
	end
end
if not fs.exists("/home") then
	fs.makeDir("/home")
end
fs.setDir("/home/")
if fs.exists(user.home()) then
	fs.setDir(user.home())
end
local a,b = pcall(function()
	if fs.exists(user.home().."/.shrc") then
		for line in io.lines(user.home().."/.shrc") do
			local success, err = pcall(interpret,line)
			if not success then
				print(err)
			end
		end
	end
end)

while true do
	term.setCursorBlink(true)
	term.setTextColor(user.currentUserColor())
 	term.write(user.currentUser())
	term.setTextColor(colors.white)
 	term.write("@"..os.hostname())
	term.setTextColour(colours.green)
	local path = fs.getDir()
	if string.sub(path,1,7+#user.currentUser()) == user.home() then
		path = "~"..string.sub(path,8+#user.currentUser(),string.len(path)-1)
	end
	term.write(" "..path.." >")
 	term.setTextColor(colors.white)
  	term.write("") -- beloved hack
	local command = read()
	local success, err = pcall(interpret,command)
	if not success then
		print(err)
	end
end
