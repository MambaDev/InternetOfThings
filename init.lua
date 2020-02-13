
local ddht = require("ddht")
local bbutton = require("button")

-- the local button being pressed.
local button = nil;

local function button_pressed()
  -- increase the brightness throughout a iteration cycle.
  print("BUTTON PRESSED")
end

local function button_long_pressed()
  -- turn on or off the led
  print("BUTTON LONG PRESSED")
end

local function button_released()
  print("BUTTON RELEASED")
end


local function main()
 button = bbutton:create(7, button_pressed, button_long_pressed, button_released)
end

main()
