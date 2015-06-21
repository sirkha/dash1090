-- dash1090                                                                  --
-- Copyright (C) 2015 John C Kha                                             --

-- This program is intended to take the output of dump1090 and display
-- statistics and data. The UI is optimized for small screens, and
-- control using either a touchscreen or a 4 button set.

-- This software is released under the MIT License (MIT):

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to 
-- deal in the Software without restriction, including without limitation the
-- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
-- sell copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.

-- This file creates the main application and UI.

local ui = require "tek.ui"

local Group = ui.Group
local Text = ui.Text

local window = require "dash1090.ui.stats"

-- Application Messages

-- * QUIT: Exits the Program
-- * MSG: An undecoded basestation (SBS1) formatted message
-- * 

local app = ui.Application:new()
ui.Application.connect(window)
app:addMember(window)

return app
