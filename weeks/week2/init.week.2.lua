
local ppwm = require("ppwm")

-- Used to determine the directional action of the led breathing affect.
local direction = true

-- Triggers a e.g breathing affect on a pwm pin by shifting the duty up and down the bounds of the
-- chip limit. If the duty is currently lower than or equal to 0, then processed to increase it up
-- to the chips duty limit. If the limit is hit, reverse the process until 0 again. incrementing in
-- steps of 20.
local function led_breathing_effect(pwms, shift)
  return function()
    print("shifting duty: " .. pwms:get_duty() .. " pin: " .. pwms.executing_pin)

    if pwms:get_duty() <= 0 then
      direction = true
    elseif pwms:get_duty() >= pwms.duty_cycle_limit then
      direction = false
    end

    if direction then
      pwms:update_duty(pwms:get_duty() + shift)
    else
      pwms:update_duty(pwms:get_duty() - shift)
    end

    end
  end

local function main()
  local p1 = ppwm:create(1)
  p1:configure(1023)

  local p2 = ppwm:create(2)
  p2:configure(1023)

  local p3 = ppwm:create(3)
  p3:configure(1023)

  local pwm_timer = tmr.create()
  local pwm_timer2 = tmr.create()
  local pwm_timer3 = tmr.create()

  pwm_timer:alarm(50, tmr.ALARM_AUTO, led_breathing_effect(p1, 50))
  pwm_timer2:alarm(100, tmr.ALARM_AUTO, led_breathing_effect(p2, 100))
  pwm_timer3:alarm(200, tmr.ALARM_AUTO, led_breathing_effect(p3, 150))
end

main()