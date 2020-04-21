function htmlUpdate(sck, flag)
    --update the html file for display in your browser
    html = '<html>\r\n<head>\r\n<title>LED LAN Control</title>\r\n</head>\r\n'
    html = html .. '<body>\r\n<h1>LED</h1>\r\n<p>Click the button below to switch LED on and off.</p>\r\n<form method=\"get\">\r\n'

    --method is get here, listener will try to find the get info
    if flag then
        --compare the boolean logic here and below in the receiver
        strButton = 'LED_OFF'
    else
        strButton = 'LED_ON'
    end
    html = html .. "<input type=\"button\" value=\"" .. strButton .. "\"onclick=\"window.location.href='/" .. strButton .. "'\">\r\n"
    -- add the different button
    html = html .. "</form>\r\n</body>\r\n</html>\r\n"
    sck:send(html)
end

function setMode(sck, data)
    print(data)
    --check what is the data received, and figure out why we find the match pattern in the string
    if string.find(data, "GET /LED_ON") then
        htmlUpdate(sck, true)
        gpio.write(pinLED, gpio.HIGH)
    elseif string.find(data, "GET / ") or string.find(data, "GET /LED_OFF") then
        htmlUpdate(sck, false)
        gpio.write(pinLED, gpio.LOW)
    else
        --if no match found then close the connection after sending a notice using the socket for the last will
        sck:send("<h2>Error, no matched string has been found!</h2>")
        sck:on("sent", function(conn)
            conn:close()
        end)
    end
end

local function on_start()
    print("ip: " .. wifi.sta.getip())

    pinLED = 4
    gpio.mode(pinLED, gpio.OUTPUT)
    svr = net.createServer(net.TCP)

    if svr then
        svr:listen(80, function(conn)
            --listen to the port 80 for http
            --when the event of ‘data is received’ happens, run the setMode
            conn:on("receive", setMode)
        end)
    end
end

local start_timer = tmr.create()

start_timer:register(1000, tmr.ALARM_SINGLE, function()
    wifi.setmode(wifi.STATION)

    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, on_start)
    wifi.sta.config({ ssid = "The Promise Lan", pwd = "DangerZone2018" })
end)

start_timer:start()
