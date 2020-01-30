
local pwms = require("pwms")

-- Used to determine the directional action of the led breathing affect.
local direction = true

-- Triggers a e.g breathing affect on a pwm pin by shifting the duty up and down the bounds of the
-- chip limit. If the duty is currently lower than or equal to 0, then processed to increase it up
-- to the chips duty limit. If the limit is hit, reverse the process until 0 again. incrementing in
-- steps of 20.
local function led_breathing_effect()
  print("shifting duty: " .. pwms.get_duty())

  if pwms.get_duty() <= 0 then
    direction = true
  elseif pwms.get_duty() >= pwms.duty_cycle_limit then
    direction = false
  end

  if direction then
    pwms.update_duty(pwms.get_duty() + 20)
  else
    pwms.update_duty(pwms.get_duty() - 20)
  end
end

local function main()
  pwms.configure(3, 500, pwms.duty_cycle_limit, true)

  local pwm_timer = tmr.create()
  pwm_timer:alarm(200, tmr.ALARM_AUTO, led_breathing_effect)
end

main()