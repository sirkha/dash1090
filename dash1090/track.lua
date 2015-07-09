-- dash1090                                                                  --
-- Copyright (C) 2015 John C Kha                                             --

-- This file listens for messages keeps a list of aircraft currently being
-- tracked

local _d = require "tek.lib.debug"
local exec = require "tek.lib.exec"

-------------------------------------------------------------------------------
-- OVERVIEW:
--  A
-------------------------------------------------------------------------------
local AircraftTracker = {}

-------------------------------------------------------------------------------
--  aircraftTracker = new(period): Returns a new aircraft tracker object that
--   will track aircraft for the period specified (in seconds)
-------------------------------------------------------------------------------
function AircraftTracker:new(period)
    obj = {
        last = 0,
        first = 1,
        subscribers = {}
    }
    obj.period = period or "none"
    setmetatable(obj, self)
    self.__index = self
    return obj
end

-------------------------------------------------------------------------------
--  subscribe(key, field, value, datum): Registers for updates to aircraft
--   data. The datum will be assigned to the value of field. Key is a unique
--   tracker for the subscription.
-------------------------------------------------------------------------------
function AircraftTracker:subscribe(key, field, value, datum) 
    value = value or "Text"
    _d.info(key .. " subscribed to " .. self.name)
    self.subscribers[key] = {
        field = field,
        value = value,
        datum = datum
    }
end

-------------------------------------------------------------------------------
-- unsubscribe(key): Removes field from subscription list.
-------------------------------------------------------------------------------
function AircraftTracker:unsubscribe(key)
    _d.info(key .. " unsubscribed from " .. self.name)
    self.subscribers[key] = nil
end

-------------------------------------------------------------------------------
-- num = add(): Add an aircraft to be tracked. Returns the number of aircraft
--  being tracked.
-------------------------------------------------------------------------------
function AircraftTracker:add()
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
-- num = remove(icao): Remove an aircraft from the tracker. If no icao address
--  is given, remove the oldest aircraft. Returns the number of tracked
--  aircraft.
-------------------------------------------------------------------------------
function AircraftTracker:remove(icao)
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
-- num = update(datum): Update subscriber fields.
-------------------------------------------------------------------------------
function AircraftTracker:update() 
    for k, subscriber in pairs(self.subscribers) do
        local newval = tostring(self.last - self.first + 1)
        _d.info(self.name .. " updating " .. k .. " to " .. newval)
        subscriber.field:setValue(subscriber.value, newval)
    end
    return self.last - self.first + 1
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function AircraftTracker.msg_next()
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

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local Track = {}

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function Track:Process()
    m = {}
    i = 1
    for k, v in string.gmatch(msg[-1] .. ",","([^,]*)(,)")  do
        _d.trace(i .. string.rep(" ", 3 - string.len(i)) .. k)
        m[i] = k
        i = i+1
    end
    return msg
end
