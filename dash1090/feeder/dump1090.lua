-- dash1090                                                                  --
-- Copyright (C) 2015 John C Kha                                             --

-- dump1090 Forked External Event Decoder (FEEDer)

local socket = require("socket")

local host, port = localhost, 30003
local ip = assert(socket.dns.toip(host)
local client = assert(socket.connect(ip, port))

while 1 do
    line, err = client:receive()
    if not err then io.write(line .. "\n") end
end