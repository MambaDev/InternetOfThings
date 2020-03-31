local internet = require("lib_internet");
local time = require("lib_time");
local weather = require("lib_weather");

-- lib used
-- rtctime, sntp, cron, http, sjson

local function on_internet_connected()
  print("internet connected - gathering weather for Portsmouth, UK")
  time.clock_synchronization()

  weather.get_weather_by_city_and_country("portsmouth", "uk", function (data)
      for k,v in pairs(data.main) do print(k,v) end
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