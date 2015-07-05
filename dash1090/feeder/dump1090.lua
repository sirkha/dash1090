-- dash1090                                                                  --
-- Copyright (C) 2015 John C Kha                                             --

-- dump1090 Forked External Event Decoder (FEEDer)

-- local ip = assert(socket.dns.toip(host))

local Feeder = { name = "dump1090"}

    
function Feeder.run()
    local exec = require "tek.lib.exec"
    local socket = require("socket")
    local _d = require "tek.lib.debug"
    _d.level = _d.WARN

    local name = arg[1]
    
    local ip, port = "192.168.24.114", 30003
    local client = assert(socket.connect(ip, port))
    local abort = false
    local lip, lport = client:getsockname()
    
    _d.info("dump1090: " .. exec.getname() .. "\n")
    _d.info("Listening on: " .. lip .. ":" .. port .. "\n")
    dumpfunc = function(...) if _d.INFO >= _d.level then _d.wrout(...) end end
    _d.dump(arg, dumpfunc)
    
    client:settimeout(5)
    
    while not terminate do 
        local msg, err = client:receive()
        
        if not err then 
            exec.sendport("*p", "ui", msg)
            local r, s, age = client:getstats()
            client:settimeout(age+5)
        elseif err == "timeout" then
            local r, s, age = client:getstats()
            _d.warn("No messages in last 5 seconds. Retrying in 5 seconds.")
            exec.sendport("*p", "ui", "FEEDER," .. name .. ",w,timeout," .. age)
            err = nil
            if exec.waittime(5000,"t") then terminate = true end
            r, s, age = client:getstats()
            client:settimeout(age+5)
            _d.info("Retrying. Client age " .. age)
        else
            _d.error(err)
        end
        if exec.getsignals("t") then terminate = true end
    end
    client:close()
end


return Feeder

