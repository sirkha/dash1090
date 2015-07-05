-- dash1090                                                                  --
-- Copyright (C) 2015 John C Kha                                             --

-- This file listens for messages and colates them into statistics

local _d = require "tek.lib.debug"
local exec = require "tek.lib.exec"

local Stat = {}

-- Class implementation in Lua

function Stat:new(period)
    obj = {
        last = 0,
        first = 1,
        subscribers = {}
    }                        -- Create a table object
    obj.period = period or "none"   -- Set up default parameters
    setmetatable(obj, self)         -- Unknown operations will look in Stat for metamethods
    self.__index = self             -- obj[key] will return Stat[key]
    return obj
end

function Stat:subscribe(key, field, value) 
    value = value or "Text"
    _d.info(key .. " subscribed to " .. self.name)
    self.subscribers[key] = {field = field, value = value}
    return 0
end

function Stat:unsubscribe(key)
    _d.info(key .. " unsubscribed from " .. self.name)
    self.subscribers[key] = nil
end

function Stat:add()
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

function Stat:subtract()
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

function Stat:update() 
    for k, subscriber in pairs(self.subscribers) do
        local newval = tostring(self.last - self.first + 1)
        _d.info(self.name .. " updating " .. k .. " to " .. newval)
        subscriber.field:setValue(subscriber.value, newval)
    end
    return self.last - self.first + 1
end

function Stat.msg_next()
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
        _d.warn("Timer task terminated with " .. time - os.time() .. "s remaining.")
        return "Timer task terminated with " .. time - os.time() .. "s remaining."
    else
        local res = exec.sendport("*p","ui","TALLY,-,"..name)
        exec.wait("t")
        _d.trace("Terminating " .. name)
        return res
    end
end

local StatContainer = {}

function StatContainer:new()
    obj = {}
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function StatContainer.__newindex(table, index, value)
    _d.trace("Creating Stat index " .. index)
    value.name = index
    rawset(table, index, value)
end

local Tally = {}

function Tally:load(tallyfile)
    -- put all statistics in a table for easy storage
    
    self.stats = StatContainer:new()
    self.session_stats = StatContainer:new()
    -- if someone wants to use a statistic, allow tally.statistic instead of 
    -- tally.stats.statistic or tally.session_stats.statistic
    setmetatable(self, { __index = function(_, key) return self.stats[key] or self.session_stats[key] end})
    if tallyfile then
    end
    
    stats = self.stats
    session_stats = self.session_stats
    
    -- if tally file does not contain any statistics that we need, define them.
    stats.day_aircraft = stats.day_aircraft or Stat:new(24*60*60)
    stats.wk_aircraft = stats.wk_aircraft or Stat:new(7*24*60*60)
    stats.mo_aircraft = stats.mo_aircraft or Stat:new(30*24*60*60)
    stats.all_aircraft = stats.all_aircraft or Stat:new()
    
    session_stats.session_msgs = Stat:new()
    session_stats.min_msgs = Stat:new(60)
    
    return self
end

function Tally:unload(tallyfile)
    --TODO Save stats to file
    for stat in stats do
        _d.trace("Cleaning up " ..stat.name)
        if stat.msg_next_task then stat.msg_next_task:terminate() end
    end
    for stat in session_stats do
        if stat.msg_next_task then stat.msg_next_task:terminate() end
    end
end

function Tally:process(msg) 
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

return Tally