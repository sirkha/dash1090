-- dash1090                                                                  --
-- Copyright (C) 2015 John C Kha                                             --

-- This file listens for messages and colates them into statistics

local Stat = {
    last = -1,
    first = 0,
    subscribers = {}
}

function Stat:new(name, period)
    obj = recalled or {}
    obj.period = period or "none"
    obj.name = name or ""
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Stat:add()
    self.last = self.last + 1
    if self.period ~= "none" then
        self[last] = os.time() + self.period
    end
    return self:update()
end

function Stat:subtract()
    if self.period ~= "none" then
        while self[self.first] < os.time() do
            self[self.first] = nil
            self.first = self.first + 1
        end
    else
        self.first = self.first + 1
    end
    return self:update()
end

function Stat:subscribe(key, field, value) 
    value = value or "Text"
    self.subscribers[key] = {field = field, value = value}
    return 0
end

function Stat:unsubscribe(key)
    self.subscribers[key] = nil
end

function Stat:update() 
    for k, subscriber in pairs(self.subscribers) do
        subscriber.field:setValue(subscriber.value, tostring(self.last - self.first))
    end
    return self.last - self.first
end

local Tally = {}

function Tally:load(tallyfile)
    if tallyfile then
    end
    self.day_aircraft = self.day_aircraft or Stat:new("DAY_AIRCRAFT", 24*60*60)
    self.wk_aircraft = self.wk_aircraft or Stat:new("WK_AIRCRAFT", 7*24*60*60)
    self.mo_aircraft = self.mo_aircraft or Stat:new("MO_AIRCRAFT", 30*24*60*60)
    self.all_aircraft = self.all_aircraft or Stat:new("ALL_AIRCRAFT")
    
    self.session_msgs = Stat:new()
    return self
end

function Tally:process(msg) 
    io.write(msg[-1])
    self.session_msgs:add()
    return msg
end

return Tally