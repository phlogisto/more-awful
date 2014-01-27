local setmetatable = setmetatable
local io = io
local table = table
local math = math
local string = string
local capi = { widget = widget,
               timer = timer }

module("awful.widget.uptime")


local function update()
  local uptime = "!?"
  local times = {}

  local fd = io.open("/proc/uptime", "r")
  if fd~=nil then
    for value in string.gmatch(fd:read("*all"), "%S+") do
      table.insert(times, value)
    end 
    io.close(fd)
    uptime = math.floor(times[1]/36)/100
  end

  return uptime
end

function new(args)
  local args      = args or {}
  local timeout   = args.timeout or 30
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
