if not arg[1] or not arg[2] then
    print("Usage: copy [file] [destination]")
end
local file = fs.getDir()..arg[1]
local destination = fs.getDir()..arg[2]
if fs.exists(file) then
    fs.copy(file,destination)
else
    print("File does not exist")
end