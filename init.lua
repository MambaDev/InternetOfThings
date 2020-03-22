-- Core implemation requirements.
local internet = require("lib_internet")
local time = require("lib_time")

-- Unit requirements.
local lights = require("lib_lights")
local buttons = require("lib_button")

local light = lights:create(1, lights.mode.off);

local function on_press() end
local function on_long_press() end
local function on_released() end

-- The function called when everything is setup and ready to go within the nodeMCU.
-- This includes the internet connection, clock syncronization and logger logger
-- setup.
local function on_start() 
  buttons:create(2, on_press, on_long_press, on_released)
end

local function on_internet_connected()
  time.clock_syncronization()
  on_start()
end

-- 1 second before we start so we have a safe cutoff point.
local start_timer = tmr.create()

start_timer:register(1000, tmr.ALARM_SINGLE,  function ()
  internet.configure_station("The Promise Lan", "DangerZone2018", nil)
  internet.connect_station(on_internet_connected)
end)

start_timer:start()