
local M  = {
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
  local server = timer_server or M.UK_TIME_SERVER;
  sntp.sync(server, sync_callback, fail_sync_callback)
end

-- Setups a cronjob with the raw string provided. Reference related material for the structure on
-- how to use a cron job.
--
-- raw_input_string (string): The raw string for the cron job.
-- callback_function (function | nil): The callback function for the given cron job.
local function setup_cron_job(raw_input_string, callback_function)
  cron.schedule(raw_input_string, callback_function);
end

M.clock_syncronization = clock_syncronization;
M.setup_cron_job = setup_cron_job;

return M;

