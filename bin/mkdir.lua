local newDir = arg[1]
if not newDir then
    print("Usage: mkdir <name>")
end
if fs.getDir() == "/" and string.sub(newDir,1,4) == "disk" and (string.len(newDir) == 5 or string.len(newDir) == 6) then
    print("Insufficient permissions")
end
if not fs.exists(fs.getDir()..newDir.."/") then
        fs.makeDir(fs.getDir()..newDir.."/")
else
    print("Direcotry already exists!")
end