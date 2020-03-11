KALMAN = {}
KALMAN.__index = KALMAN

function KALMAN:create(pin, press, long_press, released, long_press_delay)
  local this = {
    -- The pin number of the button pin executing_pin = pin;
    executing_ping = pin;

    -- The reference to the global GPIO object.
    GPIO = gpio;
    
    -- when the button is pressed call, method
    on_press = press;

    -- called when the button is then released.
    on_released = released;

    -- when the button is pressed for a long time, method
    on_long_press = long_press;

    -- if the button is currently pressed or not (1, 0)
    pressed = 0;

    -- pressed timer
    my_timer_pressed = tmr.create();

    -- how many iterations that the press is held, used to determine if the given button is being
    -- pressed for a long press or not.
    pressed_iteration_count = 0;

    -- if long pressed or not.
    long_pressed = 0;

    -- how many iterations are classed as a long press
    long_pressed_iteration = 10;
  }

  setmetatable(this, KALMAN)

  -- If no executing pin has been provided, return back early without setting up any timers or
  -- related data to the button, since its pointless without the pin.
  if this.executing_pin == nil then
    return this;
  end

  -- The fallback iteration count for if the provided  long_press_delay is nil.
  local fallback_long_pressed_iteration = this.long_pressed_iteration
  this.long_pressed_iteration = long_press_delay

  -- if a long press iteration has not been provided and the given value is nil, then fall back to
  -- the of 10 iterations of 100 milliseconds (1 second) for determing that the button is classed as
  -- a long pressed.
  if this.long_pressed_iteration == nil then
    this.long_pressed_iteration = fallback_long_pressed_iteration
  end

  -- Setup the executing pin ready for button input.
  this.GPIO.mode(this.executing_pin, this.GPIO.INPUT)
  this.GPIO.write(this.executing_pin, this.GPIO.LOW)

  -- setup the iteration timer for the button press, this will be handling if the button is pressed,
  -- released or also long pressed depending on how long the iteration is on and the button is down.
  this.my_timer_pressed:register(100, 1, function()
    -- read the pin value (1 = pressed, 0 = not pressed)
  local pin_reading = this.GPIO.read(this.executing_pin)

  -- if the pin reading is currently presed and we are not marked as currently pressed, then mark
  -- the button as pressed and trigger the pressed event if provided.
  if pin_reading == 1 and this.pressed == 0 then
    this.pressed = 1

    if this.on_press ~= nil then
      this.on_press()
    end
  end

  -- if the button is stating that its not being pressed and the current state is that the button is
  -- being presed. then reset press iteration, long press trigger and pressed trigger. Triggering
  -- the on release event if its been provided or not.
  if pin_reading == 0 and this.pressed == 1 then
    this.pressed_iteration_count = 0
    this.long_pressed = 0
    this.pressed = 0

    if this.on_released ~= nil then
      this.on_released()
    end
  end

  -- if the pin is reading pressed, we are marked as pressed and not marked as long press then
  -- iterate the press iteration count. If the press iteration count increases larger than the
  -- specified long press limit then mark as long pressed and reset call into the long press
  -- trigger. This process is reset when the button is released.
  if pin_reading == 1 and this.pressed == 1 and this.long_pressed == 0 then
    this.pressed_iteration_count = this.pressed_iteration_count + 1

    if this.pressed_iteration_count > this.long_pressed_iteration then
      this.long_pressed = 1

      if this.on_long_press ~= nil then
        this.on_long_press()
      end
    end
  end
  end)

  -- start the timer listening for the button pressed on the given pin.
  self.my_timer_pressed:start();

  return this
end

return KALMAN