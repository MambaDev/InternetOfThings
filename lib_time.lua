
local TIME  = {
  UK_TIME_SERVER  = "uk.pool.ntp.org";
}


-- Syncronization with a given internet clock, used to improve timing and related cron job actions
-- that require good time mangement.
--
-- timer_server (string): the time server to connect to.
-- sync_callback (function): callback function when sync is done correctly.
-- fail_sync_callback (function): failed call back function when sync has failed.
--
-- Requires internet connection.
local function clock_syncronization(timer_server, sync_callback, fail_sync_callback)
  local server = timer_server or TIME.UK_TIME_SERVER;
  sntp.sync(server, sync_callback, fail_sync_callback)
end

-- Gets the current time stamp based on the rtctime and clock syncronization.
local function get_time_stamp()
  local seconds, microseconds, rate = rtctime.get()
  local c_time = rtctime.epoch2cal(seconds, microseconds, rate);

  return string.format("%04d/%02d/%02d %02d:%02d:%02d", c_time["year"], 
    c_time["mon"], c_time["day"], c_time["hour"], c_time["min"], c_time["sec"])
end

-- Setups a cronjob with the raw string provided. Reference related material for the structure on
-- how to use a cron job.
--
-- raw_input_string (string): The raw string for the cron job.
-- callback_function (function | nil): The callback function for the given cron job.
local function setup_cron_job(raw_input_string, callback_function)
  cron.schedule(raw_input_string, callback_function);
end

TIME.clock_syncronization = clock_syncronization;
TIME.setup_cron_job = setup_cron_job;
TIME.get_time_stamp = get_time_stamp;

return TIME;

