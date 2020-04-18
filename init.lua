local state = {
    -- The auditing information and history for the keypad. Containing the upper
    -- limit of the number of audits, or the history of the audit information.
    audit = {
        history = {},
        results = {
            failed = "failed",
            success = "success"
        }
    },
    -- The table of all the registered buttons of the application.
    buttons = {},
    -- The possible stages of which the keypad could be in.
    stages = {
        awaiting_selection = "awaiting_selection",
        awaiting_pin = "awaiting_pin",
        unlocked = "unlocked",
        locked = "locked"
    },
    -- The current stage the keypad is in, this will be used to ensure the
    -- correct steps are being executed.
    stage = "awaiting_selection",
    -- The allocated lights that will be used to keep the user aware of the
    -- current state. Yellow, green, red and white.
    lights = {
        yellow = 5,
        green = 6,
        red = 7,
        white = 8,
    },
    -- The currently selected id of the active profile, this will be used track
    -- what current profile is being used, to match up with the correct pin
    -- sequence.
    selected_profile = nil,
    -- The pin history for the selected profile, each button press will be pushed
    -- into the table and will be used to ensure that the input sequence matches
    -- the given profiles defined sequence.
    pin_selection = nil,
    -- The list of profiles for each of the four current profile options
    -- (buttons). Each index relates to a given profile and a related button id.
    profiles = {
        {1, 2, 3, 4},
        {1, 2, 3, 4},
        {1, 2, 3, 4},
        {1, 2, 3, 4}
    }
}

-- Audit a given action for the keypad.
--
-- area    (string): The area the audit is taken place.
-- result  (string): The result of the action being audited.
-- message (string): The supporting message of the audit.
local function audit_action(area, result, message)
    if table.getn(state.audit.history) >= 15 then
        table.remove(state.audit.history, 1)
    end

    local audit_action = string.format("%s - %s - %s", area, result, message);
    table.insert(state.audit.history, { area = area, result = result, message = message })
    print(audit_action)
end

-- Updates a given profile pin sequence based on a request from the server.
--
-- connection  (net): The network connection to reply to the user.
-- profile     (number): The profile number being updated.
-- updated_pin (number[]): The list of updated pins for the profile.
local function update_pin_request(connection, profile, updated_pin)
    audit_action('profile', state.audit.results.success, 'profile ' .. profile .. ' pin updated.')
    state.profiles[profile] = updated_pin;
end

local function tcp_receiver(sck, req)
    if req == nil then
        return
    end

    local next_val = false;
    local input = nil;

    for line in req:gmatch("([^\n]*)\n?") do
        if next_val == true then input = line; break end
        next_val = not (line ~= nil and line:match("%S") ~= nil)
    end

    -- check if we can parse the json otherwise just return.
    if not pcall(sjson.decode, input) then
        return
    end
    local response = sjson.decode(input)
    print(response);

    -- user has the possibility to update the country and city via the tcp socket.
    if response.type ~= nil and response.type == "pin" then
        return update_pin_request(sck, response.profile, response.pin)
    end
end

-- Send back the current city, country alarm time and last triggered to any
-- connecting client with tags to ensure the client reads it as html.
local function tcp_connection(sck)
    local response = {"HTTP/1.0 200 OK\r\nServer: NodeMCU on ESP8266\r\nContent-Type: text/html\r\n\r\n"}

    response[#response + 1] = "<!DOCTYPE html>"
    response[#response + 1] = "<html lang='en'>"
    response[#response + 1] = "<head>"
    response[#response + 1] = "<link rel='stylesheet' href='https://codepen.io/tehstun/pen/pojvKpd.css' />"
    response[#response + 1] = "</head>"
    response[#response + 1] = "<body>"

    response[#response + 1] = "<div class='container' id='c'>"
    response[#response + 1] = "<div class='card'>"
    response[#response + 1] = "<table id='content-table'>"
    response[#response + 1] = "<tr>"
    response[#response + 1] = "<th>Area</th>"
    response[#response + 1] = "<th>Result</th>"
    response[#response + 1] = "<th>Message</th>"
    response[#response + 1] = "</tr>"

    for k, v in pairs(state.audit.history) do
        response[#response + 1] = "<tr><td>".. v.area .. "</td><td>".. v.result .."</td><td>" .. v.message .."</td></tr>"
    end

    response[#response + 1] = "</table>"
    response[#response + 1] = "</div>"
    response[#response + 1] = "</div>"
  
    response[#response + 1] = "<script src='https://codepen.io/tehstun/pen/pojvKpd.js'></script>"
    response[#response + 1] = "</body>"

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

local function tcp_server_listen(conn)
    conn:on("receive", tcp_receiver)
    conn:on("connection", tcp_connection)
end

-- Takes in a list of codes and the corresponding matching codes, if all codes
-- match the matching values with the related index then return true otherwise
-- return false.
--
-- codes    (table): The codes the user inputted.
-- matching (table): The matching values that the codes should align too.
local function did_enter_correct_code(codes, matching)
    for i, match in ipairs(matching) do
        if codes[i] == nil or codes[i] ~= match then
            return false
        end
    end
    return true
end

-- Updates the current stage to the new provided stage. While also auditing the
-- given change.
--
-- new_stage (string): The new stage that will be put into.
local function update_stage(new_stage)
    audit_action(state.stage, state.audit.results.success, "Changing stage from " .. state.stage .. " to " .. new_stage)
    state.stage = new_stage
end

-- Transition all lights to a the given related state.
--
-- yellow (number): The new duty of the yellow led.
-- green  (number): The new duty of the green led.
-- red    (number): The new duty of the red led.
-- white  (number): The new duty of the white led.
local function transition_all_lights(yellow, green, red, white)
    if yellow then gpio.write(state.lights.yellow, gpio.HIGH) else gpio.write(state.lights.yellow, gpio.LOW); end
    if green then gpio.write(state.lights.green, gpio.HIGH) else gpio.write(state.lights.green, gpio.LOW); end
    if red then gpio.write(state.lights.red, gpio.HIGH) else gpio.write(state.lights.red, gpio.LOW); end
    if white then gpio.write(state.lights.white, gpio.HIGH) else gpio.write(state.lights.white, gpio.LOW);end
end

-- Trigger the buzzer within the specified duration and interval.
--
-- duration (number): How long (milliseconds) should the buzzer be executing for.
-- interval (number): How many milliseconds between each buzz.
local function trigger_buzzer(duration, interval)
    local buzzer_timer = tmr.create()

    local total = 0

    buzzer_timer:register( interval, tmr.ALARM_AUTO, function()
            total = total + interval
            print("BUZZ")

            if total >= duration - interval then
                buzzer_timer:unregister()
            end
        end
    )

    print("BUZZ")
    buzzer_timer:start()
end

-- Processes through the steps to let the user know that the keypad is not
-- unlocked, by transitioning the lights, triggering the buzzer and then
-- resetting.
local function process_not_unlock_complete()
    local reset_keypad_timer = tmr.create()

    transition_all_lights(false, false, true, false)
    update_stage(state.stages.locked)

    trigger_buzzer(4000, 1000)

    reset_keypad_timer:register( 1000 * 4, tmr.ALARM_SINGLE, function()
            update_stage(state.stages.awaiting_selection)
            transition_all_lights(false, false, false, true)

            state.selected_profile = nil
            state.pin_selection = nil
        end
    )

    reset_keypad_timer:start()
end

-- Processes through the steps to let the user know that the keypad is unlocked,
-- by transitioning the lights, triggering the buzzer and then resetting.
local function process_unlock_complete()
    local reset_keypad_timer = tmr.create()

    update_stage(state.stages.unlocked)
    transition_all_lights(false, true, false, false)

    trigger_buzzer(4000, 2000)

    reset_keypad_timer:register( 1000 * 4, tmr.ALARM_SINGLE, function()
            update_stage(state.stages.awaiting_selection)
            transition_all_lights(false, false, false, true)

            state.selected_profile = nil
            state.pin_selection = nil
        end
    )

    reset_keypad_timer:start()
end

-- Triggered when any given button is pressed, this should handle all cases in
-- which the button could be in, locked, selection, keypad unlocking, sequence.
local function on_press(button)
    -- If the keypad is in a locked state, then no action can take place.
    if state.stage == state.stages.locked then
        audit_action(state.stage, state.audit.results.failed, "locked.")
        transition_all_lights(false, false, true, false)
        return
    end

    -- If we are awaiting for a profile and a button is pressed, mark that as the
    -- selected profile, shift into profile selection stage. Any input after will
    -- be counted towards the lock sequence.
    if state.stage == state.stages.awaiting_selection then
        audit_action(state.stage, state.audit.results.success, "selected: " .. button.id)
        update_stage(state.stages.awaiting_pin)

        transition_all_lights(true, false, false, false)
        state.selected_profile = button.id
        state.pin_selection = {}
        return
    end

    -- If we are awaiting for pins then input another pin entry, if we have enough
    -- pins, validate and unlock if possible, otherwise reset.
    if state.stage == state.stages.awaiting_pin then
        audit_action(state.stage, state.audit.results.success, "Keypad pressed for profile.")

        table.insert(state.pin_selection, button.id)

        if table.getn(state.pin_selection) == table.getn(state.buttons) then
            if did_enter_correct_code(state.pin_selection, state.profiles[state.selected_profile]) then
                audit_action(state.stage, state.audit.results.success, "Entry complete for profile.")
                process_unlock_complete()
            else
                audit_action(state.stage, state.audit.results.failed, "Keypad did not match.")
                process_not_unlock_complete()
            end
        end
        return
    end
end

-- Creates a new given button that will be used to handle button presses,
-- pressed, long pressed and release state.
local function create_button(id, pin)
    local button = {
        pressed_iteration_count = 0,
        long_pressed_iteration = 10,
        long_pressed = 0,
        pressed = 0,
        pin = pin,
        id = id
    }

    button.on_press = function() on_press(button) end

    gpio.mode(pin, gpio.INPUT)
    gpio.write(pin, gpio.LOW)

    return button
end

-- Setup and start the application.
local function setup_and_register_buttons()
    table.insert(state.buttons, create_button(1, 1))
    table.insert(state.buttons, create_button(2, 2))
    table.insert(state.buttons, create_button(3, 3))
    table.insert(state.buttons, create_button(4, 4))

    gpio.mode(state.lights.green, gpio.OUTPUT)
    gpio.mode(state.lights.red, gpio.OUTPUT)
    gpio.mode(state.lights.white, gpio.OUTPUT)
    gpio.mode(state.lights.yellow, gpio.OUTPUT)

    -- Setup the default state, the user is awaiting to select a given profile
    -- that will be used to unlock the padlock.
    update_stage(state.stages.awaiting_selection)
    transition_all_lights(false, false, false, true)

    local button_timer = tmr.create()
    button_timer:register( 100, 1, function()
            for i, button in ipairs(state.buttons) do
                -- read the pin value (1 = pressed, 0 = not pressed)
                local pin_reading = gpio.read(button.pin)

                -- if the pin reading is currently pressed and we are not marked as
                -- currently pressed, then mark the button as pressed and trigger the
                -- pressed event if provided.
                if pin_reading == 1 and button.pressed == 0 then
                    button.pressed = 1

                    if button.on_press ~= nil then
                        button.on_press()
                    end
                end

                -- if the button is stating that its not being pressed and the current
                -- state is that the button is being pressed. then reset press
                -- iteration, long press trigger and pressed trigger. Triggering the on
                -- release event if its been provided or not.
                if pin_reading == 0 and button.pressed == 1 then
                    button.pressed_iteration_count = 0
                    button.long_pressed = 0
                    button.pressed = 0

                    if button.on_released ~= nil then
                        button.on_released()
                    end
                end

                -- if the pin is reading pressed, we are marked as pressed and not
                -- marked as long press then iterate the press iteration count. If the
                -- press iteration count increases larger than the specified long press
                -- limit then mark as long pressed and reset call into the long press
                -- trigger. This process is reset when the button is released.
                if pin_reading == 1 and button.pressed == 1 and button.long_pressed == 0 then
                    button.pressed_iteration_count = button.pressed_iteration_count + 1

                    if button.pressed_iteration_count > button.long_pressed_iteration then
                        button.long_pressed = 1

                        if button.on_long_press ~= nil then
                            button.on_long_press()
                        end
                    end
                end
            end
        end
    )

    button_timer:start()
end

-- the function called when everything is setup and ready to go within the
-- NodeMCU. this includes the internet connection, clock synchronization and
-- logger logger setup.
local function on_start()
    print("ip: " .. wifi.sta.getip())
    setup_and_register_buttons()

    local tcp_server = net.createServer(net.TCP, 30)
    tcp_server:listen(80, tcp_server_listen)
end

local function start()
    wifi.setmode(wifi.STATION)
    wifi.sta.config({ssid = "The Promise Lan", pwd = "DangerZone2018"})

    wifi.sta.connect()
    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, on_start)
end


-- 1 second before we start so we have a safe cutoff point.
local start_timer = tmr.create()

start_timer:register(1000, tmr.ALARM_SINGLE,  function ()
start();
end)

start_timer:start()

