local internet = require("lib_internet");
local time = require("lib_time");
local weather = require("lib_weather");
local ddht = require("lib_ddht");

-- lib used
-- rtctime, sntp, cron, http, sjson, dht
local d1 = ddht:create(2)

local function on_digital_alarm_clock_trigger()
  local seconds, microseconds, rate = rtctime.get()
  local c_time = rtctime.epoch2cal(seconds, microseconds, rate);

  print("\n########## ALARM ALARM ALARM ##########");
  print(string.format("\t\t  %04d/%02d/%02d %02d:%02d:%02d", c_time["year"], 
    c_time["mon"], c_time["day"], c_time["hour"], c_time["min"], c_time["sec"]))
  print("########## ALARM ALARM ALARM ##########\n");

  local response = d1:read()

  print("########## WEATHER - ROOM #############");
  print(string.format("Temperature: \t%.2f  \tC", response.temperature))
  print(string.format("   Humidity: \t%d    \t", response.humidity) .. "%")
  print("########## WEATHER - ROOM #############\n");

   weather.get_weather_by_city_and_country("portsmouth", "uk", function (data)
        print("###### WEATHER - Portsmouth, UK #######");
        print(string.format(" Feels Like: \t%.2f  \tC", data.main.feels_like))
        print(string.format("Temperature: \t%.2f  \tC", data.main.temp))
        print(string.format("   Humidity: \t%d    \t", data.main.humidity) .. "%")
        print(string.format("      Windy: \t%d    \tMph", data.wind.speed))
        print("###### WEATHER - Portsmouth, UK #######");
    end)
end

local function on_internet_connected()
  print("Internet connected - synchronizing internal clock with: " .. time.UK_TIME_SERVER)
  time.clock_synchronization()

  print("Setting up digital alarm clock corn job: */5 * * * * (every 5 minutes)")
  time.setup_cron_job("*/5 * * * *", on_digital_alarm_clock_trigger)
 end

local function on_internet_disconnected()
  print("internet disconnected")
end

local function main()
  internet.configure_station("The Promise Lan", "DangerZone2018", nil)
  internet.connect_station(on_internet_connected, nil, on_internet_disconnected)
end

main()
