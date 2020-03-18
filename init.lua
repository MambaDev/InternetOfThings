
local ppwm = require("lib_ppwm")

local red = ppwm:create(1, 1000, 0)

local function on_action()
  red:update_duty(1023)
end

local function off_action()
  red:update_duty(0)
end


local function process_interval(intervals, actions)
  local position = 1;

  if intervals[position] == 1 or intervals[position] == 0 then
    actions[position]()
    return
  end

  actions[position]()
  print(intervals[position])

  local interval_timer =  tmr.create();
  interval_timer:register(intervals[position], tmr.ALARM_AUTO, function ()

    position = position + 1
    if position > table.getn(intervals) then
      position  = 1
    end

    actions[position]()
    interval_timer:interval(intervals[position])
    print(intervals[position])
  end)

  interval_timer:start();
end

local function main()
  local intervals = {1000, 500, 2000, 200}
  local actions = {on_action, off_action, on_action, off_action}
  process_interval(intervals, actions)
end

local start_timer = tmr.create()
start_timer:register(1000, tmr.ALARM_SINGLE,  main)
start_timer:start()