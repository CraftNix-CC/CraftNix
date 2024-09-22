local oldErr = printError
local oldPull = os.pullEvent
local oldPullRaw = os.pullEventRaw
_G.os.pullEventOld = oldPull
_G.os.pullEvent = os.pullEventRaw
local version = "4.4"

local function boot()
	term.clear()
	term.setCursorPos(1,1)
	local parentDir = debug.getinfo(1).source:match("@?(.*/)") --https://stackoverflow.com/a/35072122 (getting current file location)
	term.write("L")
	local success, loaded = pcall(loadfile ,parentDir.."boot/loader.lua")
	if success and loaded then
		term.write("I")
		local a,b = pcall(loaded,parentDir,version)
		if not a then
			while true do
				sleep()
			end
		end
	else
		while true do
			sleep()
		end
	end
end
local function overwrite()
    _G.printError = oldErr
    _G.os.pullEvent = oldPullRaw
    _G['rednet'] = nil
	local success, err = pcall(boot)
	if not success then
		printError(err)
		while true do
			sleep()
		end
	end
end
term.clear()
term.setCursorPos(1,1)
_G.printError = overwrite
_G.os.pullEvent = nil