local M = {
  -- This is the wdth of the pulse based on the hardware. This can be adjusted to determine the
  -- output power. e.g maximum duty cycle would be classed as "on" while 0 could be classed as
  -- "off". Making sure to not provide too much power to the device and burning it out.
  -- 
  --  This is REAL power reduction
  -- Resolution is determined by the hardware.
  --
  -- The current duty cycle limit for the current board.
  duty_cycle_limit = 1024 - 1;

  -- The frequency the PWM is executing within.
  clock_cycle = 1000;

  -- The IO pin that will be taking the PWM input.
  executing_pin = -1;

  -- The internal PWM module.
  PWM = pwm;

  -- If we are currently running or not.
  running = false;
}

-- configure sets up the pwm on a specified pin with a clock and duty cycle. If start is specified
-- then the pwm will be setup and the duty will  be found to the pin.
--
-- pin        {number}:  The chip pin that is being setup for pwm processing.
-- clock      {number}:  The clock cycle of the specified pin.
-- duty_cycle {number}:  The duty cycle of the specified pin, how much power.
-- start      {boolean}: If configuration process should also start processing pwm data.
local function configure(pin, clock, duty_cycle, start)
    M.executing_pin = pin
    M.clock_cycle = clock

    if start then
      M.PWM.setup(M.executing_pin, M.clock_cycle, M.duty_cycle_limit)
      M.update_duty(duty_cycle)
      M.running = true
    end
end

-- Stops the current proessing of the PWM data, marks internally that the PWM is not running and
-- calls into the module to stop the PWM.
local function stop()
  if M.running then
    M.running = false
    M.PWM.stop()
  end
end

-- Completely disconnects and quits the PWM mode for the current executing pin. Ensures to
-- stop/pause the processing of the data in pwm first before quiting the pwm mode for the current
-- pin.
local function close()
  if M.running then
    M.stop()
  end

  M.PWM.close()
end


-- updateExecutingPin takes in a new pin that will processing the PWM and if currently executing,
-- stops the current PWM (quiting), reconfigures and runs the pwm on the new pin and starts the
-- processing again.
--
-- pin {number}: The chip pin that is being setup for pwm processing.
local function update_executing_pin(pin)
  if M.running then
    M.close()
  end

  M.configure(pin, M.clock_cycle, M.get_duty(), true)
end

-- Updates the duty for the current pin with the specified amount. Including the guarding of the
-- upper limit of 1024 - 1 and lower limit of 0. Going outside these bounds will not cause any
-- problems but this will ensure the duty will not.
--
-- duty {number}: The duty cycle of the specified pin, how much power.
local function update_duty(duty)
  if duty > M.duty_cycle_limit then
    duty = M.duty_cycle_limit
  end

  if duty < 0 then
    duty = 0
  end

  M.PWM.setduty(M.executing_pin, duty)
end

-- Increases the duty by the specified amount.
--
-- amount {number}: The amount to increase the duty.
local function increase_duty(amount)
  M.updateDuty(M.get_duty() + amount)
end

-- Decreases the duty by the specified amount.
--
-- amount {number}: The amount to decrease the duty.
local function decrease_duty(amount)
  M.updateDuty(M.get_duty() - amount)
end

-- returns the current dity on the current pin.
local function get_duty()
  return M.PWM.getduty(M.executing_pin)
end

M.configure = configure
M.stop = stop
M.close = close

M.update_executing_pin = update_executing_pin

M.update_duty = update_duty
M.increase_duty = increase_duty
M.decrease_duty = decrease_duty
M.get_duty = get_duty

return M