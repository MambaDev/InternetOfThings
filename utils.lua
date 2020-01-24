local M  = {}

local function starts_with(str, start)
  return str:sub(1, #start) == start
end

M.starts_with = starts_with
return M
