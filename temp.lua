local audit = { limit =  10, history = {} }

local function audit_action(area, result, message)
  if table.getn(audit.history) >= audit.limit then table.remove(1, audit.history) end
  table.insert(audit.history, { area = area, result = result, message=message })
end

audit.audit_action = audit_action;

audit.audit_action("locking", "failed", "already locked")
audit.audit_action("unlocking", "success", "unlocked")
