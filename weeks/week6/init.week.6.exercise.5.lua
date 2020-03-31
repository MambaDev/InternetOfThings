-- Core implemation requirements (imports).
local internet = require("lib_internet")
local logger = require("lib_logger")
local time = require("lib_time")

-- Unit requirements (imports).
local tcp_server = nil;

local function tcp_server_connected(connection, data)
  local buffer = ""

  buffer = buffer ..  "<!DOCTYPE html>"
  buffer = buffer ..  "<html lang='en'>"
  buffer = buffer ..  "<body>"
  buffer = buffer ..  "<h1> Hello, NodeMcu.</h1>"

  connection:send(buffer)
end

local function handle_connection_request(connection, data)
  wifi.setmode(wifi.STATION)
  wifi.sta.config({ssid=data.ssid, pwd=data.password, auto=true, bssid=data.bssid})

  connection:send("configuring station")
end

local function tcp_server_recieve(connection, data)
  if data == nil then return end

  local response = sjson.decode(data);

  if response.type ~= nil and response.type == "connect" then
    return handle_connection_request(connection, data)
  end

  connection:send("invalid or no command type specified.")
end

local function tcp_server_listen(connection)
  connection:on("receive", tcp_server_recieve)
end

-- The function called when everything is setup and ready to go within the nodeMCU.
-- This includes the internet connection, clock syncronization and logger logger
-- setup.
local function on_start()
  logger.info("Application starting - basic application")

  tcp_server = net.createServer(net.TCP, 30);
  tcp_server:listen(80, tcp_server_listen);
end

local function on_failed()
  logger.info("Application failed to start")
end

local function on_internet_connected()
  time.clock_synchronization(time.UK_TIME_SERVER, on_start, on_failed);
end

-- 1 second before we start so we have a safe cutoff point.
local start_timer = tmr.create()

start_timer:register(1000, tmr.ALARM_SINGLE,  function ()
  internet.configure_station("The Promise Lan", "DangerZone2018", nil)
  internet.connect_station(nil, on_internet_connected, on_failed)
end)

start_timer:start()
