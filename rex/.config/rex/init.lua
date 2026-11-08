-- Resize panes: Cmd+Ctrl+Arrow = coarse, +Shift = fine (mirrors Ghostty config)
-- amount is a percentage of the split being divided (Rex default is 5)
for _, dir in ipairs({ "left", "right", "up", "down" }) do
  rex.bind("cmd+ctrl+" .. dir, "pane.resize", { direction = dir, amount = 5 })
  rex.bind("cmd+ctrl+shift+" .. dir, "pane.resize", { direction = dir, amount = 2 })
end
