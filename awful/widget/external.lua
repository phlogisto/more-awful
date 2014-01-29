local setmetatable = setmetatable
local io = io
local capi = { widget = widget,
               timer = timer }

module("awful.widget.external")


local function update(command)
  --TODO: check if popen works
  local fd = io.popen(command)
  local output = fd:read("*all")
  io.close(fd)
  
  return output
end

function new(args)
  local args      = args or {}
  local timeout   = args.timeout or 600
  local command   = args.command or ""
  local title     = args.title or ""
  local subtitle  = args.subtitle or ""
  args.type = "textbox"
  local w = capi.widget(args)
  local timer = capi.timer { timeout = timeout }
  w.text = title..update(command)..subtitle
  timer:add_signal("timeout", function() w.text = title..update(command)..subtitle end)
  timer:start()
  return w
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=2:softtabstop=2:textwidth=80
