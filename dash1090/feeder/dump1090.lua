-- dash1090                                                                  --
-- Copyright (C) 2015 John C Kha                                             --

-- dump1090 Forked External Event Decoder (FEEDer)

-- local ip = assert(socket.dns.toip(host))

local Feeder = {}

    
function Feeder.run()
    local exec = require "tek.lib.exec"
    local socket = require("socket")
    
    local ip, port = "192.168.24.114", 30003
    local client = assert(socket.connect(ip, port))
    local abort = false
    local lip, lport = client:getsockname()
    io.write(lip .. ":" ..port .. "\n")
    io.write("dump1090: " .. exec.getname() .. "\n")
    
    client:settimeout(5)
    while not terminate do 
        local msg, err = client:receive()
        
        if not err then 
            exec.sendport("*p", "ui", msg)
            local r, s, age = client:getstats()
            client:settimeout(age+5)
        elseif err == "timeout" then
            local r, s, age = client:getstats()
            io.write("..." .. age .. "\n")
            if exec.sendport("*p", "ui", age) then io.write("message sent\n") end
            err = nil
            if exec.waittime(5000,"t") then terminate = true end
            r, s, age = client:getstats()
            client:settimeout(age+5)
        else
            io.write(err .. "\n")
        end
        if exec.getsignals("t") then terminate = true end
    end
    client:close()
end


return Feeder

