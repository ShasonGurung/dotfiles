local colors = require("colors")
local settings = require("settings")

sbar.bar({
  height = 32,
  color = 0xdd10131a,
  border_width = 0,
  blur_radius = 0,
  padding_left = 8,
  padding_right = 8,
  notch_width = 200,
  sticky = true,
  topmost = "window",
})

sbar.default({
  updates = "when_shown",
  padding_left = 2,
  padding_right = 2,
  icon = {
    font = { family = settings.font, style = "Bold", size = 13.0 },
    color = colors.cyan,
    padding_left = 4,
    padding_right = 2,
  },
  label = {
    font = { family = settings.font, style = "Semibold", size = 12.0 },
    color = colors.text,
    padding_left = 2,
    padding_right = 4,
  },
  background = {
    drawing = false,
  },
})

require("items.workspaces")
require("items.front_app")
require("items.media")
require("items.cpu")
require("items.memory")
require("items.network")
require("items.weather")
require("items.volume")
require("items.battery")
require("items.clock")

sbar.exec("sketchybar --update")
