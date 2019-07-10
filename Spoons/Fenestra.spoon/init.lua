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
]]

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

-- undo logic from @songchenwen:
-- https://github.com/songchenwen/dotfiles/blob/master/hammerspoon/undo.lua
local undostack = {
    stack = {},
    stackMax = 100,
    skip = false
}

-- grid size
hs.grid.MARGINX = 0
hs.grid.MARGINY = 0
hs.grid.GRIDWIDTH = 10
hs.grid.GRIDHEIGHT = 4

-- grid ui
hs.grid.ui.textSize = 40
hs.grid.ui.highlightColor = {0, 1, 0, 0.3}
hs.grid.ui.highlightStrokeColor = {0, 1, 0, 0.4}
hs.grid.ui.cellStrokeColor = {1, 1, 1, 1}
hs.grid.ui.cellStrokeWidth = 2
hs.grid.ui.highlightStrokeWidth = 20
hs.grid.ui.showExtraKeys = false

-- custom grid hints
-- because i dont want to use fn keys
hs.grid.HINTS = {
    {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"},
    {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"},
    {"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"},
    {"A", "S", "D", "F", "G", "H", "J", "K", "L", ";"},
    {"Z", "X", "C", "V", "B", "N", "M", ",", ".", "/"}
}

-- these are the basics i want for now
-- but im going to reevaliate them in future
obj.defaultHotkeys = {
    showGrid = {{"ctrl"}, "Space"},
    maxWin = {{"alt"}, "Space"},
    leftHalf = {{"cmd", "alt"}, "left"},
    rightHalf = {{"cmd", "alt"}, "right"},
    leftMaj = {{"cmd", "alt", "ctrl"}, "left"},
    rightMin = {{"cmd", "alt", "ctrl"}, "right"},
    pushWest = {{"cmd", "alt", "ctrl"}, "W"},
    pushEast = {{"cmd", "alt", "ctrl"}, "E"},
    pushNext = {{"ctrl", "alt", "cmd"}, "P"},
    undo = {{"cmd", "alt", "ctrl"}, "Z"}
}

-- hotkey binding not working
function obj:bindHotkeys(keys)
    assert(keys["showGrid"], "Hotkey variable is 'showGrid'")
    assert(keys["maxWin"], "Hotkey variable is 'maxWin'")
    assert(keys["leftHalf"], "Hotkey variable is 'leftHalf'")
    -- should finish asserts?

    hs.hotkey.bindSpec(
        keys["showGrid"],
        function()
            undostack:addToStack()
            hs.grid.show()
        end
    )
    hs.hotkey.bindSpec(
        keys["maxWin"],
        function()
            obj.logger.i("Full screen")
            undostack:addToStack()
            self.maxWin()
        end
    )
    hs.hotkey.bindSpec(
        keys["leftHalf"],
        function()
            obj.logger.i("Left one half")
            undostack:addToStack()
            self:leftHalf()
        end
    )
    hs.hotkey.bindSpec(
        keys["rightHalf"],
        function()
            obj.logger.i("Right one half")
            undostack:addToStack()
            self:rightHalf()
        end
    )
    hs.hotkey.bindSpec(
        keys["leftMaj"],
        function()
            obj.logger.i("Left two thirds")
            undostack:addToStack()
            self:leftMaj()
        end
    )
    hs.hotkey.bindSpec(
        keys["rightMin"],
        function()
            obj.logger.i("Right one third")
            undostack:addToStack()
            self:rightMin()
        end
    )
    hs.hotkey.bindSpec(
        keys["pushWest"],
        function()
            undostack:addToStack()
            obj.logger.i("Push Win Hotkey")
            self:pushWest()
        end
    )
    hs.hotkey.bindSpec(
        keys["pushEast"],
        function()
            undostack:addToStack()
            obj.logger.i("Pull Win Hotkey")
            self:pushEast()
        end
    )
    hs.hotkey.bindSpec(
        keys["pushNext"],
        function()
            undostack:addToStack()
            obj.logger.i("Push Next Hotkey")
            self:pushNext()
        end
    )
    hs.hotkey.bindSpec(
        keys["undo"],
        function()
            undostack:undo()
        end
    )
end

function obj.maxWin()
    hs.window.focusedWindow()
    hs.grid.maximizeWindow()
end

function obj:pushWest()
    obj.logger.d("Push Win Function")
    hs.window.focusedWindow():moveOneScreenWest()
end

function obj:pushEast()
    hs.window.focusedWindow():moveOneScreenEast()
end

function obj:pushNext()
    local currentWindow = hs.window.focusedWindow()
    local nextScreen = currentWindow:screen():next()
    currentWindow:moveToScreen(nextScreen)
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

function obj:leftHalf()
    obj:placeWindow(0, 0, 5, 4)
end

function obj:rightHalf()
    obj:placeWindow(5, 0, 5, 4)
end

function obj:leftMaj()
    obj:placeWindow(0, 0, 7, 4)
end

function obj:rightMin()
    obj:placeWindow(7, 0, 3, 4)
end

-- undo functions from
-- https://github.com/songchenwen/dotfiles/blob/master/hammerspoon/undo.lua
-- allows us to undo the window arrangement changes
-- keeps history
function undostack:addToStack(wins)
    if self.skip then
        return
    end
    if not wins then
        wins = {hs.window.focusedWindow()}
    end
    local size = #self.stack
    self.stack[size + 1] = self:getCurrentWindowsLayout(wins)
    size = size + 100
    if size > self.stackMax then
        for x = 1, size - self.stackMax do
            self.stack[x] = nil
        end
    end
end

function undostack:getCurrentWindowsLayout(wins)
    if not wins then
        wins = {hs.window.focusedWindow()}
    end
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
    if t1 == t2 then
        return true
    end
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
