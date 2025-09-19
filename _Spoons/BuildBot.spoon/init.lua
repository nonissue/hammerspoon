--- === BuildBot ===
---
--- Minimal SC2 build advisor overlay with pause/stop and proper Spoon lifecycle.
---
--- Download or place this folder as: ~/.hammerspoon/Spoons/BuildBot.spoon/
---
--- Usage:
---   local BA = hs.loadSpoon("BuildBot")
---   BA:bindHotkeys({
---     start = {{"ctrl","alt","cmd"}, "S"},
---     pause = {{"ctrl","alt","cmd"}, "P"},
---     resume = {{"ctrl","alt","cmd"}, "R"},
---     stop = {{"ctrl","alt","cmd"}, "X"},
---     toggle = {{"ctrl","alt","cmd"}, "H"},
---     reload = {{"ctrl","alt","cmd"}, "L"},
---   })
---   BA:setGameFilter("com.blizzard.starcraft2")
---   BA:loadBuild({
---     { time=12,  supply="14", action="Pylon at ramp" },
---     { time=17,  supply="16", action="Gateway" },
---     { time=20,  supply="17", action="Scout" },
---     { time=27,  supply="20", action="Cybernetics Core" },
---     { time=38,  supply="23", action="2nd Gas" },
---   })

local obj          = {}
obj.__index        = obj

obj.name           = "BuildBot"
obj.version        = "0.2.0"
obj.author         = "You"
obj.homepage       = "https://example.invalid"
obj.license        = "MIT"

-- Dependencies
local wf           = require("hs.window.filter")
local canvas       = require("hs.canvas")
local timer        = require("hs.timer")
local screen       = require("hs.screen")
local hotkey       = require("hs.hotkey")

local SaltParser   = dofile(hs.spoons.resourcePath("SaltParser.lua"))

-- ============ Config ============
obj.cfg            = {
    pollInterval = 0.2,  -- seconds
    maxVisibleSteps = 3, -- show current + next two
    textSize = 24,
    textColor = { white = 1, alpha = 0.96 },
    align = { x = "1%", y = "3%", w = "40%", h = "34%" },
    overlayLevel = "overlay",   -- topmost; "mainmenu" also works
    clickThrough = true,        -- ignore mouse/keyboard
    showOnlyWhenFocused = true, -- gated by bundleID filter
    bundleID = "com.blizzard.starcraft2",
    debug = false,              -- enable debug logging
}

-- ============ State ============
obj._build         = {}
obj._hud           = nil
obj._wf            = nil
obj._tick          = nil
obj._startEpoch    = nil -- when we pressed Start/Sync
obj._paused        = false
obj._pauseEpoch    = nil -- when pause began (epoch seconds)
obj._elapsedOffset = 0   -- accumulated elapsed when paused/stopped
obj._isShowing     = false

-- ============ Internal helpers ============
local function now() return timer.secondsSinceEpoch() end

local function debugLog(self, msg)
    if self.cfg.debug then
        hs.printf("[BuildBot] %s", msg)
    end
end

local function formatGameTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%d:%02d", mins, secs)
end

local function fmtStepLine(step, prefix, elapsed)
    if not step then return nil end
    local ahead = step.time - elapsed
    local sign = ahead >= 0 and "-" or "+"
    return string.format("%s[%s] %s%ds  %s  —  %s",
        prefix or "",
        formatGameTime(step.time),
        sign,
        math.floor(math.abs(ahead)),
        step.supply or "",
        step.action or ""
    )
end

function obj:_currentIndex(elapsed)
    if #self._build == 0 then return 1 end
    for i, s in ipairs(self._build) do
        if s.time > elapsed then
            return i
        end
    end
    return #self._build
end

function obj:_composeText(elapsed)
    if #self._build == 0 then
        return "No build loaded. Use :loadBuild(...) or :loadSALT(...)."
    end
    if not self._startEpoch then
        return "Press Start/Sync to begin (game timer)."
    end

    local currentIdx = self:_currentIndex(elapsed)
    local lines = {}

    lines[#lines + 1] = string.format("⏱  %s   %s\n\nCurrent / Next:",
        formatGameTime(elapsed),
        (self._paused and "[PAUSED]" or ""))

    -- Show previous step
    if currentIdx > 1 then
        local prevLine = fmtStepLine(self._build[currentIdx - 1], "   ", elapsed)
        if prevLine then
            lines[#lines + 1] = prevLine
        end
    end

    -- Show current step (what to do now) with arrow
    local currentLine = fmtStepLine(self._build[currentIdx], "➤ ", elapsed)
    if currentLine then
        lines[#lines + 1] = currentLine
    end

    -- Show next 2 steps
    for i = 1, 2 do
        local nextLine = fmtStepLine(self._build[currentIdx + i], "   ", elapsed)
        if nextLine then
            lines[#lines + 1] = nextLine
        end
    end

    return table.concat(lines, "\n")
end

function obj:_ensureHUD()
    if self._hud then return end
    local f = screen.mainScreen():frame()
    local c = canvas.new({ x = f.x, y = f.y, w = f.w, h = f.h })
    c:level(self.cfg.overlayLevel)
    c:clickActivating(false) -- never steal focus; allows click-through
    c[1] = { type = "rectangle", action = "fill", fillColor = { alpha = 0 }, stroke = false }
    c[2] = {
        type = "text",
        textSize = self.cfg.textSize,
        textFont = "Menlo",
        frame = self.cfg.align,
        text = {},
    }
    self._hud = c
end

function obj:_showHUD()
    self:_ensureHUD()
    if not self._isShowing then
        self._hud:show()
        self._isShowing = true
    end
end

function obj:_hideHUD()
    if self._hud and self._isShowing then
        self._hud:hide()
        self._isShowing = false
    end
end

function obj:_startTicker()
    if self._tick then
        self._tick:stop(); self._tick = nil
    end
    self._tick = timer.doEvery(self.cfg.pollInterval, function ()
        if not self._hud then return end
        local elapsed = 0
        if self._startEpoch and not self._paused then
            elapsed = (now() - self._startEpoch) + self._elapsedOffset
        else
            elapsed = self._elapsedOffset
        end
        -- Round to 1 decimal place to avoid floating point precision issues
        elapsed = math.floor(elapsed * 10 + 0.5) / 10
        local composedText = self:_composeText(elapsed)
        if type(composedText) == "string" then
            self._hud[2].text = composedText
            self._hud[2].textColor = self.cfg.textColor
        else
            self._hud[2].text = composedText
        end
    end)
end

function obj:_stopTicker()
    if self._tick then
        self._tick:stop(); self._tick = nil
    end
end

function obj:_cleanupWindowFilter()
    if self._wf then
        self._wf:unsubscribeAll()
        self._wf = nil
    end
end

function obj:_cleanupHotkeys()
    if self._hotkeys then
        for _, hk in pairs(self._hotkeys) do
            if hk then hk:delete() end
        end
        self._hotkeys = {}
    end
end

-- ============ Public API ============

--- BuildBot:loadBuild(buildTable)
--- Method
--- Load a build: array of { time=seconds, supply="##", action="..." }
function obj:loadBuild(buildTable)
    table.sort(buildTable, function (a, b) return (a.time or 0) < (b.time or 0) end)
    self._build = buildTable
    return self
end

--- BuildBot:loadSALT(saltString)
--- Method
--- Stub for SALT → internal table parsing. Replace with real parser if desired.
function obj:loadSALT(s)
    local parsed = SaltParser.parse(s)
    if not parsed or #parsed == 0 then
        debugLog(self, "SALT parse failed; keeping prior build.")
        return self
    end
    self._build = parsed
    return self
end

--- BuildBot:setGameFilter(bundleID)
--- Method
--- Show overlay only when this macOS app is focused (default: SC2).
function obj:setGameFilter(bundleID)
    self.cfg.bundleID = bundleID or self.cfg.bundleID
    self:_cleanupWindowFilter()

    if self.cfg.showOnlyWhenFocused and self.cfg.bundleID then
        self._wf = wf.new(false):allowApp(self.cfg.bundleID)
        self._wf:subscribe(wf.windowFocused, function () self:_showHUD() end)
        self._wf:subscribe(wf.windowUnfocused, function () self:_hideHUD() end)
    end
    return self
end

--- BuildBot:startTimer()
--- Method
--- Start/sync the timer (manual sync at game start).
function obj:startTimer()
    self:_ensureHUD()
    self:_showHUD()
    self._paused = false
    self._pauseEpoch = nil
    self._startEpoch = now()
    self:_startTicker()
    return self
end

--- BuildBot:pause()
--- Method
--- Pause the timer (freeze elapsed).
function obj:pause()
    if self._paused then return self end
    if not self._startEpoch then return self end
    self._paused = true
    self._pauseEpoch = now()
    -- Elapsed continues to be displayed via _elapsedOffset (in resume we add delta)
    return self
end

--- BuildBot:resume()
--- Method
--- Resume from pause without losing elapsed.
function obj:resume()
    if not self._paused then return self end
    if not self._startEpoch or not self._pauseEpoch then return self end
    local delta = now() - self._pauseEpoch
    -- We "skip over" the paused duration by subtracting it from startEpoch
    self._startEpoch = self._startEpoch + delta
    self._paused = false
    self._pauseEpoch = nil
    return self
end

--- BuildBot:stopTimer()
--- Method
--- Stop the timer and reset elapsed (keeps HUD visible).
function obj:stopTimer()
    self._startEpoch = nil
    self._paused = false
    self._pauseEpoch = nil
    self._elapsedOffset = 0
    self._completedSteps = {}
    -- HUD remains; text will prompt to Start
    return self
end

--- BuildBot:toggleHUD()
--- Method
function obj:toggleHUD()
    if self._hud and self._isShowing then
        self:_hideHUD()
    else
        self:_showHUD()
    end
    return self
end

--- BuildBot:resetElapsed()
--- Method
--- Keep timer stopped but preserve build; equivalent to stopTimer().
function obj:resetElapsed()
    return self:stopTimer()
end

--- BuildBot:bindHotkeys(map)
--- Method
--- map keys: start, pause, resume, stop, toggle, reload
--- BuildBot:bindHotkeys(map)
--- map keys: start, pause, resume, stop, toggle, reload
function obj:bindHotkeys(map)
    self:_cleanupHotkeys()
    self._hotkeys = {}

    local function safeBind(actionName, fn)
        local spec = map and map[actionName]
        if not spec then return end

        -- Accept either:
        -- 1) {mods, key}
        -- 2) {mods, key, pressedFn, releasedFn, repeatFn} (Hammerspoon-style)
        -- 3) {mods=..., key=..., pressed=..., released=..., repeatFn=...} (named)
        local mods, key, pressed, released, repeatFn

        if type(spec) == "table" and spec.mods and spec.key then
            mods     = spec.mods
            key      = spec.key
            pressed  = spec.pressed
            released = spec.released
            repeatFn = spec.repeatFn
        elseif type(spec) == "table" then
            mods     = spec[1]
            key      = spec[2]
            pressed  = spec[3]
            released = spec[4]
            repeatFn = spec[5]
        end

        -- Validate
        if type(mods) ~= "table" or (type(key) ~= "string" and type(key) ~= "number") then
            debugLog(self, string.format("Skipping hotkey '%s': expected {mods, key,...} but got %s",
                actionName, type(spec)))
            return
        end

        -- Delete previous binding if present (redundant now due to cleanup)
        if self._hotkeys[actionName] then
            self._hotkeys[actionName]:delete()
        end

        -- If caller didn’t provide custom pressed/released/repeat, use our fn
        local hk = hotkey.bind(mods, key, pressed or fn, released, repeatFn)
        self._hotkeys[actionName] = hk
    end

    safeBind("start", function () self:startTimer() end)
    safeBind("pause", function () self:pause() end)
    safeBind("resume", function () self:resume() end)
    safeBind("stop", function () self:stopTimer() end)
    safeBind("toggle", function () self:toggleHUD() end)
    safeBind("reload", function ()
        if self._build and #self._build > 0 then self:loadBuild(self._build) end
    end)

    -- Only start ticker when we have hotkeys bound and a build loaded
    if #self._build > 0 then
        self:_startTicker()
    end

    -- initial filter
    self:setGameFilter(self.cfg.bundleID)
    return self
end

-- ============ Spoon Lifecycle Methods ============

--- BuildBot:stop()
--- Method
--- Stop the spoon and clean up all resources (called on Hammerspoon reload)
function obj:stop()
    self:_stopTicker()
    self:_cleanupWindowFilter()
    self:_cleanupHotkeys()
    self:_hideHUD()
    if self._hud then
        self._hud:delete()
        self._hud = nil
    end
    return self
end

--- BuildBot:start()
--- Method
--- Initialize the spoon (called when loaded)
function obj:start()
    -- Minimal startup - actual initialization happens in bindHotkeys
    return self
end

-- ============ Spoon Metatable Boilerplate ============
function obj:new()
    local o = setmetatable({}, self)
    return o
end

return obj:new()
