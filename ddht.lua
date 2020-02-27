M = {}
M.__index = M

function M:create(pin, sample_rate)
  local this = {
    -- The pin number of the DHT sensor, cannot be 0, type of a number.
    executing_pin = pin;
    -- The reference to the global DHT object.
    DHT = dht;
    -- The last status that was determined when reading from the Ddht.
    last_status = dht.OK,
    last_response = nil,

    -- if the chip component is ready to sample again or not.
    can_sample_again = true,

    -- the sample rate in milliseconds
    sample_rate = sample_rate
  }

  setmetatable(this, M)

  if this.sample_rate == nil then
    this.sample_rate = 2500
  end

  return this
end

-- Reads all raw data coming from any dht sensor including the dh11.
function M:read_raw()
  if not self.can_sample_again then
    return self.last_response
  end

  local status, temp, humi, temp_dec, humi_dec self.DHT.read(self.executing_pin)
  return self:process_response(status, temp, humi, temp_dec, humi_dec)
end

-- Reads raw information from all non-dht11 sensors.
function M:read_raw_not_11()
  if not self.can_sample_again then
    return self.last_response
  end

  local status, temp, humi, temp_dec, humi_dec = self.DHT.readxx(self.executing_pin)
  return self:process_response(status, temp, humi, temp_dec, humi_dec)
end

-- Reads as if its a DHT11, taking the response status, temp and humdi with all its decimal values.
-- Followed by post processing.
function M:read()
  if not self.can_sample_again then
    return self.last_response
  end

  local status, temp, humi, temp_dec, humi_dec = self.DHT.read11(self.executing_pin)
  return self:process_response(status, temp, humi, temp_dec, humi_dec)
end

-- process_response does some post read processing, ensuring tot track the status for internal
-- referencing and formatting the repsonse into a easily handled object over multiple properties.
function M:process_response(status, temp, humi, temp_dec, humi_dec)
  self.last_status = status;

  self.last_response = {
    temperature = temp,
    temperature_decimal = temp_dec,
    humidity = humi,
    humidity_decimal = humi_dec
  }

  -- start the sample timer, which will allow the sensor sampling rate to be respected. Otherwise we
  -- can get unexpected results back from the sensor.
  self:start_sample_timer()

  return self.last_response
end

function M:start_sample_timer()
  local pwm_timer = tmr.create()
  self.can_sample_again = false

  pwm_timer:alarm(self.sample_rate, tmr.ALARM_SINGLE, function ()
  self.can_sample_again = true
  end)
end

-- returns true if the last sensor was ok.
function M:is_ok()
  return self.last_status == self.DHT.OK
end

-- returns true if the last sensor was not ok.
function M:is_error()
  return self.last_status ~= self.DHT.OK
end

-- returns true if the sensor is reporting the data otherwise false for no real value is being
-- reported.
function M:is_reporting()
  return self.last_response ~= nil and self.last_response.temperature ~= -999 and self.last_response.humidity ~= -999
end

-- retuns the last returned status from the chip or dht module, otherwise nil.
function M:get_status()
  return self.last_status
end

-- returns a string based message for a given status. OK, ERROR_CHECKSUM, ERROR_TIMEOUT errors.
-- Otherwise UNKNOWN.
function M:status_string()
  if self.last_status == self.DHT.OK then
    return "OK"
  elseif self.last_status == self.DHT.ERROR_CHECKSUM then
    return "CHECKSUM ERROR"
  elseif self.last_status == self.DHT.ERROR_TIMEOUT then
    return "TIMEOUT ERROR"
  end

  return "UNKNOWN"
end

return M