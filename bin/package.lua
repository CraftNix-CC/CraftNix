--The "package" system is still based on the primitive one used prior to being branded as CraftNix
print("The package manager is not ready for use!")
print("Please re-clone the repo to update")
return
-----------
local makeJson = textutils.serializeJSON
local makeTable = textutils.unserializeJSON
arg[0] = nil
if not arg[1] then
    print("Usage: package [update install remove]")
	return
end
--verify the files exist
if not fs.exists("/etc/packages.d/") then
    fs.makeDir("/etc/packages.d/")
end
if not fs.exists("/etc/packages.d/packages.json") then
    local file = fs.open("/etc/packages.d/packages.json","w")
    file.write(makeJson({
        provided = {},
        installed = {
            base = {
                packageId = "base",
                version = ""
            }
        }
    }))
    file.close()
end
if not fs.exists("/etc/packages.d/mirror.json") then
    local file = fs.open("/etc/packages.d/mirror.json","w")
    file.write(makeJson({
        lastupdated = "1970-01-01 12:00 AM",
        packages = {}
    }))
    file.close()
end
local file = fs.open("/etc/packages.d/mirror.json","r")
local packageList = makeTable(file.readAll())
file.close()
local file = fs.open("/etc/packages.d/packages.json","r")
local meta = makeTable(file.readAll())
file.close()
local updated = meta.updated
local installed = meta.installed
if not meta.provided then
	meta.provided = {}
	for i,v in pairs(installed) do
		meta.provided[v] = {v}
	end
end
local provided = meta.provided
if not meta.conflicts then
	meta.conflicts = {}
end
local conflicts = meta.conflicts
local metadata = ''

local function isProvided(pack)
	for i,v in pairs(provided) do
		for i,v in pairs(v) do
			if v == pack then
				return true
			end
		end
	end
	return false
end
local function hasConflicts(pack)
	for i,v in pairs(conflicts) do
		for _,v in pairs(v) do
			if v == pack then
				return true,i
			end
		end
	end
	return false, ""
end

local function uninstallPackage(pack1)
	if installed[pack1] then
		local pack = installed[pack1]
		if pack.files then
			for i,v in pairs(pack.files) do
				fs.delete(v)
			end
		end
		meta.installed[pack1] = nil
		meta.provided[pack1] = nil
	end
end
local function handleConflict(pack,pack1)
	print(pack.." conflicts with "..pack1)
	print("remove "..pack1.."? y/n")
	local _, a = os.pullEvent("char")
	local doRemove = a == "y"
	if doRemove then
		uninstallPackage(pack1)
	else
		error("unable to create conflicts!",0)
	end
end
local function installPackage(pack)
    local info = installed[pack]
    if info then
        print("Package already installed!")
        print("Did you mean: package update?")
    else
        if packageList.packages[pack] then
			local conflicting = {}
			if hasConflicts(pack) then
				local _,conflicting1 = hasConflicts(pack)
				handleConflict(pack,conflicting1)
			end
			if packageList.packages[pack].conflicts then
				for i,v in pairs(packageList.packages[pack].conflicts) do
					table.insert(conflicting,v)
					if installed[v] then
						handleConflict(pack,v)
					end
				end
			end
            local baseUrl = packageList.packages[pack].assetBase
            print("Installing package "..pack)
			local files = {}
			provided[pack] = {
				pack,
			}
			conflicts[pack] = conflicting
			if packageList.packages[pack].files then
			    for i,v in pairs(packageList.packages[pack].files) do
					local url = v
					local file = ""
					if type(i) == "string" then
						file = i
					else
						file = v
					end
					table.insert(files,file)
					fs.updateFile(file,baseUrl..url)
				end
			end
			if packageList.packages[pack].requires then
				for i,v in pairs(packageList.packages[pack].requires) do
					if not installed[v] and not isProvided(v) then
						installPackage(v)
					end
				end
			end
			if packageList.packages[pack].provides then
				 for i,v in pairs(packageList.packages[pack].provides) do
					table.insert(provided[pack],v)
				 end
			end
            meta.installed[pack] = {
                packageId = pack,
                version = packageList.packages[pack].version,
				requires = packageList.packages[pack].requires,
				files = files,
            }
        else   
            print("Invalid package")
        end
    end
end
local function updatePackage(pack)
    local info = installed[pack]
    if info then
        if packageList.packages[pack].version ~= info.version then
            return true
        else
            return false
        end
    else
        printError("Package not installed")
        return false
    end
end
local function updateList()
	print("Updating package list...")
	local http, response = http.get(metadata)
	if not http then
		print(response)
		return
	end
	packageList = makeTable(http.readAll())
	http.close()
end
if arg[1] == "update" then
	updateList()
    local hasUpdated = false
	local updates = {}
    for i,v in pairs(installed) do
        local a = updatePackage(i)
        if a then
			table.insert(updates,i)
            hasUpdated = true
        end
    end
	for i,v in pairs(updates) do
		uninstallPackage(v)
	end
	for i,v in pairs(updates) do
		installPackage(v)
	end
    if not hasUpdated then
        print("No updates avaliable!")
    end
elseif arg[1] == "install" then
	updateList()
    if not arg[2] then
        print("Usage: package install [name]")
        return
    end
	table.remove(arg,1)
	for i,v in pairs(arg) do
		installPackage(v)
	end
elseif arg[1] == "remove" then
    if not arg[2] then
        print("Usage: package remove [name]")
        return
    end
	table.remove(arg,1)
	for i,v in pairs(arg) do
		print("Uninstalling "..v)
	    uninstallPackage(v)
	end
else
	print("no command specified!")
end
local file = fs.open("/etc/packages.d/mirror.json","w")
file.write(makeJson(packageList))
file.close()

local file = fs.open("/etc/packages.d/packages.json","w")
file.write(makeJson(meta))
file.close()
