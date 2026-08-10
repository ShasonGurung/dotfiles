local colors = require("colors")

local front_app = sbar.add("item", "front_app", {
  position = "left",
  icon = { string = "󰣆", color = colors.magenta },
  label = { max_chars = 28 },
})

front_app:subscribe("front_app_switched", function(env)
  sbar.animate("sin", 10, function()
    front_app:set({ label = { string = env.INFO } })
  end)
end)
