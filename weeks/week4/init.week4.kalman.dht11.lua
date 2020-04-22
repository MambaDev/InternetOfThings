
local kalman = require("kalmanFilter")
local ddht = require("lib_ddht")

local d1 = ddht:create(8)

local filter_temp = kalman:create(0.01, 2);
local filter_hum = kalman:create(0.01, 2);

local function sample_ddt()
  local response = d1:read()

  local temp = filter_temp:filter(response.temperature);
  local hum = filter_hum:filter(response.humidity);

  print(string.format("kalman - temperature %s", temp))
  print(string.format("kalman - humidity %s", hum))
end


-- 1 second before we start so we have a safe cutoff point.
local start_timer = tmr.create()

start_timer:register(2550, tmr.ALARM_AUTO, function()
  sample_ddt()
end)

start_timer:start()
