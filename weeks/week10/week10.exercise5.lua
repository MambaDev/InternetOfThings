local state = {
    students = {},
    source_constant = "192.168.1.69"
}

local function send_core_page(sck)
    local response = { "HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n" }
    response[#response + 1] = "<head>"
    response[#response + 1] = "<link href='https://unpkg.com/tailwindcss@^1.0/dist/tailwind.min.css' rel='stylesheet'>"
    response[#response + 1] = "</head>"
    response[#response + 1] = "<body>"

    response[#response + 1] = '<div class="max-w-sm mx-auto mt-4 mb-4 rounded overflow-hidden shadow-lg">'
    response[#response + 1] = '<div class="px-6 py-4">'
    response[#response + 1] = '<div class="font-bold text-xl mb-2">Register Attendance</div>'
    response[#response + 1] = '<form type=submit>'
    response[#response + 1] = '<div class="mb-6">'
    response[#response + 1] = '<label class="block text-gray-700 text-sm font-bold mb-2" for="password">'
    response[#response + 1] = 'Student Id'
    response[#response + 1] = '</label>'
    response[#response + 1] = '<input class="shadow appearance-none border border-red-500 rounded w-full py-2 px-3 text-gray-700 mb-3 leading-tight focus:outline-none focus:shadow-outline" id="id" name="id" placeholder="student id">'
    response[#response + 1] = '</div>'
    response[#response + 1] = '<div class="mb-6">'
    response[#response + 1] = '<label class="block text-gray-700 text-sm font-bold mb-2" for="password">'
    response[#response + 1] = 'Student Name'
    response[#response + 1] = '</label>'
    response[#response + 1] = '<input class="shadow appearance-none border border-red-500 rounded w-full py-2 px-3 text-gray-700 mb-3 leading-tight focus:outline-none focus:shadow-outline" id="name" name="name" placeholder="name">'
    response[#response + 1] = '</div>'
    response[#response + 1] = '<div class="flex items-center justify-between">'
    response[#response + 1] = '<input type="submit" value="Submit" id="submit-button" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"'
    response[#response + 1] = 'Update'
    response[#response + 1] = '</button></div></form></div></div></body>'

    -- sends and removes the first element from the 'response' table continues to
    -- do this per entry per sent until empty, and closing the socket. This is
    -- the recommended way to not have memory leaks.
    local function send(localSocket)
        if #response > 0 then
            localSocket:send(table.remove(response, 1))
        else
            localSocket:close()
            response = nil
        end
    end

    sck:on("sent", send)
    send(sck)

end

local function tcp_receiver(sck, req)
    for line in req:gmatch("([^\n]*)\n?") do
        if string.find(line, "GET /") then

            local name = string.match(line, "name=(%w+).*")
            local id = string.match(line, "id=(%w+)")

            local _, ip = sck:getpeer();

            if (name ~= nil and id ~= nil) and ip == state.source_constant then
                local file_write = file.open("students.txt", "a+")
                file_write:writeline(name .. " " .. id)
                file_write:close()

                return send_core_page(sck)
            end

        end
    end

    send_core_page(sck)
end

local function tcp_server_listen(conn)
    conn:on("receive", tcp_receiver)
end

local function on_start()
    print("ip: " .. wifi.sta.getip())

    local tcp_server = net.createServer(net.TCP, 30)
    tcp_server:listen(80, tcp_server_listen)
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
