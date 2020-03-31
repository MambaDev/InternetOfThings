
local internet = require("lib_internet");
local time = require("lib_time");

-- lib used
-- rtctime, sntp, cron, http, sjson


local function stampTime()
  -- get the stamp of the time from the syncronized clock
  local seconds, microseconds, rate = rtctime.get()
  local time = rtctime.epoch2cal(seconds, microseconds, rate);

  print(string.format("current syncronization time: %04d/%02d/%02d %02d:%02d:%02d", 
    time["year"], time["mon"], time["day"], time["hour"], time["min"], time["sec"]))
end


local function setup_cron_job(schedule_string, callback_function)
  cron.schedule(schedule_string, callback_function);
end

local function on_internet_connected()
  print("internet connected - attempting synctronization")
  time.clock_synchronization()

  setup_cron_job("* * * * *", function ()
    stampTime()
    print("cron job triggered.")
  end)

  setup_cron_job("*/5 * * * *", function ()
    stampTime()
    print("cron (every 5 minutes) job triggered.")
  end)
end

local function on_internet_disconnected()
  print("internet disconnected")
end

local function main()
  internet.configure_station("The Promise Lan", "DangerZone2018", nil)
  internet.connect_station(on_internet_connected, nil, on_internet_disconnected)
end


main()