local colors = require("colors")

local battery = sbar.add("item", "battery", {
  position = "right",
  update_freq = 60,
  icon = { string = "󰁹", color = colors.green },
  label = { string = "--%" },
  click_script = "open 'x-apple.systempreferences:com.apple.Battery-Settings.extension'",
})

battery:subscribe({ "routine", "forced", "power_source_change", "system_woke" }, function()
  sbar.exec("pmset -g batt | awk -F '; *' 'NR==2 {gsub(/%/,\"\",$1); sub(/^.*[[:space:]]/,\"\",$1); print $1, $2}'", function(result)
    local charge, state = result:match("(%d+)%s+(.+)")
    if not charge then
      battery:set({ drawing = false })
      return
    end

    local level = tonumber(charge) or 0
    local charging = state == "charging" or state == "charged"
    local icon = charging and "󰂄" or (level < 20 and "󰁺" or (level < 50 and "󰁾" or "󰁹"))
    battery:set({
      drawing = true,
      icon = { string = icon, color = level < 20 and colors.red or colors.green },
      label = { string = level .. "%" },
    })
  end)
end)
