local setmetatable = setmetatable
local io = io
local capi = { widget = widget,
               timer = timer }

module("awful.widget.user")


local function update()
  --TODO: check if popen works
  local fd = io.popen("echo -n `whoami`")
  local whoami = fd:read("*all")
  io.close(fd)
  return whoami
end

function new(args)
  local args      = args or {}
  local timeout   = args.timeout or 300
  local title     = args.title or ""
  local subtitle  = args.subtitle or ""
  args.type = "textbox"
  local w = capi.widget(args)
  local timer = capi.timer { timeout = timeout }
  w.text = title..update()..subtitle
  timer:add_signal("timeout", function() w.text = title..update()..subtitle end)
  timer:start()
  return w
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=2:softtabstop=2:textwidth=80
