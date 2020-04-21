function crawl_url(url)
    headers = { ['user-agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.117 Safari/537.36' }
    --headers to avoid the website to recognise you as a robot
    http.request(url, 'GET', headers, nil, function(code, data)
        print("\n\n" .. url)

        if (code < 0) then
            print("HTTP request failed")
            print(code)
        else
            print(code, data)
        end
    end)
end

function crawl()
    urls = {
        --'http://httpbin.org/ip',
        'http://www.amazon.co.uk',
        --'http://wttr.in/',
        -- try other urls and see why they can work or why not
    }

    for _, v in pairs(urls) do
        crawl_url(v)
    end
end

local function on_start()
    print("ip: " .. wifi.sta.getip())
    crawl()
end

local start_timer = tmr.create()

start_timer:register(1000, tmr.ALARM_SINGLE, function()
    wifi.setmode(wifi.STATION)

    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, on_start)
    wifi.sta.config({ ssid = "The Promise Lan", pwd = "DangerZone2018" })
end)

start_timer:start()

