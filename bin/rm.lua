if not arg[1] then
    print("Usage: rm [file]")
end
local file = fs.getDir()..arg[1]
if fs.exists(file) then
    fs.delete(file)
else
    print("File does not exist")
end