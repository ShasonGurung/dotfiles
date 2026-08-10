local colors = require("colors")

local clock = sbar.add("item", "clock", {
  position = "q",
  update_freq = 10,
  icon = { string = "󰥔", color = colors.cyan },
  label = { string = "--:--" },
  click_script = "open -a Calendar",
})

clock:subscribe({ "routine", "forced", "system_woke" }, function()
  sbar.exec("date '+%a %d %b  %H:%M'", function(result)
    clock:set({ label = { string = result:gsub("%s+$", "") } })
  end)
end)
