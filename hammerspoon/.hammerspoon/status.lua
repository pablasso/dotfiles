-- Menu bar status monitor.
--
-- Runs each check's shell command on its own timer and shows one combined
-- icon. A check passes when its command exits 0; the first line it prints is
-- shown as its detail in the menu.
--
-- Checks and their timing are defined per machine in ~/.hammerspoon/machine.lua
-- (see init.lua and ~/.dotfiles/unlinked/hammerspoon-machine.example.lua).

local M = {}

-- Used when neither the check nor machine.lua's `defaults` sets a value.
local BUILTIN_DEFAULTS = { every = 30, timeout = 10 } -- seconds
local MAX_DETAIL = 80

-- Hammerspoon starts as a GUI app, so it doesn't inherit the shell's PATH.
local EXTRA_PATH = "/opt/homebrew/bin:/usr/local/bin:" .. os.getenv("HOME") .. "/.local/bin"

local menubar, icons, menuIcons, configError
local checks, timers = {}, {}

-- Icons ----------------------------------------------------------------------
-- Drawn in the style of the SF Symbols circle, checkmark.circle and
-- exclamationmark.circle.fill. Black on transparent makes them template
-- images, which macOS recolors to match the menu bar and menus (light, dark,
-- highlighted). The failure icon is the exception: it stays red.

local INK = { white = 0, alpha = 1 }
local RED = { hex = "#E5534B" } -- muted red; macOS systemRed (#FF3B30) looked too saturated

local function buildIcons(size)
  local s = size / 18 -- shapes are designed on an 18pt grid
  local function pt(x, y) return { x = x * s, y = y * s } end
  local radius, width = 6.75 * s, 1.25 * s

  local function draw(elements, template)
    local canvas = hs.canvas.new({ x = 0, y = 0, w = size, h = size })
    canvas:appendElements(elements)
    local image = canvas:imageFromCanvas():template(template)
    canvas:delete()
    return image
  end

  local ring = { type = "circle", center = pt(9, 9), radius = radius,
                 action = "stroke", strokeWidth = width, strokeColor = INK }
  local check = { type = "segments", closed = false, action = "stroke", strokeWidth = 1.4 * s,
                  strokeCapStyle = "round", strokeJoinStyle = "round", strokeColor = INK,
                  coordinates = { pt(6.1, 9.2), pt(8.1, 11.2), pt(11.9, 7.0) } }
  -- Exclamation mark cut out of a filled red circle.
  local alert = {
    { type = "circle", center = pt(9, 9), radius = radius + width / 2, action = "fill", fillColor = RED },
    { type = "rectangle", frame = { x = 8.2 * s, y = 5.1 * s, w = 1.6 * s, h = 5.1 * s },
      roundedRectRadii = { xRadius = 0.8 * s, yRadius = 0.8 * s },
      action = "fill", fillColor = INK, compositeRule = "destinationOut" },
    { type = "circle", center = pt(9, 12.2), radius = 0.95 * s,
      action = "fill", fillColor = INK, compositeRule = "destinationOut" },
  }

  return {
    ok = draw({ ring, check }, true),
    pending = draw({ ring }, true),
    fail = draw(alert, false),
  }
end

-- Helpers --------------------------------------------------------------------

local function firstLine(text)
  local line = text and text:match("^%s*([^\r\n]*%S)")
  if line and #line > MAX_DETAIL then
    line = line:sub(1, MAX_DETAIL - 1) .. "…"
  end
  return line
end

local function ago(timestamp)
  local seconds = os.time() - timestamp
  if seconds < 60 then return seconds .. "s ago" end
  if seconds < 3600 then return math.floor(seconds / 60) .. "m ago" end
  return math.floor(seconds / 3600) .. "h ago"
end

local function seconds(value, fallback)
  value = tonumber(value)
  return (value and value > 0) and value or fallback
end

-- State ----------------------------------------------------------------------

local function render()
  local failed, pending = 0, 0
  for _, c in ipairs(checks) do
    if c.status == "fail" then failed = failed + 1 end
    if c.status == "pending" then pending = pending + 1 end
  end
  if configError then failed = failed + 1 end

  local state, title, tooltip
  if failed > 0 then
    -- macOS sits menu bar text 0.75pt above icon center (measured against the
    -- clock); lower the count so it centers on the circle. No color is set, so
    -- it keeps the menu bar's adaptive text color.
    title = hs.styledtext.new(tostring(failed), {
      font = hs.styledtext.defaultFonts.menuBar,
      baselineOffset = -0.75,
    })
    state, tooltip = "fail", failed .. " check(s) failing"
  elseif #checks == 0 then
    state, tooltip = "pending", "No checks configured"
  elseif pending > 0 then
    state, tooltip = "pending", "Running checks"
  else
    state, tooltip = "ok", "All " .. #checks .. " check(s) passing"
  end
  menubar:setIcon(icons[state], icons[state]:template())
  menubar:setTitle(title)
  menubar:setTooltip(tooltip)
end

local function notify(title, detail)
  hs.notify.new({ title = title, informativeText = detail or "" }):send()
end

local function finish(c, ok, detail)
  local previous = c.status
  c.status = ok and "ok" or "fail"
  c.detail = detail
  c.lastRun = os.time()
  -- Only alert on real transitions, so reloading the config doesn't re-notify.
  if previous == "ok" and not ok then
    notify(c.name .. " failed", detail)
  elseif previous == "fail" and ok then
    notify(c.name .. " recovered", detail)
  end
  render()
end

local function run(c)
  if not c.cmd or (c.task and c.task:isRunning()) then return end

  local timedOut = false
  c.task = hs.task.new("/bin/sh", function(exitCode, stdOut, stdErr)
    if c.killer then c.killer:stop(); c.killer = nil end
    local detail = firstLine(stdOut) or firstLine(stdErr)
    if timedOut then detail = "timed out after " .. c.timeout .. "s" end
    finish(c, exitCode == 0 and not timedOut, detail)
  end, { "-c", c.cmd })

  local env = c.task:environment()
  env.PATH = EXTRA_PATH .. ":" .. (env.PATH or "/usr/bin:/bin:/usr/sbin:/sbin")
  c.task:setEnvironment(env)

  if not c.task:start() then
    finish(c, false, "could not start /bin/sh")
    return
  end
  c.killer = hs.timer.doAfter(c.timeout, function()
    if c.task and c.task:isRunning() then
      timedOut = true
      c.task:terminate()
    end
  end)
end

local function runAll()
  for _, c in ipairs(checks) do run(c) end
end

local function buildMenu()
  local items = {}
  if configError then
    items[#items + 1] = { title = "machine.lua: " .. firstLine(configError), image = menuIcons.fail, fn = hs.openConsole }
    items[#items + 1] = { title = "-" }
  end
  if #checks == 0 then
    items[#items + 1] = { title = "No checks configured", disabled = true }
    items[#items + 1] = { title = "Add them to ~/.hammerspoon/machine.lua", disabled = true }
  end
  for _, c in ipairs(checks) do
    local detail = c.lastRun and string.format("%s (%s)", c.detail or "no output", ago(c.lastRun)) or "checking…"
    items[#items + 1] = {
      title = c.name .. ": " .. detail,
      image = menuIcons[c.status],
      fn = function() run(c) end, -- click a check to re-run it
    }
  end
  items[#items + 1] = { title = "-" }
  items[#items + 1] = { title = "Run all checks now", fn = runAll }
  items[#items + 1] = { title = "Open Hammerspoon console", fn = hs.openConsole }
  items[#items + 1] = { title = "Reload config", fn = hs.reload }
  return items
end

-- API ------------------------------------------------------------------------

-- defs:          list of { name = string, cmd = string, every = seconds?, timeout = seconds? }
-- opts.defaults: { every = seconds?, timeout = seconds? } for checks that don't set their own
-- opts.error:    a message to show as a failure (for example, machine.lua didn't load)
function M.start(defs, opts)
  opts = opts or {}
  configError = opts.error
  local defaults = opts.defaults or {}
  local every = seconds(defaults.every, BUILTIN_DEFAULTS.every)
  local timeout = seconds(defaults.timeout, BUILTIN_DEFAULTS.timeout)

  icons, menuIcons = buildIcons(18), buildIcons(16)
  menubar = hs.menubar.new(true, "dotfilesStatusMonitor")
  menubar:setMenu(buildMenu)

  for i, d in ipairs(defs or {}) do
    local c = {
      name = d.name or ("check " .. i),
      cmd = type(d.cmd) == "string" and d.cmd or nil,
      every = seconds(d.every, every),
      timeout = seconds(d.timeout, timeout),
      status = "pending",
    }
    if not c.cmd then
      c.status, c.detail, c.lastRun = "fail", "missing cmd", os.time()
    end
    checks[#checks + 1] = c
  end

  render()
  for _, c in ipairs(checks) do
    if c.cmd then
      run(c)
      timers[#timers + 1] = hs.timer.doEvery(c.every, function() run(c) end)
    end
  end
  return M
end

-- For debugging from the console or the `hs` CLI.
function M.summary()
  local out = { title = menubar and menubar:title(), checks = {} }
  for _, c in ipairs(checks) do
    out.checks[#out.checks + 1] = {
      name = c.name, status = c.status, detail = c.detail, lastRun = c.lastRun,
      every = c.every, timeout = c.timeout,
    }
  end
  return out
end

return M
