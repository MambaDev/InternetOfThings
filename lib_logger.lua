local M = {
    debugging = false;
}

-- prints a message to the console with a time stamp and a given info message stamp.
--
-- message (string): The message being printed to the page.
local function info(message)
    print(string.format('INFO: %s', message));
end

-- prints a message with arguments to the console with a time stamp and a given info message stamp.
--
-- message (string): The message being printed to the page.
-- ... A infinite amount of string format arguments that will be unpacted.
local function infof(message, ...)
    info(string.format(message, unpack(arg)))
end

-- prints a message to the console with a time stamp and a given debug message stamp.
-- If debug is turned off on the main logger object, then this message will not show.
--
-- message (string): The message being printed to the page.
local function debug(message)
    if not M.debugging then
        return
    end

    print(string.format('DEBUG: %s', message));
end

-- prints a message to the console with a time stamp and a given debug message stamp.
-- If debug is turned off on the main logger object, then this message will not show.
--
-- message (string): The message being printed to the page.
-- ... A infinite amount of string format arguments that will be unpacted.
local function debugf(message, ...)
    debug(string.format(message, unpack(arg)))
end

M.info = info;
M.infof = infof;
M.debug = debug;
M.debugf = debugf;

return M