
local internet = require("internet")
local ddht = require("ddht")


local d1 = ddht:create(2)

-- ##############################
-- TCP
-- ##############################
local tcp_server = nil

local function tcp_server_connected(connection, data)
  local response = d1:read()

  local buffer = ""

  buffer = buffer ..  "<!DOCTYPE html>"
  buffer = buffer ..  "<html lang='en'>"
  buffer = buffer ..  "<body>"
  buffer = buffer ..  "<h1> Hello, NodeMcu.</h1>"

  if d1:is_reporting() then
    buffer = buffer .. "<div>Reporting: Yes</div>"
  else
    buffer = buffer .. "<div>Reporting: No</div>"
  end

  buffer = buffer .. "<div>Status: " .. d1:status_string() .. " </div>"
  buffer = buffer .. "<div>Temperature: " .. response.temperature .. " </div>"
  buffer = buffer .. "<div>Humidity: " .. response.humidity .. " </div>"
  buffer = buffer ..  "</body>"
  buffer = buffer ..  "</html>"

  connection:send(buffer)
end

local function tcp_server_disconnected(connection, data)
  print("a client disconnected!")
end


local function tcp_server_recieve(connection, data)
  print(data)
end

local function tcp_server_sent(connection, data)
  connection:close()
end


local function tcp_server_listen(connection)
  connection:on("receive", tcp_server_recieve)
  connection:on("connection", tcp_server_connected)
  connection:on("disconnection", tcp_server_disconnected)
  connection:on("sent", tcp_server_sent)

end

-- ##############################
-- TCP END
-- ##############################

-- ##############################
-- Internet
-- ##############################

local function on_internet_connected(data)
  print("station connected, getting ip address: " .. data.SSID)
end

local function on_internet_got_ip()
  print("station ip address gathered: " .. internet.get_station_ip())
  print("station mac address: " .. internet.get_station_mac())
  print("station status: " .. internet.get_station_status())

  tcp_server = net.createServer(net.TCP, 30)

  print("attempting to create a TCP server")
  tcp_server:listen(80, tcp_server_listen)
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
