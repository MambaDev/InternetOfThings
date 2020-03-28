-- Core implemation requirements (imports).
local internet = require("lib_internet")
local logger = require("lib_logger")
local time = require("lib_time")

-- Enable debug mode.
logger.debugging = true;

-- Unit requirements (imports).
local adamqtt = require("lib_ada_mqtt")
local lights = require("lib_lights");
-- local ppwm = require("lib_ppwm");

ADAFRUIT_IO_USERNAME = "mambadev"
ADAFRUIT_IO_KEY = "aio_KXFc21Ti8DdEVpWrpFEkcVZlgPjt"

local light = lights:create(3, lights.mode.on);

local function on_mqtt_connected(client)
  client:subscribe("mambadev/feeds/led", nil, function (topic, data)
    if data == "ON" then light:change_mode(lights.mode.on); end;
    if data == "OFF" then light:change_mode(lights.mode.off); end;
  end)
end

-- The function called when everything is setup and ready to go within the nodeMCU.
-- This includes the internet connection, clock syncronization and logger logger
-- setup.
local function on_start()
  logger.info("Application starting - basic application")
  logger.info("Making MQTT connecction")

  local client = adamqtt:create(nil, nil, ADAFRUIT_IO_USERNAME, ADAFRUIT_IO_KEY);
  client:connect(on_mqtt_connected);

end

local function on_failed(reason)
  logger.infof("Application failed to start, reason: %s", reason)
end

local function on_internet_connected()
  time.clock_syncronization(time.UK_TIME_SERVER, on_start, on_failed);
end

-- 1 second before we start so we have a safe cutoff point.
local start_timer = tmr.create()

start_timer:register(1000, tmr.ALARM_SINGLE,  function ()
  internet.configure_station("The Promise Lan", "DangerZone2018", nil)
  internet.connect_station(nil, on_internet_connected, on_failed)
end)

start_timer:start()
