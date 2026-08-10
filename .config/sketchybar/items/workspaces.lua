local colors = require("colors")

local workspace_event = "aerospace_workspace_change"
sbar.add("event", workspace_event)

local items = {}

local function update_workspace(item, visible, selected, display)
  item:set({
    drawing = visible,
    display = display,
  })
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

local workspace_format = "%{workspace}|%{monitor-appkit-nsscreen-screens-id}"

local function parse_workspaces(result)
  local workspaces = {}
  for line in result:gmatch("[^\r\n]+") do
    local workspace, display = line:match("^([^|]+)|(%d+)$")
    if workspace and display then
      workspaces[workspace] = tonumber(display)
    end
  end
  return workspaces
end

local function refresh()
  local occupied_command = "aerospace list-workspaces --monitor all --empty no --format '" .. workspace_format .. "'"
  sbar.exec(occupied_command, function(result)
    local occupied = parse_workspaces(result)

    local focused_command = "aerospace list-workspaces --focused --format '" .. workspace_format .. "'"
    sbar.exec(focused_command, function(focused_result)
      local focused_workspaces = parse_workspaces(focused_result)
      local focused, focused_display = next(focused_workspaces)

      for workspace, item in pairs(items) do
        local display = occupied[workspace]
        local selected = workspace == focused
        local visible = display ~= nil or selected

        if selected then
          display = focused_display
        end

        update_workspace(item, visible, selected, display)
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
  refresh()
end)

refresh()
