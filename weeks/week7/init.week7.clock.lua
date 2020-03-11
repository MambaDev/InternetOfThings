local internet = require("lib_internet")
local timer_server = "uk.pool.ntp.org";

-- lib used
-- rtctime, sntp, cron, http, sjson

local function stampTime()
  -- get the stamp of the time from the syncronized clock
  local seconds, microseconds, rate = rtctime.get()
  local time = rtctime.epoch2cal(seconds, microseconds, rate);

  print(string.format("current syncronization time: %04d/%02d/%02d %02d:%02d:%02d", 
    time["year"], time["mon"], time["day"], time["hour"], time["min"], time["sec"]))
end

local function clock_syncronization(timer_server)
sntp.sync(timer_server, function (seconds, microseconds, server, info)
    print("synctronization complete with time server: " .. timer_server)
    stampTime()
  end, function (error_int, info_string)
    print("synctronization failed with time server: " .. timer_server, 
      " error: " .. error_int, " info: " .. info_string)
  end)
end


local function on_internet_connected()
  print("internet connected - attempting synctronization")
  clock_syncronization(timer_server)
end

local function on_internet_disconnected()
  print("internet disconnected")
end

local function main()
  internet.configure_station("The Promise Lan", "DangerZone2018", nil)
  internet.connect_station(on_internet_connected, nil, on_internet_disconnected)
end


main()