if not arg[1] then
    print("Usage: cat <file>")
    return
end
local file = fs.isProgramInPath(fs.getDir(),arg[1])
if file ~= false then
    local data = fs.open(file,"r")
    print(data.readAll())
    data.close()
    return
else
    print("File not found!")
end
