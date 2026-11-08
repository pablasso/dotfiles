-- Shared Hammerspoon config. Per-machine checks live in ~/.hammerspoon/machine.lua,
-- which is not in this repo.

local home = os.getenv("HOME")
local configDir = home .. "/.hammerspoon/"
local repoDir = home .. "/.dotfiles/hammerspoon/.hammerspoon/"
local machinePath = configDir .. "machine.lua"

require("hs.ipc") -- lets the `hs` command-line tool talk to Hammerspoon
hs.autoLaunch(true)

-- Reload on .lua changes. Editing a shared file changes it in the repo, not the
-- symlink in ~/.hammerspoon, so watch both places. Globals stop the watchers
-- from being garbage-collected.
local function reloadOnLuaChange(paths)
  for _, path in ipairs(paths) do
    if path:match("%.lua$") then
      hs.reload()
      return
    end
  end
end
configWatchers = {
  hs.pathwatcher.new(repoDir, reloadOnLuaChange):start(),
  hs.pathwatcher.new(configDir, reloadOnLuaChange):start(),
}

local machine, machineError = { checks = {} }, nil
if hs.fs.attributes(machinePath) then
  local ok, result = pcall(dofile, machinePath)
  if ok and type(result) == "table" then
    machine = result
  else
    machineError = ok and "machine.lua must return a table" or tostring(result)
    print("machine.lua: " .. machineError)
  end
end

statusMonitor = require("status").start(machine.checks, {
  defaults = machine.defaults,
  error = machineError,
})

hs.alert.show("Hammerspoon config loaded")
