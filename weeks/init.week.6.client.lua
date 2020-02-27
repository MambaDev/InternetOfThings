
local internet = require("internet")

-- ##############################
-- TCP
-- ##############################

local function on_tcp_connection(connection, s)
  print("connected ")

  local hello_timer = tmr.create()

  hello_timer:alarm(1000, tmr.ALARM_AUTO, function ()
    connection:send("testing = chip\n")
  end)
end

local function on_tcp_disconnection(error_code)
  print("disconnected " .. error_code)
end

local function on_tcp_reconnection(error_code)
  print("reconnected " .. error_code)
end

local skip_headers
local chunk
local buffering
local buf

local function on_tcp_receive(connection, data)
  print("data recieved " .. data)

  if skip_headers then
    -- simple logic to filter the HTTP headers
    chunk = chunk..data
    local i, j = string.find(chunk, '\r\n\r\n')

    if i then
      skip_headers = false
      data = string.sub(chunk, j+1, -1)
      chunk = nil
    end
  end

  if not skip_headers then
    buf[#buf+1] = data

    if #buf > 5 then
      -- throttle server to avoid buffer overrun
      connection:hold()

      if buffering then
        buffering = false
        print(chunk)
      end
    end
  end
end

-- ##############################
-- TCP END
-- ##############################

-- ##############################
-- Internet
-- ##############################

local tcp_client = nil

local function on_internet_connected(data)
  print("STA CONNECTED:" .. data.SSID)
end

local function on_internet_got_ip()
  print("STA MAC: " .. internet.get_station_mac())
  print("STA STATUS: " .. internet.get_station_status())

  tcp_client = net.createConnection(net.TCP, 0)

  tcp_client:on("connection", on_tcp_connection)
  tcp_client:on("disconnection", on_tcp_disconnection)
  tcp_client:on("reconnection", on_tcp_reconnection)
  tcp_client:on("receive", on_tcp_receive)

  print("attempting tcp connection")
  tcp_client:connect(80, "192.168.1.65")
end

local function on_internet_disconnected(callback)
  print("internet disconnected, reason: " .. callback.reason)
end

-- ##############################
-- Internet END
-- ##############################

local function main()
  internet.configure_station("The Promise Lan", "DangerZone2018", nil)
  internet.connect_station(on_internet_connected, on_internet_got_ip, on_internet_disconnected)
end

main()
