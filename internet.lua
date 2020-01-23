
local M = {
}

-- configure sets up the events and handlers to ensure that we know when and if we are currently
-- connected or not. Which can later be used to simlify the setup and connection of sockets, http
-- clients and other systems.
local function configure(ssid, password)
  wifi.setmode(wifi.STATION)
  wifi.sta.config({ssid=ssid, pwd=password, auto=false}) -- don't auto connect when we setup the conneciton details.
end

-- connect will attemp to make a connection to the Internet.connection, returning if no connection
-- could be made (timeout) or a connection was made or determined to be connecetd. A boolean
-- expression would be returned. connectedCallback is a function which will be called when the
-- Internet.connection is conencted. disconnectedCallback is a function which will be called when
-- the Internet.connection failed to connect.
local function connect(connectedCallback, failedCallback)
  wifi.sta.connect()

  if connectedCallback ~= nil then
    wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, connectedCallback)
  end

  if failedCallback ~= nil then
    wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, failedCallback)
  end

end

-- getip is just a short hand notation for getting the ip from the wifi sta module.
local function getip()
  return wifi.sta.getip()
end

M.configure = configure
M.connect = connect
M.getip = getip

return M
