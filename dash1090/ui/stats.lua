-- dash1090                                                                  --
-- Copyright (C) 2015 John C Kha                                             --

local ui = require "tek.ui"

local Group = ui.Group
local Text = ui.Text

local Stat = ui.Text:newClass { _NAME = "_statistic"}

function Stat:init() 
  self.Class = "statistic"
  self.Mode = self.Mode or "statistic"
  return ui.Text.init(self)
end

function Stat:show()
    if self.Stat then self.Stat:subscribe(tostring(self), self, "Text") end
    Text.show(self)
end

function Stat:hide()
    Text.hide(self)
    if self.Stat then self.Stat:unsubscribe(tostring(self)) end
end


local Window = function (pui, app)

    local txtAircraftCurrent = Stat:new {
        Text = "##",
        Stat = app.tally.min_msgs
    }
    local txtAircraft24hr = Text:new { Text = "##", Tally = app.tally }
    local txtAircraft7d = Text:new { Text = "##", Tally = app.tally }
    local txtAircraftMo = Text:new { Text = "##", Tally = app.tally }
    local txtAircraftAll = Stat:new { 
        Text = "##",
        Stat = app.tally.session_msgs
    }

    local window = ui.Window:new {
      Orientation = "vertical",
      Title = "dash1090",
      Children = {
        Group:new {
          Legend = "Aircraft",
          Children = {
            Group:new {
              Legend="Current",
              Children = {
                txtAircraftCurrent
              }
            },
            Group:new {
              Legend = "Historical",
              Columns = 2,
              Children = {
                Text:new { Class="caption", Text="Day"},    txtAircraft24hr,
                Text:new { Class="caption", Text="Wk"},     txtAircraft7d,
                Text:new { Class="caption", Text="Mo"},     txtAircraftMo,
                Text:new { Class="caption", Text="All"},    txtAircraftAll
              }
            }
          }
        }
      }
    }
    pui.Application:connect(window)
    app:addMember(window)
end

return Window