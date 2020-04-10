local function on_press() end
local function on_long_press() end
local function on_release() end

local function four_buttons_one_timer()
  local buttons = {
    create_button(1, on_release, on_long_press, on_release),
    create_button(2, on_release, on_long_press, on_release),
    create_button(3, on_release, on_long_press, on_release),
    create_button(4, on_release, on_long_press, on_release)
  }

  local button_timer = tmr.create()
  button_timer:register( 100, 1, function()
      for i, button in ipairs(buttons) do
        -- read the pin value (1 = pressed, 0 = not pressed)
        local pin_reading = gpio.read(button.executing_pin)

        -- if the pin reading is currently presed and we are not marked as currently pressed, then mark
        -- the button as pressed and trigger the pressed event if provided.
        if pin_reading == 1 and button.pressed == 0 then
          button.pressed = 1

          if button.on_press ~= nil then
            button.on_press()
          end
        end

        -- if the button is stating that its not being pressed and the current state is that the button is
        -- being presed. then reset press iteration, long press trigger and pressed trigger. Triggering
        -- the on release event if its been provided or not.
        if pin_reading == 0 and button.pressed == 1 then
          button.pressed_iteration_count = 0
          button.long_pressed = 0
          button.pressed = 0

          if button.on_released ~= nil then
            button.on_released()
          end
        end

        -- if the pin is reading pressed, we are marked as pressed and not marked as long press then
        -- iterate the press iteration count. If the press iteration count increases larger than the
        -- specified long press limit then mark as long pressed and reset call into the long press
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
end


four_buttons_one_timer()