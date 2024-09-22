for i,v in pairs(fs.list(fs.getDir())) do
    if string.sub(v, 1, 1) ~= "." then
        if fs.getDir() == "/" and  v == "startup.lua" or v == "rom" then
             --skip
         else
             if fs.isDir(fs.getDir()..v) then
                 term.setTextColor(colors.green)
            end
            print(v)
            term.setTextColor(colors.white)
         end
    end
end