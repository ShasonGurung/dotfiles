local colors = require("colors")

local network = sbar.add("item", "network", {
  position = "right",
  update_freq = 15,
  icon = { string = "󰖩", color = colors.cyan },
  label = { string = "offline", max_chars = 18 },
  click_script = "open 'x-apple.systempreferences:com.apple.Network-Settings.extension'",
})

network:subscribe({ "routine", "forced", "system_woke" }, function()
  sbar.exec("ipconfig getsummary en0 2>/dev/null | awk -F ' SSID : ' '/ SSID : / {print $2; exit}'", function(result)
    local name = result:gsub("%s+$", "")
    network:set({ label = { string = name ~= "" and name or "offline" } })
  end)
end)

local speed = sbar.add("item", "network.speed", {
  position = "right",
  update_freq = 2,
  icon = { drawing = false },
  label = { string = " --   --" },
})

local previous_down = nil
local previous_up = nil
local previous_time = nil

local function format_bits(bits)
  if bits >= 1000000000 then
    return string.format("%.1fGbps", bits / 1000000000)
  elseif bits >= 1000000 then
    return string.format("%.1fMbps", bits / 1000000)
  elseif bits >= 1000 then
    return string.format("%.0fKbps", bits / 1000)
  end
  return string.format("%.0fbps", bits)
end

speed:subscribe({ "routine", "forced", "system_woke" }, function()
  local command = [[iface=$(route -n get default 2>/dev/null | awk '/interface:/{print $2}'); netstat -ibn -I "$iface" 2>/dev/null | awk 'NR==2 {print $7, $10}']]
  sbar.exec(command, function(result)
    local down, up = result:match("(%d+)%s+(%d+)")
    down = tonumber(down)
    up = tonumber(up)
    local now = os.time()

    if down and up and previous_down and previous_up and previous_time then
      local elapsed = math.max(now - previous_time, 1)
      local down_bits = math.max(down - previous_down, 0) * 8 / elapsed
      local up_bits = math.max(up - previous_up, 0) * 8 / elapsed
      speed:set({
        label = { string = " " .. format_bits(up_bits) .. "   " .. format_bits(down_bits) },
      })
    end

    if down and up then
      previous_down = down
      previous_up = up
      previous_time = now
    end
  end)
end)
