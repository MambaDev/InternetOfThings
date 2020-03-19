
local UTILS  = {}

-- # trilateration formulas to return the (x,y) intersection point of three circles
local function trilateration(x1,y1,r1,x2,y2,r2,x3,y3,r3)
  local A = 2*x2 - 2*x1
  local B = 2*y2 - 2*y1
  local C = math.pow(r1, 2) - math.pow(r2, 2) - math.pow(x1, 2) + math.pow(x2, 2) - math.pow(y1, 2) + math.pow(y2, 2)
  local D = 2*x3 - 2*x2
  local E = 2*y3 - 2*y2
  local F = math.pow(r2, 2) - math.pow(r3, 2) - math.pow(x2,2) + math.pow(x3,2) - math.pow(y2,2) + math.pow(y3,2)
  local x = (C*E - F*B) / (E*A - B*D)
  local y = (C*D - A*F) / (B*D - A*E)

  return x, y
end

-- ######################
-- ToA - Time Of Arrival
-- 
--  Distance = Velocity * Travel Time
--  Travel Time = Receiving Timestamp - Sending Timestamp
--  The problem becomes how to validate the timestamp
--  • Synchronization
-- ######################

-- Wave velocity difference based:
--  Two waves of different velocity are sent from the sender
--  • Can be an electromagnetic wave + a sound wave
--  Record the timestamp in receiver only
--  • Arrival timestamp of electromagnetic wave tr
--  • Arrival timestamp of sound wave ts
local function time_of_arrival_wave_velocity(vr, vs, ts, tr)
  return (vr * vs * (ts - tr)) / (vr - vs)
end

--  Two waves of different velocity are sent from the sender
--  • Can be an electromagnetic wave + a sound wave
--  Record the timestamp in receiver only
--  • Arrival timestamp of electromagnetic wave tr
--  • Arrival timestamp of sound wave ts
local function time_of_arrival_return_time(v, t, t0, t_delay)
  return (v * (t - t0 - t_delay)) / 2
end

-- ######################
-- Time Difference of Arrival
--  Difference of Distance based
--  Improvement: does not require the receiver to be synchronized
--  Limitation: still require all the senders' clocks to be synchronized
-- ######################

-- Principle
--  Distance Difference = Velocity * (Travel Time 1 - Travel Time 2)
--  The target sends out the signal, two receivers are used
--  The position of the target/sender (x,y) is determined by
--  • The positions of receiver 1 (xi,yi) and receiver 2 (xj,yj)
--  • The calculated distance difference Δdij
--  2 groups of data/differences are needed to solve the equation
-- 
-- Limitations for both ToA and TDoA
--  Require customised sender and receiver
--  Additional device
--  Additional cost
local function time_difference_of_arrival(x1, y1, x2, y2, x3, y3)
  return math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2)) -
    math.sqrt(math.pow(x1 - x3, 2) + math.pow(y1, y3))
end

-- #################

-- WIFI BASED LOCALIZATION
-- Steps:
--  Scan the available APs
--  Get the RSSI for each reference
--  Filter the RSSI of outliers
--  Calculate the position
  -- • Formula required
  -- • RSSI = – (10*n*log10d + R)
  --  • R is the RSSI when distance is 1 unit, d is the distance, n is the factor

-- (RSSI) Received Signal Strength Indication
-- R is the RSSI when distance is 1 unit, d is the distance, n is the factor
-- Prior setup:
--  Measure the initial RSSI
--  Potisions of APs should be stable
local function received_signal_strength_indication(n, d, R)
  return -(10 * n * math.log(d, 10) + R)
end

UTILS.trilateration = trilateration

UTILS.time_of_arrival_wave_velocity = time_of_arrival_wave_velocity
UTILS.time_of_arrival_return_time = time_of_arrival_return_time
UTILS.time_difference_of_arrival = time_difference_of_arrival

UTILS.received_signal_strength_indication = received_signal_strength_indication

return UTILS
