local LIGHTS = { mode = { on= gpio.HIGH, off = gpio.LOW }; }
LIGHTS.__index  = LIGHTS

-- Creates a new instance of a single light control
--
-- pin:           The execution pin in switch the operations will take place.
-- starting_mode: The starting mode in which the pin will be in, on/off.
function LIGHTS:create(pin, starting_mode)
  local this = {
    state = starting_mode or LIGHTS.mode.off;
    executing_pin = pin or 4;
  }

  gpio.mode(this.executing_pin, gpio.OUTPUT);
  gpio.write(this.executing_pin, this.state);

  setmetatable(this, LIGHTS)

  return this;
end

-- Triggers the light to switch to the alternative light mode, e.g switching
-- between off and on and on and off based on the current state.
function LIGHTS:switch_mode()
 if self.state == self.mode.on then
    self.state = self.mode.off;
 else
  self.state = self.mode.on;
 end

 gpio.write(self.executing_pin, self.state);
end

-- Change the current light state to the provided state and if and only if
-- the provided state is not the already assigned mode.
--
-- state: The state being set, on or off.
function LIGHTS:change_mode(state)
  if state ~= nil and state ~= self.state then
    self.state = state;
    gpio.write(self.executing_pin, self.state)
  end
end

return LIGHTS