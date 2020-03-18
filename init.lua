local lights = require("lib_lights")
local buttons = require("lib_button")

local light = lights:create(1, lights.mode.off);

local function on_press()
  light:change_mode(light.mode.on)
  print('pressed')
end

local function on_long_press()
  print('long_pressed')
end

local function on_released()
  light:change_mode(light.mode.off)
  print('released')
end

local function main()
  print('setting up button');
  local button = buttons:create(2, on_press, on_long_press, on_released)

end

main()