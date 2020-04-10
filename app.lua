local internet = require("lib_internet")
local pwms = require("lib_ppwm");

print("module load heap: " .. node.heap())

local state = {
  -- The auditing information and history for the keypad. Containing the upper
  -- limit of the number of audits, or the history of the audit information.
  audit = {
    limit =  10;
    history = {};
    results = {
      failed = "failed";
      success = "success";
    };
  };

  -- The table of all the registered buttons of the application.
  buttons = {};

  -- The possible stages of which the keycode could be in.
  stages = {
    awaiting_selection = "awaiting_selection";
    awaiting_pin = "awaiting_pin";
    unlocked = "unlocked";
    locked = "locked";
  };

  -- The current stage the keycode is in, this will be used to ensure the
  -- correct steps are being executed.
  stage = "awaiting_selection";

  -- The allocated lights that will be used to keep the user aware of the
  -- current state. Yellow, green, red and white.
  lights = {
    yellow = pwms:create(5, nil, 0);
    green = pwms:create(6, nil, 0);
    red = pwms:create(7, nil, 0);
    white = pwms:create(8, nil, 0);
  };

  -- The currently selected id of the active profile, this will be used track
  -- what current profile is being used, to match up with the correct pin
  -- sequence.
  selected_profile = nil;

  -- The pin history for the selected profile, each button press will be pushed
  -- into the table and will be used to ensure that the input sequence matches
  -- the given profiles defined sequence.
  pin_selection = nil;

  -- The list of profiles for each of the four current profile options
  -- (buttons). Each index relates to a given profile and a related button id.
  profiles = {
    { 1, 2, 3, 4 },
    { 1, 2, 3, 4 },
    { 1, 2, 3, 4 },
    { 1, 2, 3, 4 },
  };
};

-- Audit a given action for the keypad.
--
-- area    (string): The area the audit is taken place.
-- result  (string): The result of the action being audited.
-- message (string): The supporting message of the audit.
local function audit_action(area, result, message)
  if table.getn(state.audit.history) >= state.audit.limit then table.remove(1, state.audit.history) end
  table.insert(state.audit.history, { area = area, result = result, message=message })
end

-- Transition all lights to a the given related state.
--
-- yellow (number): The new duty of the yellow led.
-- green  (number): The new duty of the green led.
-- red    (number): The new duty of the red led.
-- white  (number): The new duty of the white led.
local function transition_all_lights(yellow, green, red, white)
  state.lights.yellow:transition_to_duty(yellow);
  state.lights.green:transition_to_duty(green);
  state.lights.red:transition_to_duty(red);
  state.lights.white:transition_to_duty(white);
end

-- Transition the lights into a locked state, turning of all lights off and
-- ensuring that the red light is on.
local function transition_to_locked_state()
  transition_all_lights(0, 0, 400, 0);
end

-- Transition the lights into a sequence selection state, turning of all lights off and
-- ensuring that the yellow light is on.
local function transition_to_sequence_selection_state()
  transition_all_lights(400, 0, 0, 0);
end

-- Transition the lights into profile selection state, turning of all lights off
-- and ensuring that the white light is on.
local function transition_to_profile_selection_state()
  transition_all_lights(0, 0, 0, 400);
end

-- Triggered when any given button is pressed, this should handle all cases in
-- which the button could be in, locked, selection, keypad unlocking, sequence.
local function on_press(button)
  print("stage: " .. state.stage)

  -- If the keycode is in a locked state, then no action can take place.
  if state.stage == state.stages.locked then
      audit_action(state.stage, state.audit.results.failed, "keypad locked.");
      transition_to_locked_state();
    return
  end

  -- If we are awaiting for a profile and a button is pressed, mark that as the
  -- selected profile, shift into profile selection stage. Any input after will
  -- be counted towards the lock sequence.
  if state.stage == state.stages.awaiting_selection then
      audit_action(state.stage, state.audit.results.success, "profile selection.");
      transition_to_sequence_selection_state();
      state.stage = state.stages.awaiting_pin;
      state.selected_profile = button.id;
      state.pin_selection = {};
    return
  end

  -- If we are awaiting for pins then input another pin entry, if we have enough
  -- pins, validate and unlock if possible, otherwise reset.
  if state.stage == state.stages.awaiting_pin then
      audit_action(state.stage, state.audit.results.success, "pin entry.");
      table.insert(state.pin_selection, button.id);

    if table.getn(state.pin_selection) == table.getn(state.buttons) then
      audit_action(state.stage, state.audit.results.success, "pin complete, validating.");
      transition_all_lights(0, 400, 0, 0);
    end
    return
  end
end

local function on_long_press(button)
end

local function on_released(button)
end

local function create_button(id, led, pin)
  local button = {
    pressed_iteration_count = 0;
    long_pressed_iteration = 10;
    long_pressed = 0;
    pressed = 0;
    pin = pin;
    id = id;
  }

  button.on_press = function () on_press(button); end
  button.on_long_press = function () on_long_press(button); end
  button.on_released = function () on_released(button); end

  gpio.mode(pin, gpio.INPUT)
  gpio.write(pin, gpio.LOW)

  return button;
end


local function setup_and_register_buttons()
  table.insert(state.buttons, create_button(1, 8, 1));
  table.insert(state.buttons, create_button(2, 7, 2));
  table.insert(state.buttons, create_button(3, 6, 3));
  table.insert(state.buttons, create_button(4, 5, 4));

  -- Setup the default state, the user is awaiting to select a given profile
  -- that will be used to unlock the padlock.
  state.stage = state.stages.awaiting_selection;
  transition_to_profile_selection_state();

  local button_timer = tmr.create()
  button_timer:register(100, 1, function()
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

  button_timer:start();
end

-- the function called when everything is setup and ready to go within the
-- NodeMCU. this includes the internet connection, clock synchronization and
-- logger logger setup.
local function on_start()
  print("ip: " .. internet.get_station_ip())
  setup_and_register_buttons()
 end

-- log the reason to why the application failed to connect to the internet, or
-- failed to synchronize the clock. Error is typically not very helpful.
local function on_failed(reason) print("internet disconnected") end

-- When the internet is connected (and we have a ip address) attempt to
-- synchronize the clocks with a remote time synchronization server, when the
-- synchronization has been completed, start the application entry.
local function on_internet_connected() on_start() end

-- 1 second before we start so we have a safe cutoff point, otherwise if a error
-- occurs, you can get stuck in a boot loop that is really hard to get out of.
local start_timer = tmr.create()

start_timer:register(1000, tmr.ALARM_SINGLE,  function ()
  internet.configure_station("The Promise Lan", "DangerZone2018", nil)
  internet.connect_station(nil, on_internet_connected, on_failed)
end)

start_timer:start()
