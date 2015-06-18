#!/usr/bin/env lua

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
            Text:new { Class="Caption", Text="24 hr"},    txtAircraft24hr,
            Text:new { Class="Caption", Text="7 day"},    txtAircraft7d,
            Text:new { Class="Caption", Text="1 Mo"},     txtAircraftMo,
            Text:new { Class="Caption", Text="All Time"}, txtAircraftAll
          }
        }
      }
    }
  }
}

local app = ui.Application:new()
ui.Application.connect(window)
app:addMember(window)

app:run()
