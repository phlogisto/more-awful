local setmetatable = setmetatable
local io = io
local math = math
local string = string
local table = table
local capi = { widget = widget,
               timer = timer }

module("awful.widget.ram")


local function update()
  --TODO: check if popen works
  local fd = io.popen("free");
  local free = {}
  for line in fd:lines() do
    table.insert(free, line);
  end
  io.close(fd)
  
  local percentage = "?"
  for line = 1, #free do
    if string.sub(free[line],1,4)=="Mem:" then
      local mem_split = {}
      for value in string.gmatch(free[line], "%S+") do
        table.insert(mem_split, value)
      end
      local total = mem_split[2]
      local used  = mem_split[3]-mem_split[6]-mem_split[7]
      percentage = math.floor(100*used/total)
      break
    end
  end

  if percentage < 33 then
    return percentage.."%"
  elseif percentage < 66 then
    return "<span color='#ff0'>"..percentage.."%</span>"
  else
    return "<span color='#f00'>"..percentage.."%</span>"
  end 

  return percentage.."%"
end


function new(args)
  local args      = args or {}
  local timeout   = args.timeout or 2
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
