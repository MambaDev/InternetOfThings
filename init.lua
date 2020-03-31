-- core implementation requirements (imports).
local internet = require("lib_internet")
local logger = require("lib_logger")
local time = require("lib_time")

-- unit requirements (imports).
local weather = require("lib_weather")
local buttons = require("lib_button")

local state = {
  city = "Portsmouth";
  country = "UK";

  alarmOn = true;
  alarmTime =  "*/10 * * * *";
  alarmTimeSecs = 10;

  lastTriggered =  "Not Triggered Yet";
  timeCronJobEntry = nil;
}

local tcp_server = nil

-- When the timer is triggered, log out the current timer and the current
-- weather for the configured country and city. Calls into remote api for
-- weather.
local function on_digital_alarm_clock_trigger()
  local seconds, microseconds, rate = rtctime.get()
  local c_time = rtctime.epoch2cal(seconds, microseconds, rate)

  local time =  string.format("\t\t  %04d/%02d/%02d %02d:%02d:%02d", c_time["year"],
    c_time["mon"], c_time["day"], c_time["hour"], c_time["min"], c_time["sec"])

  -- Ensure to update the last triggered time, used in the response the api
  -- requests to the server. which is then rendered on the web page.
  state.lastTriggered = time

  logger.info("ALARM ALARM ALARM")
  logger.info (time)

   weather.get_weather_by_city_and_country(state.city, state.country, function (data)
        logger.infof("WEATHER - %s, %s",                state.city, state.country)
        logger.infof(" Feels Like: \t%.2f  \tC",        data.main.feels_like)
        logger.infof("Temperature: \t%.2f  \tC",        data.main.temp)
        logger.infof("   Humidity: \t%d    \tPercent",  data.main.humidity)
        logger.infof("      Windy: \t%d    \tMph",      data.wind.speed)
    end)
end

-- When a user requests to update the country and city via the server tcp
-- connection, attempt to update based on the json response and if they don't
-- exist, use the existing city and country.
local function update_current_country_city(connection, response)
  state.country = response.country or state.country
  state.city = response.city or state.city

  connection:send("updated weather.")
end

local function tcp_receiver(sck, req)
  if req == nil then return end

  -- check if we can parse the json otherwise just return.
  if not pcall(sjson.decode, req) then return end
  local response = sjson.decode(req)

  -- user has the possibility to update the country and city via the tcp socket.
  if response.type ~= nil and response.type == "weather" then
    return update_current_country_city(sck, response)
  end
end

-- Send back the current city, country alarm time and last triggered to any
-- connecting client with tags to ensure the client reads it as html.
local function tcp_connection(sck)
   local response = {"HTTP/1.0 200 OK\r\nServer: NodeMCU on ESP8266\r\nContent-Type: text/html\r\n\r\n"}

  response[#response + 1] ="<!DOCTYPE html>"
  response[#response + 1] ="<html lang='en'>"
  response[#response + 1] ="<body style='margin: 0 auto; text-align: center'>"
  response[#response + 1] ="<h1>Hello, NodeMcu.</h1>"
  response[#response + 1] ="<div>Country: " .. state.country .. "</div>"
  response[#response + 1] ="<div>City: " .. state.city ..  "</div>"
  response[#response + 1] ="<div>Alarm :".. state.alarmTime .. "</div>"
  response[#response + 1] ="<div>Last Triggered: ".. state.lastTriggered ..  "</div>"
  response[#response + 1] ="</body>"

   -- sends and removes the first element from the 'response' table continues to
   -- do this per entry per sent until empty, and closing the socket. This is
   -- the recommended way to not have memory leaks.
  local function send(localSocket)
    if #response > 0 then localSocket:send(table.remove(response, 1))
    else localSocket:close() response = nil end
  end

  sck:on("sent", send)
  send(sck)
end

local function tcp_server_listen(conn)
  conn:on("receive", tcp_receiver)
  conn:on("connection", tcp_connection)
end

-- When the button is pressed normally, turn on the alarm if its not already on,
-- otherwise do nothing.
local function turnOnAlarm()
  if state.alarmOn then return end

  state.alarmOn = true
  logger.infof("setting up alarm with time of: %s", state.alarmTime)
  state.timeCronJobEntry = time.setup_cron_job(state.alarmTime, on_digital_alarm_clock_trigger)
end

-- When the button is pressed long, turn off the alarm if its not already off,
-- otherwise do nothing.
local function turnOffAlarm()
  if not state.alarmOn then return end

  state.alarmOn = false
  logger.infof("turning off alarm with time of: %s", state.alarmTime)
  time.clear_cron_job(state.timeCronJobEntry);
end

-- register the ADC alarm timer, this alarm timer is how the user would be
-- configuring the minutes been the alarm firing, and thus increases the dialer
-- to increase the number of  minutes between firing.
--
-- This is updated every 10 seconds when there is a more than 60 not increase or
-- decrease. Otherwise keep it the same.
local function registerAdcAlarmTrigger()
  local adc_timer = tmr.create();

  adc_timer:register(1000 * 10, 1, function()
    local digitV = adc.read(0)

    local minutes = math.ceil(digitV / 60)

    if math.abs(minutes - state.alarmTimeSecs) > 60 then
      state.alarmTime =  string.format("*/%d * * * *", minutes)
      time.update_cron_job(state.timeCronJobEntry, state.alarmTime);
      state.alarmTimeSecs = minutes;
    end
 end)

  adc_timer:start();

end

-- the function called when everything is setup and ready to go within the NodeMCU.
-- this includes the internet connection, clock synchronization and logger logger
-- setup.
local function on_start()
  logger.infof("ip: %s", internet.get_station_ip())

  state.timeCronJobEntry = time.setup_cron_job(state.alarmTime, on_digital_alarm_clock_trigger)

  buttons:create(2, turnOnAlarm, turnOffAlarm, nil)
  registerAdcAlarmTrigger();

  tcp_server = net.createServer(net.TCP, 30)
  tcp_server:listen(80, tcp_server_listen)
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
