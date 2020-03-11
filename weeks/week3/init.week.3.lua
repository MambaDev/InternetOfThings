
local ddht = require("ddht")

local function main()
  local d1 = ddht:create(2)
  local response = d1:read()

  print("Status: " .. d1:status_string() .. 
  " - DHT Temperature: " .. response.temperature .. " Humidity: " .. response.humidity)
end

main()
