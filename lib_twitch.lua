local utils = require("utils")

local Twitch = {
  ws = nil,
  on_private_message = nil,
  channel = nil
}


local function parse_message(line)
  local prefix

  if line:sub(1,1) == ":" then
    local space = line:find(" ")
    prefix = line:sub(2, space-1)
    line = line:sub(space)
  end

  local colonsplit = line:find(":")
  local last = ""

  if colonsplit then
    last = line:sub(colonsplit+1)
    line = line:sub(1, colonsplit-2)
  end

  local params = ""
  local cmd, channel

  for arg in line:gmatch("(%S+)") do
    if not cmd then cmd = arg
    elseif not channel then channel = arg
    else params = params .. arg
    end
  end

  if last ~= nil then  params = params .. last end
  return prefix, cmd, channel, params
end



local function on_connection(ws)
  print ('twitch ws connected')

  Twitch.ws:send("NICK justinfan129038740928374")
end

local function on_close(_, status)
  print('connection closed', status)
  Twitch.ws = nil -- required to Lua gc the websocket client
end

local function on_recieve(_, message, opCode)
  for line in message:gmatch("[^\r\n]+") do
    if utils.starts_with(line, "PING") then
      return Twitch.ws:send("PONG :tmi.twitch.tv")
    end

    local prefix, cmd, channel, params = parse_message(line)

    if cmd == "001" and Twitch.channel ~= nil then
      return Twitch.ws:send("JOIN #" .. Twitch.channel)
    end

    if cmd == "PRIVMSG" and Twitch.on_private_message ~= nil then
      Twitch.on_private_message(channel, params)
    end
  end
end

local function connect()
  Twitch.ws = websocket.createClient()

  Twitch.ws:on("connection", on_connection)
  Twitch.ws:on("receive", on_recieve)
  Twitch.ws:on("close", on_close)

  Twitch.ws:connect("ws://irc-ws.chat.twitch.tv:80")
end

Twitch.connect = connect

return Twitch