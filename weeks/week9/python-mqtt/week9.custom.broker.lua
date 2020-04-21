local logger = require("lib_logger")
logger.debugging = true;
-- Enable debug mode.

-- Unit requirements (imports).
local mqttl = require("lib_ada_mqtt")

local function on_mqtt_connected(client)
    client:subscribe("led-light", nil, function(topic, data)
        print(topic, data)
    end)

    client:publish("led-light", "on")
end

local function on_start()
    print("ip: " .. wifi.sta.getip())

    local client = mqttl:create("192.168.1.69", 8080);
    client:connect(on_mqtt_connected);
end

local function start()
    wifi.setmode(wifi.STATION)
    wifi.sta.config({ ssid = "The Promise Lan", pwd = "DangerZone2018" })

    wifi.sta.connect()
    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, on_start)
end


-- 1 second before we start so we have a safe cutoff point.
local start_timer = tmr.create()

start_timer:register(1000, tmr.ALARM_SINGLE, function()
    start();
end)

start_timer:start()
