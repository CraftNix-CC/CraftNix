if arg[1] == "-r" or arg[1] == "--reboot" then
    os.reboot()
else
    os.shutdown()
end