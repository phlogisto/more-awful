local setmetatable = setmetatable
local io = io
local math = math
local string = string
local table = table
local capi = { widget = widget,
               timer = timer }

module("awful.widget.ifstatus")

local function bytes_to_human(bytes)
  if bytes < 1024 then
    return (math.floor(bytes)).." B"
  elseif bytes < 1048576 then
    return (math.floor(bytes*100/1024)/100).." kB"
  elseif bytes < 1073741824 then
    return (math.floor(bytes*100/1048576)/100).." MB"
  else
    return (math.floor(bytes*100/1073741824)/100).." GB"
  end
end


local function update(interface, interval)
  if ifstatus_up    == nil then ifstatus_up   =0 end
  if ifstatus_down  == nil then ifstatus_down =0 end

  local fd = io.input("/proc/net/dev");
  local net_dev = {}
  for line in fd:lines() do
    table.insert(net_dev, line);
  end
  io.close(fd)
  
  local if_up         = 0
  local if_down       = 0
  local if_up_diff    = 0
  local if_down_diff  = 0
  for line = 1, #net_dev do
    local iface = {}
    for value in string.gmatch(net_dev[line], "%S+") do
      table.insert(iface, value)
    end
    if iface[1] == interface..":" then
      if_up         = iface[10]
      if_down       = iface[2]
      if_up_diff    = if_up   - ifstatus_up
      if_down_diff  = if_down - ifstatus_down
      break
    end
  end

  ifstatus_up   = if_up
  ifstatus_down = if_down

  return "↑"..bytes_to_human(if_up_diff/interval).."/s | ↓"..bytes_to_human(if_down_diff/interval).."/s"
end


function new(args)
  local args      = args or {}
  local timeout   = args.timeout or 2
  local interface = args.interface or "wlan0"
  local title     = args.title or ""
  local subtitle  = args.subtitle or ""
  args.type = "textbox"
  local w = capi.widget(args)
  local timer = capi.timer { timeout = timeout }
  w.text = title..update(interface,timeout)..subtitle
  timer:add_signal("timeout", function() w.text = title..update(interface,timeout)..subtitle end)
  timer:start()
  return w
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=2:softtabstop=2:textwidth=80
