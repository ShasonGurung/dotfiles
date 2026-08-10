local colors = require("colors")
local settings = require("settings")

local weather = sbar.add("item", "weather", {
  position = "q",
  update_freq = 900,
  icon = { string = "󰖐", color = colors.yellow },
  label = { string = "--" },
  click_script = "open 'https://wttr.in/'",
})

weather:subscribe({ "routine", "forced", "system_woke" }, function()
  local location = settings.weather_location:gsub(" ", "+")
  local command = "curl -fsS --max-time 5 'https://wttr.in/" .. location .. "?format=%t+%C'"
  sbar.exec(command, function(result, exit_code)
    if exit_code == 0 then
      weather:set({ label = { string = result:gsub("%s+$", "") } })
    end
  end)
end)
