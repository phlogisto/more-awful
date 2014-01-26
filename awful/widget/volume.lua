local setmetatable = setmetatable
local io = io
local tonumber = tonumber
local string = string
local capi = { widget = widget,
               timer = timer }

module("awful.widget.volume")


local function update()
  local fd = io.popen("amixer sget Master")
  local status = fd:read("*all")
  io.close(fd)
  
  local volume = "?"
  if tonumber(string.match(status, "(%d?%d?%d)%%")) ~= nil then
    volume = tonumber(string.match(status, "(%d?%d?%d)%%")) / 100
    status = string.match(status, "%[(o[^%]]*)%]")
  
    if string.find(status, "on", 1, true) then
      volume = volume*100 .. "%"
    else
      volume = "<span color='#f00'>-M-</span>"
    end
  end

  return volume
end

function refresh()
  return title..update()..subtitle
end

function new(args)
  local args      = args or {}
  local timeout   = args.timeout or 30
  title     = args.title or ""
  subtitle  = args.subtitle or ""
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
