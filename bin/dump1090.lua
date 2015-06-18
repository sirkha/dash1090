#!/usr/bin/env lua

local ui = require "tek.ui"
local Group = ui.Group
local Text = ui.Text

local window = ui.Window:new {
  Orientation = "vertical",
  Title = "dash1090",
  Children = {
    Group:new {
      Legend = "Aircraft",
      Oreintation = "Vertical",
      Children = {
        Group:new {
          Legend="Current",
          Children = {
            Text:new { Text = "6" }
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
