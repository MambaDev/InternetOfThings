-- Core implemation requirements.
local internet = require("lib_internet")
local time = require("lib_time")

-- Unit requirements.
local lights = require("lib_lights")
local buttons = require("lib_button")
local ddht = require("lib_ddht")

-- This works by pressing the button, enabling the first LED on pin 1
-- followed by a long press enabling led on pin 3. Releasing at any 
-- time turns off any lights that are on.
local light = lights:create(1, lights.mode.off);

local d1 = ddht:create(3)
local sampling_timer = tmr.create();
local sampling = false;

local function sample_ddht()
  local response = d1:read()

  print(string.format("%s - status: %s - dht11 temperature: %s - humidity: %s",
    time.get_time_stamp(), d1:status_string(), response.temperature, response.humidity));
end

sampling_timer:register(5000, tmr.ALARM_AUTO, sample_ddht)

local function on_press() end

local function on_long_press()

  if sampling then
    print(string.format('%s - stopping sampling DH11.', time.get_time_stamp()))
    light:change_mode(light.mode.off);
    sampling_timer:stop()
  else
    print(string.format('%s - starting sampling DH11 again.', time.get_time_stamp()))
    light:change_mode(light.mode.on);
    sampling_timer:start()
    sample_ddht();
  end

  sampling = not sampling;
end

local function on_released() end


local function on_internet_connected()
  print("Internet connected - synchronizing internal clock with: " .. time.UK_TIME_SERVER)
  time.clock_syncronization()

  buttons:create(2, on_press, on_long_press, on_released, 20)
 end

local function on_internet_disconnected()
end

local function main()
  internet.configure_station("The Promise Lan", "DangerZone2018", nil)
  internet.connect_station(on_internet_connected, nil, on_internet_disconnected)
end

-- 1 second before we start so we have a safe cutoff point.
local start_timer = tmr.create()
start_timer:register(1000, tmr.ALARM_SINGLE,  main)
start_timer:start()