-- dash1090                                                                  --
-- Copyright (C) 2015 John C Kha                                             --

-- This file keeps tallies derived from either messages or subscriptions.

local _d = require "tek.lib.debug"
local exec = require "tek.lib.exec"



-------------------------------------------------------------------------------
-- Class implementation in Lua
--
-------------------------------------------------------------------------------
local Tally = {}

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function Tally:new(period)
    -- Create a table object and set-up parameters
    obj = {
        last = 0,
        first = 1,
        period = period or "none",
        subscribers = {}
    }
    -- Look in the parent class for metamethods
    setmetatable(obj, self)
    -- obj[key] will return Tally[key] if not an index. This means methods of
    -- obj refer to the parent class.
    self.__index = self
    return obj
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function Tally:subscribe(key, field, value) 
    value = value or "Text"
    _d.info(key .. " subscribed to " .. self.name)
    self.subscribers[key] = {field = field, value = value}
    return 0
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function Tally:unsubscribe(key)
    _d.info(key .. " unsubscribed from " .. self.name)
    self.subscribers[key] = nil
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function Tally:add()
    _df = self.name .. " %s %q"
    self.last = self.last + 1
    if self.period ~= "none" then
        self[self.last] = os.time() + self.period
        _d.info(_df:format("time", self[self.last]))
        if not(self.msg_next_task) then
                _d.info(_df:format("executing for", 
                                    self.last .. " @ " .. self[self.last]))
            task = {
                func = self.msg_next,
                taskname = self.name .. self[self.last],
                abort = false
            }
            self.msg_next_task = exec.run(task, self.name, 
                                           self[self.last], _d.level)
        end
    end
    _d.info(_df:format("index range", self.first .. ":" .. self.last))
    return self:update()
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function Tally:subtract()
    _df = self.name .. " %s %q" 
    if self.period ~= "none" then
        _d.info(_df:format("time", self[self.first]))
        while (self.last >= self.first) and (self[self.first] <= os.time()) do
            _d.trace(_df:format("removing", self.first))
            self[self.first] = nil
            self.first = self.first + 1
        end
        if self.msg_next_task:terminate() then
            self.msg_next_task = nil
            if self.last >= self.first then
                _d.info(_df:format("rexecuting for", 
                                    self.first .. " @ " .. self[self.first]))
                task = {
                    func = self.msg_next,
                    taskname = self.name .. self[self.last],
                    abort = false
                }
                self.msg_next_task = exec.run(task, self.name,
                                               self[self.first], _d.level)
            end
        else
            _d.error("Child task failed to end successfully.")
        end
    else
        self.first = self.first + 1
    end
    _d.info(_df:format("index range", self.first .. ":" .. self.last))
    return self:update()
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function Tally:update() 
    for k, subscriber in pairs(self.subscribers) do
        local newval = tostring(self.last - self.first + 1)
        _d.info(self.name .. " updating " .. k .. " to " .. newval)
        subscriber.field:setValue(subscriber.value, newval)
    end
    return self.last - self.first + 1
end

-------------------------------------------------------------------------------
-- msg_next(): Run as a sub process to act as a simple chron daemon, removing
--  items from the tally when they have expired.
-------------------------------------------------------------------------------
function Tally.msg_next()
    local exec = require "tek.lib.exec"
    local _d = require "tek.lib.debug"
    _d.level = tonumber(arg[3])
    
    _d.info("Timer task: " .. exec.getname())
    dumpfunc = function(...) if _d.INFO >= _d.level then _d.wrout(...) end end
    _d.dump(arg, dumpfunc)
    _d.trace("Timer task signals: " .. (exec.getsignals() or "no signals"))
    
    local name = arg[1]
    local time = arg[2]
    
    if exec.waittime((time-os.time())*1000, "t") then
        _d.warn("Timer task terminated with " .. 
                    time - os.time() .. "s remaining.")
        return "Timer task terminated with " ..
                    time - os.time() .. "s remaining."
    else
        local res = exec.sendport("*p","ui","TALLY,-,"..name)
        exec.wait("t")
        _d.trace("Terminating " .. name)
        return res
    end
end

-------------------------------------------------------------------------------
-- Special table that tells its members their key.
-------------------------------------------------------------------------------
local TallySet = {}

-------------------------------------------------------------------------------
-- Create a tally set
-------------------------------------------------------------------------------
function TallySet:new()
    obj = {}
    setmetatable(obj, self)
    self.__index = self
    return obj
end

-------------------------------------------------------------------------------
-- Let the object know its key in the set.
-------------------------------------------------------------------------------
function TallySet.__newindex(table, index, value)
    _d.trace("Creating Tally index " .. index)
    value.name = index
    rawset(table, index, value)
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local Tallies = {}

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function Tallies:load(tallyfile)
    -- put all tallies in a table for easy storage
    
    self.tallies = TallySet:new()
    self.session_tallies = TallySet:new()
    -- if someone wants to use a tally, allow tallies.tally instead of 
    -- tallies.tallies.tally or tally.session_tallies.tally
    mtab = { 
        __index = function(_, key)
            return self.tallies[key] or self.session_tallies[key]
        end
    }
    setmetatable(self, mtab)
    if tallyfile then
    end
    
    tallies = self.tallies
    session_tallies = self.session_tallies
    
    -- if tally file does not contain any tallies that we need, define them.
    tallies.day_aircraft = tallies.day_aircraft or Tally:new(24*60*60)
    tallies.wk_aircraft = tallies.wk_aircraft or Tally:new(7*24*60*60)
    tallies.mo_aircraft = tallies.mo_aircraft or Tally:new(30*24*60*60)
    tallies.all_aircraft = tallies.all_aircraft or Tally:new()
    
    session_tallies.session_msgs = Tally:new()
    session_tallies.min_msgs = Tally:new(60)
    
    return self
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function Tallies:unload(tallyfile)
    --TODO Save tallies to file
    for tally in tallies do
        _d.trace("Cleaning up " ..tally.name)
        if tally.msg_next_task then tally.msg_next_task:terminate() end
    end
    for tally in session_tallies do
        if tally.msg_next_task then tally.msg_next_task:terminate() end
    end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function Tallies:process(msg) 
    m = {}
    i = 1
    for k, v in string.gmatch(msg[-1] .. ",","([^,]*)(,)")  do
        _d.trace(i .. string.rep(" ", 3 - string.len(i)) .. k)
        m[i] = k
        i = i+1
    end
    if string.find(msg[-1],"TALLY,-") then self[m[3]]:subtract() end
    
    self.session_msgs:add()
    self.min_msgs:add()
    return msg
end

return Tallies