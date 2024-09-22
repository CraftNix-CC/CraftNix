if not arg[1] then
    print("Usage: cd <directory>")
    return
end
local newDir = fs.resolvePath(fs.getDir()..arg[1])
if newDir ~= "/" then
    newDir = newDir.."/"
end
fs.setDir(newDir)