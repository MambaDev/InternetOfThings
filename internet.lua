
local M = {
  CONNECTED = false;
  IP = {};
}

local function handleConnectionEvent(T)
  print("STA - CONNECTED".." - SSID: "..T.SSID.." - BSSID: "..T.BSSID.." - Channel: "..T.channel)
  M.CONNECTED = true
end

local function handleDisconnectEvent(T)
  print("STA - DISCONNECTED".." - SSID: "..T.SSID.." - BSSID: "..T.BSSID.." - reason: "..T.reason)
  M.CONNECTED = false
end

local function handleGotIpAddressEvent(T)
  print("STA - GOT IP".." - Station IP: "..T.IP.." - Subnet mask: "..T.netmask.." - Gateway IP: "..T.gateway)
  M.IP = T
end

local function configure(ssid, password)
  wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, handleConnectionEvent)
  wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, handleDisconnectEvent)
  wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, handleGotIpAddressEvent)

  wifi.setmode(wifi.STATION)
  wifi.sta.config({ssid=ssid, pwd=password})
end

local function getip()
  return wifi.sta.getip()
end

M.configure = configure
M.getip = getip

return M
