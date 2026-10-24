-- Resize panes: Cmd+Ctrl+Arrow = coarse, +Shift = fine (mirrors Ghostty config)
-- amount is a percentage of the split being divided (Rex default is 5)
for _, dir in ipairs({ "left", "right", "up", "down" }) do
  rex.bind("cmd+ctrl+" .. dir, "pane.resize", { direction = dir, amount = 5 })
  rex.bind("cmd+ctrl+shift+" .. dir, "pane.resize", { direction = dir, amount = 2 })
end

-- rex-image-paste: Cmd+Shift+V pastes clipboard images as file paths, copying them to remote panes.
-- Machine-independent: does nothing where ~/.config/rex/rex-image-paste isn't cloned.
do
  local f = io.open((os.getenv("HOME") or "") .. "/.config/rex/rex-image-paste/init.lua")
  if f then
    f:close()
    require("rex-image-paste").setup()
    rex.bind("cmd+shift+v", "image_paste")
  end
end

-- rexurrect: restore saved sessions once each time the Rex server starts (keep this last).
-- Machine-independent: finds rexurrect under $HOME at runtime and does nothing where it isn't installed.
do
  local bin = (os.getenv("HOME") or "") .. "/.cargo/bin/rexurrect"
  local f = io.open(bin)
  if f then
    f:close()
    local r = rex.exec({ bin, "auto-restore" })
    if r then io.stderr:write(r.stderr) end
  end
end
