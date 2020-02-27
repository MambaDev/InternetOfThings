
local internet = require("internet")

local function on_internet_connected()
  print("internet connected")

  internet.get_station_access_point(function (t)
    -- (SSID : Authmode, RSSI, BSSID, Channel)
    print("\n"..string.format("%32s","SSID").."\tBSSID\t\t\t\t RSSI\t\tAUTHMODE\tCHANNEL")

     --RSSI here will be picked
    for ssid,v in pairs(t) do
      local authmode, rssi, bssid, channel = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]+)")
      print(string.format("%32s",ssid).."\t"..bssid.."\t "..rssi.."\t\t"..authmode.."\t\t\t"..channel)
    end
  end)

  print("AP IP:" .. internet.get_access_point_ip())
  print("AP MAC:" .. internet.get_access_point_mac())
  print("STA MAC:" .. internet.get_station_mac())
end

local function on_internet_disconnected()
  print("internet disconnected")
end

local function main()
  internet.configure_station_ap("Stephen", "password", "stephenNodeMCU", "12345678")
  internet.connect_station(on_internet_connected, on_internet_disconnected)
end

main()