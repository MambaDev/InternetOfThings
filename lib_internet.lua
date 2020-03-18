
local INTERNET = {
}

-- configure sets up the events and handlers to ensure that we know when and if we are currently
-- connected or not. Which can later be used to simlify the setup and connection of sockets, http
-- clients and other systems.
local function configure_station(ssid, password, bssid)
  wifi.setmode(wifi.STATION)
  wifi.sta.config({ssid=ssid, pwd=password, auto=false, bssid=bssid}) -- don't auto connect when we setup the conneciton details.
end

-- configures and setups the device to be used as a access point. With the access name and password
-- being specifid.
local function configure_soft_ap(ssid, password)
  wifi.setmode(wifi.SOFTAP)
  wifi.ap.config({ssid=ssid, pwd=password, auth=wifi.WPA2_PSK}) -- don't auto connect when we setup the conneciton details.
end

-- setup the device to be configured as a station and a access point. specifying both the station
-- ssid/password and the access point ssid/passowrd
local function configure_station_ap(station_ssid, station_password, ap_ssid, ap_password)
  wifi.setmode(wifi.STATIONAP)
  wifi.sta.config({ssid=station_ssid, pwd=station_password, auto=false}) -- don't auto connect when we setup the conneciton details.
  wifi.ap.config({ssid=ap_ssid, pwd=ap_password,  auth=wifi.WPA2_PSK})
end

-- connect will attemp to make a connection to the Internet.connection, returning if no connection
-- could be made (timeout) or a connection was made or determined to be connecetd. A boolean
-- expression would be returned. connectedCallback is a function which will be called when the
-- Internet.connection is conencted. disconnectedCallback is a function which will be called when
-- the Internet.connection failed to connect.
local function connect_station(connectedCallback, ipCallback, failedCallback)
  wifi.sta.connect()

  if connectedCallback ~= nil then
    wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, connectedCallback)
  end

  if ipCallback  ~= nil then
    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, ipCallback)
  end

  if failedCallback ~= nil then
    wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, failedCallback)
  end

end

-- getip is just a short hand notation for getting the ip from the wifi sta module.
local function get_station_ip()
  return wifi.sta.getip()
end

local function get_station_status()
  return wifi.sta.status()
end

-- gets the station connection mac address
local function get_station_mac()
  return wifi.sta.getmac()
end

local function get_access_point_ip()
  return wifi.ap.getip()
end

-- gets the access point mac address
local function get_access_point_mac()
  return wifi.ap.getmac()
end

-- gets the current station connection access point. requires the passing of the callback method
-- which will be called with the list of acceess points.
local function get_station_access_point(ap_list_calback)
  wifi.sta.getap(ap_list_calback)
end

INTERNET.configure_soft_ap = configure_soft_ap
INTERNET.configure_station_ap = configure_station_ap
INTERNET.get_access_point_mac = get_access_point_mac
INTERNET.get_access_point_ip = get_access_point_ip

INTERNET.configure_station = configure_station
INTERNET.connect_station = connect_station
INTERNET.get_station_mac = get_station_mac
INTERNET.get_station_access_point = get_station_access_point
INTERNET.get_station_ip = get_station_ip
INTERNET.get_station_status = get_station_status

return INTERNET
