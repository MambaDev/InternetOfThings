PPWM = {}
PPWM.__index = PPWM

function PPWM:create(pin, clock)
  local this = {
  -- This is the wdth of the pulse based on the hardware. This can be adjusted to determine the
  -- output power. e.g maximum duty cycle would be classed as "on" while 0 could be classed as
  -- "off". Making sure to not provide too much power to the device and burning it out.
  -- 
  --  This is REAL power reduction
  -- Resolution is determined by the hardware.
  --
  -- The current duty cycle limit for the current board.
  duty_cycle_limit = 1023;

  -- The frequency the PWM is executing within.
  clock_cycle = 1000;

  -- The IO pin that will be taking the PWM input.
  executing_pin = -1;

  -- The internal PWM module.
  PWM = pwm;

  -- If we are currently running or not.
  running = false;
  }

  if pin ~= nil then
    this.executing_pin = pin
  end

  if clock ~= nil then
    this.clock_cycle = clock
  end

  setmetatable(this, PPWM)
  return this
end

-- configure sets up the pwm on a specified pin with a clock and duty cycle. If start is specified
-- then the pwm will be setup and the duty will  be found to the pin.
--
-- pin        {number}:  The chip pin that is being setup for pwm processing.
-- clock      {number}:  The clock cycle of the specified pin.
-- duty_cycle {number}:  The duty cycle of the specified pin, how much power.
-- start      {boolean}: If configuration process should also start processing pwm data.
function PPWM:configure(duty)
    self.PWM.setup(self.executing_pin, self.clock_cycle, self.duty_cycle_limit)
    self:update_duty(duty)
    self.running = true
end

-- Stops the current proessing of the PWM data, marks internally that the PWM is not running and
-- calls into the module to stop the PWM.
function PPWM:stop()
  if self.running then
    self.running = false
    self.PWM.stop()
  end
end

-- Completely disconnects and quits the PWM mode for the current executing pin. Ensures to
-- stop/pause the processing of the data in pwm first before quiting the pwm mode for the current
-- pin.
function PPWM:close()
  if self.running then
    self:stop()
  end

  self.PWM.close()
end

-- updateExecutingPin takes in a new pin that will processing the PWM and if currently executing,
-- stops the current PWM (quiting), reconfigures and runs the pwm on the new pin and starts the
-- processing again.
--
-- pin {number}: The chip pin that is being setup for pwm processing.
function PPWM:update_executing_pin(pin)
  if self.running then
    self:close()
  end

  self.executing_pin = pin
  self:configure()
end

-- Updates the duty for the current pin with the specified amount. Including the guarding of the
-- upper limit of 1024 - 1 and lower limit of 0. Going outside these bounds will not cause any
-- problems but this will ensure the duty will not.
--
-- duty {number}: The duty cycle of the specified pin, how much power.
function PPWM:update_duty(duty)
  if duty > self.duty_cycle_limit then
    duty = self.duty_cycle_limit
  end

  if duty < 0 then
    duty = 0
  end

  self.PWM.setduty(self.executing_pin, duty)
end

-- Increases the duty by the specified amount.
--
-- amount {number}: The amount to increase the duty.
function PPWM:increase_duty(amount)
  self.updateDuty(self:get_duty() + amount)
end

-- Decreases the duty by the specified amount.
--
-- amount {number}: The amount to decrease the duty.
function PPWM:decrease_duty(amount)
  self:updateDuty(self:get_duty() - amount)
end

-- returns the current dity on the current pin.
function PPWM:get_duty()
  return self.PWM.getduty(self.executing_pin)
end

return PPWM