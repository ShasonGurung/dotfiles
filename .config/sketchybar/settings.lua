local settings = {
  font = "JetBrainsMono Nerd Font",
  weather_location = "",
}

local ok, local_settings = pcall(require, "local")
if ok then
  for key, value in pairs(local_settings) do
    settings[key] = value
  end
end

return settings
