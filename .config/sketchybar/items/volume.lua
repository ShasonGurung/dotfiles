local colors = require("colors")

local volume = sbar.add("item", "volume", {
  position = "right",
  icon = { string = "󰕾", color = colors.magenta },
  label = { string = "--%" },
  scroll_texts = true,
  click_script = "osascript -e 'set volume output muted not (output muted of (get volume settings))'",
})

local function set_volume(value)
  local level = tonumber(value) or 0
  local icon = level == 0 and "󰖁" or (level < 35 and "󰕿" or (level < 70 and "󰖀" or "󰕾"))
  volume:set({ icon = { string = icon }, label = { string = level .. "%" } })
end

volume:subscribe("volume_change", function(env)
  set_volume(env.INFO)
end)

volume:subscribe("mouse.scrolled", function(env)
  local delta = tonumber(env.SCROLL_DELTA or env.INFO) or 0
  sbar.exec("osascript -e 'set volume output volume (output volume of (get volume settings) + " .. delta * 4 .. ")'")
end)

sbar.exec("osascript -e 'output volume of (get volume settings)'", set_volume)
