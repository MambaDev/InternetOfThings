local logger = require("lib_logger")

M = {}
M.__index = M

-- Creates a new MQTT client ready for connection.
--
-- host     string: The host the cient will be using.
-- port     number: The host port the  cient will be using.
-- username string: The username that will be used for authentictaion.
-- key      string: The key/password used with the password.
function M:create(host, port, username, key, name)
  local this = {
    host_address = host or 'io.adafruit.com';
    host_port = port or 1883;
    host_username = username or nil;
    host_key = key or nil;
    connected_client = nil;
    client = nil;
    name = name or "main";
    topic_actions = {};
  }

  setmetatable(this, M)
  return this;
end

-- Makes the connection to the ada broker services via MQTT.
--
-- on_connection function: The function that will be called once the client has connected.
function M:connect(on_connection)
  self.client = mqtt.Client(self.name, 300, self.host_username, self.host_key)

  self.client:on("connect", function(connected_client)
      logger.debugf("%s - connected, host: %s - port: %s", self.name, self.host_address, self.host_port)

      self.connected_client = connected_client;
      if on_connection ~= nil then on_connection(self) end
  end)

  self.client:on("offline", function ()
      logger.debugf("%s - offline, host: %s - port: %s", self.name, self.host_address, self.host_port)
      self.connected_client = nil;
  end)

  logger.debugf("%s - connecting, host: %s - port: %s",self.name, self.host_address, self.host_port)
  self.client:lwt("/lwt","Now offline",1,0)

  self.client:connect(self.host_address, self.host_port, false, false, nil, function (reason)
      logger.debugf("%s - connecting failed, reason: %s", self.name, reason)
  end)

self.client:on("message", function (client, topic, data)
      logger.debugf("%s - message from topic: %s - data: %s", self.name, topic, data);

      if self.topic_actions[topic] == nil then return end;

      -- for all topic actions registerd, fire the given event.
      table.foreach(self.topic_actions[topic],
        function(k,v) v(topic, data)
      end)
  end);
end

-- Subscribe to the given mqtt topic with the given call back.
--
-- topic      string: the topic that is being subscribed too.
-- callback function: The callback function of thet topic when subscribed.
function M:subscribe(topic, callback, data_callback)
  logger.debugf("%s - subscribing to topic: %s", self.name, topic);

  self.connected_client:subscribe(topic, 1, function ()
    logger.debugf("%s - subscribed to topic: %s", self.name, topic);

    if callback ~= nil then callback() end

    if data_callback ~= nil then
      self:register_topic(topic, data_callback)
    end
  end);
end

-- Publish to the given mqtt topic with the given data..
--
-- topic  string: The topic that is being published too.
-- data   string: The data that is being published.
function M:publish(topic, data, send_callback)
  logger.debugf("%s - publishing to topic: %s with data: %s", self.name, topic, data);
  self.connected_client:publish(topic, tostring(data), 1, 0, function ()
    logger.debugf("%s - published to topic: %s with data: %s", self.name, topic, data);
    if send_callback ~= nil then send_callback() end
  end)
end

-- registers a topic with the on message event flow. So if the topic exists, all
-- functions are called, this simplifies the registering processs when subscribing.
--
-- topic      string: the topic that is being registerd too.
-- callback function: The callback function of when the topic gets a message.
function M:register_topic(topic, callback)
  if self.topic_actions[topic] == nil then
    self.topic_actions[topic] = {};
  end

  table.insert(self.topic_actions[topic], callback);
end

return M