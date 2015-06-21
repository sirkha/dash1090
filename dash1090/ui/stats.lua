-- dash1090                                                                  --
-- Copyright (C) 2015 John C Kha                                             --

local ui = require "tek.ui"

local Group = ui.Group
local Text = ui.Text

local txtAircraftCurrent = Text:new { Text = "##" }
local txtAircraft24hr = Text:new { Text = "##" }
local txtAircraft7d = Text:new { Text = "##" }
local txtAircraftMo = Text:new { Text = "##" }
local txtAircraftAll = Text:new { Text = "##" }

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

return window