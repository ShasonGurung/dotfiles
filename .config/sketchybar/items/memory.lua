local colors = require("colors")

local memory = sbar.add("item", "memory", {
  position = "right",
  update_freq = 10,
  icon = { string = "󰍛", color = colors.green },
  label = { string = "--%" },
})

memory:subscribe({ "routine", "forced" }, function()
  sbar.exec("memory_pressure | awk '/System-wide memory free percentage/ {gsub(/%/,\"\",$5); printf \"%.0f\", 100-$5}'", function(result)
    memory:set({ label = { string = (tonumber(result) or 0) .. "%" } })
  end)
end)
