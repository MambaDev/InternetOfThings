local internet = require("lib_internet")

-- unit requirements (imports).
local lights = require("lib_lights")
local buttons = require("lib_button")

print("module load heap: " .. node.heap())

local light_yellow =  lights:create(5, lights.mode.off)
local light_green = lights:create(6, lights.mode.off)
local light_red = lights:create(7, lights.mode.off)
local light_white = lights:create(8, lights.mode.off)


-- the function called when everything is setup and ready to go within the NodeMCU.
-- this includes the internet connection, clock synchronization and logger logger
-- setup.
local function on_start()
  print("ip: " .. internet.get_station_ip())

  buttons:create(1, function () light_yellow:change_mode(lights.mode.on); end, nil,
    function () light_yellow:change_mode(lights.mode.off); end)

  buttons:create(2, function () light_green:change_mode(lights.mode.on); end, nil,
    function () light_green:change_mode(lights.mode.off); end)
 
  buttons:create(3, function () light_red:change_mode(lights.mode.on); end, nil,
    function () light_red:change_mode(lights.mode.off); end)

  buttons:create(4, function () light_white:change_mode(lights.mode.on); end, nil,
    function () light_white:change_mode(lights.mode.off); end)
 end

-- log the reason to why the application failed to connect to the internet, or
-- failed to synchronize the clock. Error is typically not very helpful.
local function on_failed(reason) print("internet disconnected") end

-- When the internet is connected (and we have a ip address) attempt to
-- synchronize the clocks with a remote time synchronization server, when
-- the synchronization has been completed, start the application entry.
local function on_internet_connected() on_start() end

-- 1 second before we start so we have a safe cutoff point, otherwise if a error
-- occurs, you can get stuck in a boot loop that is really hard to get out of.
local start_timer = tmr.create()

start_timer:register(1000, tmr.ALARM_SINGLE,  function ()
  internet.configure_station("The Promise Lan", "DangerZone2018", nil)
  internet.connect_station(nil, on_internet_connected, on_failed)
end)

start_timer:start()
