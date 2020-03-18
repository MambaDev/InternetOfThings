FILTER = {}
FILTER.__index = FILTER

-- Creates a new single dimensional kalman filter (this does not support control vectors for following growth)
--
-- process_noise:         how noisy our data is, e.g how much noise are we expecting.
-- measurement_of_noise:  how much noise is expected to be generated by our measurements.
function FILTER:create(process_noise, measurement_of_noise)
  local this = {
    process_noise = process_noise or 1;
    measurement_of_noise = measurement_of_noise or 1;

    -- Our estimated value that is the given filter value without noise.
    cov = nil;
    x = nil;
  }

  setmetatable(this, FILTER)

  return this
end

-- Filter a given new value
-- measurement: The given value being filtered.
-- control_value: The given control value of the filter.
function FILTER:filter(measurement, control_value)
  local control = control_value or 0;

  -- if we don't have a prevous value
  if self.x == nil then
      self.x = measurement;
      self.cov = self.measurement_of_noise;
  else
    local prediction_x = self:prediction(control);
    local prediction_cov = self:uncertainty();

    local kalman_gain = prediction_cov * (1 / (prediction_cov + self.measurement_of_noise))

    self.x = prediction_x + kalman_gain * (measurement - prediction_x);
    self.cov = prediction_cov - (kalman_gain * prediction_cov);
  end

  return self.x;
end

-- Predict the next value
-- control_value: The control value.
function FILTER:prediction(control_value)
  local control = control_value or 0;
  return self.x + control;
end

-- Returns uncertainy of the filter.
function FILTER:uncertainty()
  return self.cov + self.process_noise
end

-- returns the last filtered value.
function FILTER:last_value()
  return self.x
end

-- Updates the noise for the given filter.
function FILTER:update_noise_value(noise)
  local updated_noise = noise or self.process_noise;
  self.process_noise = updated_noise;
end

return FILTER