--- === Fenestra ===
--- Method
--- * Window Manipulaiton
--- * Borrowed undo implementation from:
--- * github.com/heptal // https://goo.gl/HcebTk
-- other interesting ideas:
-- layouts (http://lowne.github.io/hammerspoon-extensions/)
-- snapping (ibid)
--[[
    Todo:
        - Window snapping?
        - Forced layouts?
        - Vertical adjustments?
            - Use similar hotkeys as existing ones, just with ⬆ and ⬇ arrow keys
            - Would have to somehow refer to the current placement of the window for
            - x coordinates.
]] --
-- 22-10-28 BUG:
-- Sometimes moveScreenToNextWindow fails, as does "maximizing" a window.
-- This seems to occur:
-- 1. Mainly or only in safari
-- 2. When I'm using three displays (MBP Display, LG Ultrafine, Acer 4k)
-- The arrangement:
--
-- [ACER][LG]
-- [MBP]
--
-- info here:
-- https://github.com/Hammerspoon/hammerspoon/issues/3277
-- https://github.com/Hammerspoon/hammerspoon/issues/3224
-- https://github.com/Hammerspoon/hammerspoon/issues/3223
local obj = {}
obj.__index = obj

-- Metadata
obj.name = "Fenestra"
obj.version = "0.1"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue/hammerspoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"
-- end Metadata

-- init logger
obj.logger = hs.logger.new("Fenestra")

-- hs.screen.strictScreenInDirection = true
-- undo logic from @songchenwen:
-- https://github.com/songchenwen/dotfiles/blob/master/hammerspoon/undo.lua
local undostack = { stack = {}, stackMax = 100, skip = false }

-- grid size

hs.grid.MARGINX = 0
hs.grid.MARGINY = 0
hs.grid.GRIDWIDTH = 10
hs.grid.GRIDHEIGHT = 4

-- grid ui
hs.grid.ui.textSize = 40
hs.grid.ui.highlightColor = { 0, 1, 0, 0.3 }
hs.grid.ui.highlightStrokeColor = { 0, 1, 0, 0.4 }
hs.grid.ui.cellStrokeColor = { 1, 1, 1, 1 }
hs.grid.ui.cellStrokeWidth = 2
hs.grid.ui.highlightStrokeWidth = 20
hs.grid.ui.showExtraKeys = false

-- custom grid hints
-- because i dont want to use fn keys
hs.grid.HINTS = {
    { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" },
    { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" },
    { "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P" },
    { "A", "S", "D", "F", "G", "H", "J", "K", "L", ";" },
    { "Z", "X", "C", "V", "B", "N", "M", ",", ".", "/" }
}

-- these are the basics i want for now
-- but im going to reevaliate them in future
obj.defaultHotkeys = {
    showGrid = { { "ctrl", "alt", "cmd" }, "Space" },
    maxWin = { { "alt" }, "Space" },
    leftHalf = { { "cmd", "alt" }, "left" },
    rightHalf = { { "cmd", "alt" }, "right" },
    leftMaj = { { "cmd", "alt", "ctrl" }, "left" },
    rightMin = { { "cmd", "alt", "ctrl" }, "right" },
    pushWest = { { "cmd", "alt", "ctrl" }, "W" },
    pushEast = { { "cmd", "alt", "ctrl" }, "E" },
    moveWindowToNextScreen = { { "ctrl", "alt", "cmd" }, "N" },
    -- pushPrevious?
    pushUp = { { "ctrl", "alt", "cmd" }, "Up" },
    pushDown = { { "ctrl", "alt", "cmd" }, "Down" },
    undo = { { "cmd", "alt", "ctrl" }, "Z" },
    centerWindow = { { "cmd", "alt", "ctrl" }, "C" }
}

-- hotkey binding not working
function obj:bindHotkeys(keys)
    assert(keys["showGrid"], "Hotkey variable is 'showGrid'")
    assert(keys["maxWin"], "Hotkey variable is 'maxWin'")
    assert(keys["leftHalf"], "Hotkey variable is 'leftHalf'")
    -- should finish asserts?

    hs.hotkey.bindSpec(keys["showGrid"], function()
        undostack:addToStack()
        hs.grid.show()
    end)
    hs.hotkey.bindSpec(keys["maxWin"], function()
        obj.logger.i("Full screen")
        undostack:addToStack()
        self.maxWin()
    end)
    hs.hotkey.bindSpec(keys["leftHalf"], function()
        obj.logger.i("Left one half")
        undostack:addToStack()
        self:leftHalf()
    end)
    hs.hotkey.bindSpec(keys["rightHalf"], function()
        obj.logger.i("Right one half")
        undostack:addToStack()
        self:rightHalf()
    end)
    hs.hotkey.bindSpec(keys["leftMaj"], function()
        obj.logger.i("Left two thirds")
        undostack:addToStack()
        self:leftMaj()
    end)
    hs.hotkey.bindSpec(keys["rightMin"], function()
        obj.logger.i("Right one third")
        undostack:addToStack()
        self:rightMin()
    end)
    hs.hotkey.bindSpec(keys["pushUp"], function()
        undostack:addToStack()
        obj.logger.i("Push Win Hotkey")
        self:pushUp()
    end)
    hs.hotkey.bindSpec(keys["pushDown"], function()
        undostack:addToStack()
        obj.logger.i("Push Win Hotkey")
        self:pushDown()
    end)
    hs.hotkey.bindSpec(keys["pushWest"], function()
        undostack:addToStack()
        obj.logger.i("Push Win Hotkey")
        self:pushWest()
    end)
    hs.hotkey.bindSpec(keys["pushEast"], function()
        undostack:addToStack()
        obj.logger.i("Pull Win Hotkey")
        self:pushEast()
    end)
    hs.hotkey.bindSpec(keys["moveWindowToNextScreen"], function()
        undostack:addToStack()
        obj.logger.i("Push Window To Next Screen Hotkey")
        self:moveWindowToNextScreen()
    end)
    hs.hotkey.bindSpec(keys["centerWindow"], function()
        undostack:addToStack()
        obj.logger.i("Center Win")
        self:centerWindow()
    end)
    hs.hotkey.bindSpec(keys["undo"], function() undostack:undo() end)
end

function obj.maxWin()
    local cw = hs.window.focusedWindow()
    hs.grid.maximizeWindow(cw)
end

function obj:pushWest()
    obj.logger.d("Push West Function")
    local cw = hs.window.frontmostWindow()

    cw:moveOneScreenWest(_, true, 0)
end

function obj:pushEast() hs.window.focusedWindow():moveOneScreenEast() end

function obj:moveWindowToNextScreen()
    obj.logger.i("Move Window To Next Screen")
    local currentWindow = hs.window.focusedWindow()
    obj.logger.i(currentWindow)
    obj.logger.i(currentWindow:screen())
    obj.logger.i(currentWindow:screen():next())
    obj.logger.i(currentWindow:frame())
    local nextScreen = currentWindow:screen():next()
    currentWindow:moveToScreen(nextScreen, false, true, 0)
    currentWindow:maximize()
    -- currentWindow:
end

function obj.pushUp()
    local cw = hs.window.focusedWindow()
    local cwgrid = hs.grid.get(cw)
    hs.grid.set(cw, { cwgrid.x, 0, cwgrid.w, 2 })
end

function obj.pushDown()
    local cw = hs.window.focusedWindow()
    local cwgrid = hs.grid.get(cw)
    hs.grid.set(cw, { cwgrid.x, 2, cwgrid.w, 2 })
end

function obj:placeWindow(x, y, w, h)
    local function fn(cell)
        cell.x = x
        cell.y = y
        cell.w = w
        cell.h = h
        return hs.grid
    end

    hs.grid.adjustWindow(fn)
end

function obj:leftHalf() obj:placeWindow(0, 0, 5, 4) end

function obj:rightHalf() obj:placeWindow(5, 0, 5, 4) end

function obj:leftMaj() obj:placeWindow(0, 0, 7, 4) end

function obj:rightMin() obj:placeWindow(7, 0, 3, 4) end

function obj:centerWindow()
    local cw = hs.window.focusedWindow()
    cw:centerOnScreen(_, true, 0)
end

-- undo functions from
-- https://github.com/songchenwen/dotfiles/blob/master/hammerspoon/undo.lua
-- allows us to undo the window arrangement changes
-- keeps history
function undostack:addToStack(wins)
    if self.skip then return end
    if not wins then wins = { hs.window.focusedWindow() } end
    local size = #self.stack
    self.stack[size + 1] = self:getCurrentWindowsLayout(wins)
    size = size + 100
    if size > self.stackMax then
        for x = 1, size - self.stackMax do self.stack[x] = nil end
    end
end

function undostack:getCurrentWindowsLayout(wins)
    if not wins then wins = { hs.window.focusedWindow() } end
    local current = {}
    for i = 1, #wins do
        local w = wins[i]
        local f = w:frame()
        if w:isVisible() and w:isStandard() and w:id() and f then
            current[w] = f
        end
    end

    return current
end

local function compareFrame(t1, t2)
    if t1 == t2 then return true end
    if t1 and t2 then
        return t1.x == t2.x and t1.y == t2.y and t1.w == t2.w and t1.h == t2.h
    end
    return false
end

function undostack:undo()
    local size = #self.stack
    if size > 0 then
        local status = self.stack[size]
        for w, f in pairs(status) do
            if w and f and w:isVisible() and w:isStandard() and w:id() then
                if not compareFrame(f, w:frame()) then
                    w:setFrame(f)
                end
            end
        end
        self.stack[size] = nil
    else
        hs.alert("Nothing to Undo", 0.5)
    end
end

function obj:init()
    obj.logger.i("-- Loading Fenestra")
    return self
end

return obj
