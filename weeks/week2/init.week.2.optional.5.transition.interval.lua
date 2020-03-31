
local ppwm = require("lib_ppwm")
-- 
local red = ppwm:create(1, 1000, 0)

local function on_action()
  -- red:update_duty(1023)
  red:transition_to_duty(1000, 10)
end

local function off_action()
  -- red:update_duty(0)
  red:transition_to_duty(0, 10)
end


local function process_interval(intervals, actions, position)
  if intervals[position] == 1 or intervals[position] == 0 then
    actions[position]()
    return
  end

  local interval_timer =  tmr.create();
  actions[position]()

  interval_timer:register(intervals[position], tmr.ALARM_AUTO, function ()
    position = position + 1

    if position > table.getn(intervals) then position  = 1 end

    interval_timer:interval(intervals[position])
    actions[position]()
  end)

  interval_timer:start();
end

local function main()
  local intervals = {1000, 500, 2000, 200}
  local actions = {on_action, off_action, on_action, off_action}
  process_interval(intervals, actions, 1)
end

local start_timer = tmr.create()
start_timer:register(1000, tmr.ALARM_SINGLE,  main)
start_timer:start()