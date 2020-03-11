local internet = require("lib_internet");
local time = require("lib_time");

-- lib used
-- rtctime, sntp, cron, http, sjson

local function on_internet_connected()
  print("Internet connected");
  print("Syncronizating with internet clock")
  time.clock_syncronization()
end

local function on_internet_disconnected()
  print("Internet disconnected")
end

local function main()
  internet.configure_station("The Promise Lan", "DangerZone2018", nil)
  internet.connect_station(on_internet_connected, nil, on_internet_disconnected)
end


main()
