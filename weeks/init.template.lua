local function on_start()
  print("ip: " .. wifi.sta.getip())
end

local start_timer = tmr.create()

start_timer:register(1000, tmr.ALARM_SINGLE, function()
  wifi.setmode(wifi.STATION)

  wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, on_start)
  wifi.sta.config({ ssid = "The Promise Lan", pwd = "DangerZone2018" })
end)

start_timer:start()
