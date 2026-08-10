local colors = require("colors")

local media = sbar.add("item", "media", {
  position = "q",
  drawing = false,
  icon = { string = "󰎆", color = colors.magenta },
  label = { max_chars = 42 },
  click_script = "open -a Music",
})

media:subscribe("media_change", function(env)
  local info = env.INFO
  local playing = info and info.state == "playing"
  local artist = info and info.artist or ""
  local title = info and info.title or ""

  sbar.animate("tanh", 14, function()
    media:set({
      drawing = playing,
      label = { string = artist ~= "" and (artist .. " — " .. title) or title },
    })
  end)
end)
