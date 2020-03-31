-- core implemation requirements (imports).
local internet = require("lib_internet")
local logger = require("lib_logger")
local time = require("lib_time")

-- unit requirements (imports).

-- the function called when everything is setup and ready to go within the nodemcu.
-- this includes the internet connection, clock syncronization and logger logger
-- setup.
local function on_start()
  logger.info("application starting - basic application")
end

local function on_failed()
  logger.info("application failed to start")
end

local function on_internet_connected()
  time.clock_synchronization(time.uk_time_server, on_start, on_failed);
end

-- 1 second before we start so we have a safe cutoff point.
local start_timer = tmr.create()

start_timer:register(1000, tmr.alarm_single,  function ()
  internet.configure_station("the promise lan", "dangerzone2018", nil)
  internet.connect_station(nil, on_internet_connected, on_failed)
end)

start_timer:start()

