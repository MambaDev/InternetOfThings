
local kalman_filter = require("kalmanFilter")

local function main()
  -- first generate our data.
  local array_values = {}
  for i=1, 5 do array_values[i] = 12 end

  print("\nbefore noise: " .. table.concat(array_values, " "))

  for i=1, 5 do
    if i % 2 == 0 then array_values[i] = array_values[i] + math.random(4);
    else array_values[i] = array_values[i] - math.random(4);
    end
  end

  print("after noise: " .. table.concat(array_values, " "))

  local filter = kalman_filter:create(0.01, 4);
  local array_values_filtered = {}
  for i=1, 5 do array_values_filtered[i] = filter:filter(array_values[i]) end

  print("after noise filter: " .. table.concat(array_values_filtered, " "))

end

main()
