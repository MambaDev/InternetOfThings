
local ppwm = require("lib_ppwm")

local red = ppwm:create(1, 600, 0)
local yellow = ppwm:create(2, 600, 0)
local green = ppwm:create(6, 600, 600)

local light_counter = 0

local function process_lights()
  light_counter = light_counter + 1;

  if light_counter == 8 then
    green:update_duty(0)
    yellow:update_duty(600)
  end

  if light_counter == 9 then
    yellow:update_duty(0)
    red:update_duty(600)
  end

  if light_counter == 13 then
    yellow:update_duty(600)
    red:update_duty(0)
  end

  if light_counter == 14 then
    yellow:update_duty(0)
    green:update_duty(600)
    light_counter = 0
  end
end

local function main()
  local pwm_timer = tmr.create()
  pwm_timer:alarm(500, tmr.ALARM_AUTO, process_lights)
end

local start_timer = tmr.create()
start_timer:register(500, tmr.ALARM_SINGLE,  main)
start_timer:start()