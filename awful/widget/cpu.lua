local setmetatable = setmetatable
local io = io
local math = math
local string = string
local table = table
local capi = { widget = widget,
               timer = timer }

module("awful.widget.cpu")


local function update()
  if conky_cpu_idle   == nil then conky_cpu_idle  = {} end
  if conky_cpu_total  == nil then conky_cpu_total = {} end

  local fd = io.open("/proc/stat", "r");
  local proc_stat = {}
  if fd~=nil then
    for line in fd:lines() do
      table.insert(proc_stat, line);
    end
    io.close(fd)
  end

  local cpu_idle  = {}
  local cpu_total = {}
  local cpu_usage = {}
  for cpu_n = 1, #proc_stat do
    local line = cpu_n + 1 --to skip line with summed cpu's
    if string.sub(proc_stat[line],1,3)=="cpu" then
      local cpu_split = {}
      local _idle     = 0
      local _total    = 0
      local cpu_line = string.sub(proc_stat[line], 6, string.len(proc_stat[line]))
      for value in string.gmatch(cpu_line, "%S+") do
        table.insert(cpu_split, value)
        _total = _total + value
      end
      _idle = cpu_split[4]

      if conky_cpu_idle[cpu_n]  == nil then table.insert(conky_cpu_idle,  0) end
      if conky_cpu_total[cpu_n] == nil then table.insert(conky_cpu_total, 0) end

      local diff_idle   = _idle - conky_cpu_idle[cpu_n]
      local diff_total  = _total - conky_cpu_total[cpu_n]
      local usage       = (1000 * (diff_total-diff_idle)/diff_total + 5)/10

      table.insert(cpu_idle,  _idle)
      table.insert(cpu_total, _total)
      table.insert(cpu_usage, math.floor(usage) + 0)
    else
      break
    end
  end

  conky_cpu_idle = cpu_idle
  conky_cpu_total = cpu_total

  local cpu_text = {}
  for i=1, #cpu_usage do
    if cpu_usage[i] < 33 then
      table.insert(cpu_text,  cpu_usage[i] .. "%")
    elseif cpu_usage[i] < 66 then
      table.insert(cpu_text, "<span color='#ff0'>" .. cpu_usage[i] .. "%</span>")
    else
      table.insert(cpu_text, "<span color='#f00'>" .. cpu_usage[i] .. "%</span>")
    end
  end

  return table.concat(cpu_text, " ")
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
