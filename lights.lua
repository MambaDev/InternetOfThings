local M = {}

local LIGHTS = {
  -- Large LED on chip, called by pin D4.
  LARGE = 4;
  -- Small LED on chip, called by pin D0.
  SMALL = 0;
}

-- ChangeLightState updates a given light state based on the status. The
-- light is the led which is being set. use .LARGE or .SMALL. The status
-- is a boolean expression for on or off. (true for on.)
local function changeLightState(light, status)
  local mode = gpio.HIGH

  if status then mode = gpio.LOW end

  gpio.mode(light, gpio.OUTPUT)
  gpio.write(light, mode)
end

M.changeLightState = changeLightState

M.LARGE = LIGHTS.LARGE
M.SMALL = LIGHTS.SMALL

return M
