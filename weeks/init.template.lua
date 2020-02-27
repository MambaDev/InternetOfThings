
local internet = require("internet")

local function on_internet_connected()
  print("internet connected")
end

local function on_internet_disconnected()
  print("internet disconnected")
end

local function main()
  internet.configure("Stephen", "password")
  internet.connect(on_internet_connected, on_internet_disconnected)
end

main()