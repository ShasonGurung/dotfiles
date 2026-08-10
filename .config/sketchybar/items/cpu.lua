local colors = require("colors")

local cpu = sbar.add("item", "cpu", {
  position = "right",
  update_freq = 3,
  icon = { string = "󰻠", color = colors.cyan },
  label = { string = "--%" },
})

cpu:subscribe({ "routine", "forced" }, function()
  sbar.exec("ps -A -o %cpu= | awk -v cores=\"$(sysctl -n hw.ncpu)\" '{s+=$1} END {printf \"%.0f\", s/cores}'", function(result)
    local usage = math.min(tonumber(result) or 0, 100)
    cpu:set({ label = { string = string.format("%d%%", usage) } })
  end)
end)
