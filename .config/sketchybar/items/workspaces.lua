local colors = require("colors")

local workspace_event = "aerospace_workspace_change"
sbar.add("event", workspace_event)

local items = {}

local function update_workspace(item, visible, selected)
  item:set({ drawing = visible })
  sbar.animate("tanh", 12, function()
    item:set({
      label = { color = selected and colors.cyan or colors.muted },
    })
  end)
end

for index = 1, 10 do
  local workspace = tostring(index)
  local item = sbar.add("item", "workspace." .. workspace, {
    position = "left",
    drawing = false,
    icon = { drawing = false },
    label = {
      string = workspace,
      font = { size = 13.0 },
      padding_left = 7,
      padding_right = 7,
    },
    click_script = "aerospace workspace " .. workspace,
  })
  items[workspace] = item
end

local function refresh(focused_hint)
  sbar.exec("aerospace list-workspaces --monitor all --empty no", function(result)
    local occupied = {}
    for workspace in result:gmatch("[^%s]+") do
      occupied[workspace] = true
    end

    if focused_hint and focused_hint ~= "" then
      for workspace, item in pairs(items) do
        local visible = occupied[workspace] or workspace == focused_hint
        update_workspace(item, visible, workspace == focused_hint)
      end
      return
    end

    sbar.exec("aerospace list-workspaces --focused", function(focused_result)
      local focused = focused_result:gsub("%s+", "")
      for workspace, item in pairs(items) do
        local visible = occupied[workspace] or workspace == focused
        update_workspace(item, visible, workspace == focused)
      end
    end)
  end)
end

local observer = sbar.add("item", "workspace.observer", {
  drawing = false,
  updates = true,
  update_freq = 2,
})

observer:subscribe({ "routine", "forced" }, function()
  refresh()
end)

observer:subscribe(workspace_event, function(env)
  refresh(env.FOCUSED_WORKSPACE)
end)

refresh()
