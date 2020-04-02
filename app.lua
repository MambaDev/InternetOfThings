local internet = require("lib_internet")

-- unit requirements (imports).
local pwms = require("lib_ppwm");
local buttons = require("lib_button")

print("module load heap: " .. node.heap())

local light_yellow = pwms:create(5, nil, 0)
local light_green = pwms:create(6, nil, 0)
local light_red = pwms:create(7, nil, 0)
local light_white = pwms:create(8, nil, 0)


-- the function called when everything is setup and ready to go within the NodeMCU.
-- this includes the internet connection, clock synchronization and logger logger
-- setup.
local function on_start()
  print("ip: " .. internet.get_station_ip())

  buttons:create(1, function () light_yellow:transition_to_duty(1024); end, nil,
    function () light_yellow:transition_to_duty(0); end)

  buttons:create(2, function () light_green:transition_to_duty(1024); end, nil,
    function () light_green:transition_to_duty(0); end)
 
  buttons:create(3, function () light_red:transition_to_duty(1024); end, nil,
    function () light_red:transition_to_duty(0); end)

  buttons:create(4, function () light_white:transition_to_duty(1024); end, nil,
    function () light_white:transition_to_duty(0); end)
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
