-- MODULE DOCS: https://nodemcu.readthedocs.io/en/master/modules

local lights = require("lights")
local internet = require("internet")

-- Turns on the large LED on and off followed by turning on the small LED
-- on and off again.
local function lightChange()
  lights.changeLightState(lights.LARGE, true)
  lights.changeLightState(lights.LARGE, false)

  lights.changeLightState(lights.SMALL, true)
  lights.changeLightState(lights.SMALL, false)
end

-- Marks both lights (small and large) as constantly on.
local function lightConstantOn()
  lights.changeLightState(lights.LARGE, true)
  lights.changeLightState(lights.SMALL, true)
end

-- lightLoop creates a timer based on the specified time and calls into light
-- change on each tick (time) and then restarting the timer after each tick.
local function lightLoop(milliseconds)
  local lightTimer = tmr.create()
  lightTimer:register(milliseconds, 1, lightChange)
  lightTimer:start()
end

local function main()
  internet.configure("Stephen", "password")
  print(internet.getip())
end

main()
