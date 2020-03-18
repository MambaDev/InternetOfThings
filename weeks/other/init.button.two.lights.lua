local lights = require("lib_lights")
local buttons = require("lib_button")

-- This works by pressing the button, enabling the first LED on pin 1
-- followed by a long press enabling led on pin 3. Releasing at any 
-- time turns off any lights that are on.
local light = lights:create(1, lights.mode.off);
local light2 = lights:create(3, lights.mode.off);

local function on_press()
  light:change_mode(light.mode.on)
  print('pressed')
end

local function on_long_press()
  light2:change_mode(light2.mode.on);
  print('long_pressed')
end

local function on_released()
  light:change_mode(light.mode.off)
  light2:change_mode(light2.mode.off);
  print('released')
end

local function main()
  buttons:create(2, on_press, on_long_press, on_released)
end

main()