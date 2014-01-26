local setmetatable = setmetatable
local io = io
local math = math
local string = string
local capi = { widget = widget,
               timer = timer }

module("awful.widget.battery")


local function update(bat_num)
  local bat_state       = "E"
  local bat_energy_now  = 0
  local bat_energy_full = 0
  local charge_symbol = { C = "<span weight='bold' color='#0ff'>⚡</span>",
                          D = "<span weight='bold' color='#ff0'>⌁</span>",
                          F = "⚡",
                          U = "<span weight='bold' color='#f00'>?</span>",
                          E = "<span weight='bold' color='#f00'>!</span>"   }

  local fd = io.open("/sys/class/power_supply/BAT"..bat_num.."/status", "r")
  if fd~=nil then
    bat_state = string.sub(fd:read("*all"), 1, 1)
    io.close(fd)
  end

  local fd = io.open("/sys/class/power_supply/BAT"..bat_num.."/energy_now", "r")
  if fd~=nil then
    bat_energy_now = fd:read("*all") + 0
    io.close(fd)
  end

  local fd = io.open("/sys/class/power_supply/BAT"..bat_num.."/energy_full", "r")
  if fd~=nil then
    bat_energy_full = fd:read("*all") + 0
    io.close(fd)
  end
 
  local bat_power=0
  if bat_energy_full~=0 then
     bat_power = math.floor(100 * bat_energy_now / bat_energy_full)
  end

  local bat_power_text = ""
  if bat_power > 40 then
    bat_power_text = bat_power .. "%"
  elseif bat_power > 20 then
    bat_power_text = "<span color='#ff0'>" .. bat_power .. "%</span>"
  else
    bat_power_text = "<span color='#f00'>" .. bat_power .. "%</span>"
  end
  
  return charge_symbol[bat_state]..bat_power_text
end


function new(args)
  local args      = args or {}
  local battery   = args.battery or 0
  local timeout   = args.timeout or 5
  local title     = args.title or ""
  local subtitle  = args.subtitle or ""
  args.type = "textbox"
  local w = capi.widget(args)
  local timer = capi.timer { timeout = timeout }
  w.text = title..update(battery)..subtitle
  timer:add_signal("timeout", function() w.text = title..update(battery)..subtitle end)
  timer:start()
  return w
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=2:softtabstop=2:textwidth=80
