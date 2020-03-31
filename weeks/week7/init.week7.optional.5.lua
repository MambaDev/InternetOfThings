-- core implementation requirements (imports).
local internet = require("lib_internet")
local logger = require("lib_logger")
local time = require("lib_time")

-- unit requirements (imports).

-- the function called when everything is setup and ready to go within the NodeMCU.
-- this includes the internet connection, clock synchronization and logger logger
-- setup.
local function on_start()
  logger.info("Starting application")
end

-- log the reason to why the application failed to connect to the internet, or
-- failed to synchronize the clock. Error is typically not very helpful.
local function on_failed(reason)
  logger.infof("application failed to start, reason: %s", to_string(reason))
end

-- When the internet is connected (and we have a ip address) attempt to
-- synchronize the clocks with a remote time synchronization server, when
-- the synchronization has been completed, start the application entry.
local function on_internet_connected()
  time.clock_synchronization(time.uk_time_server, on_start, on_failed)
end

-- 1 second before we start so we have a safe cutoff point, otherwise if a error
-- occurs, you can get stuck in a boot loop that is really hard to get out of.
local start_timer = tmr.create()

start_timer:register(1000, tmr.ALARM_SINGLE,  function ()
  internet.configure_station("The Promise Lan", "DangerZone2018", nil)
  internet.connect_station(nil, on_internet_connected, on_failed)
end)

start_timer:start()
