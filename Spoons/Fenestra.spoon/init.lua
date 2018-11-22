--- === Fenestra ===
--- Method
--- * Window Manipulaiton
--- * Borrowed undo implementation from:
--- * github.com/heptal // https://goo.gl/HcebTk


-- other interesting ideas:
-- layouts (http://lowne.github.io/hammerspoon-extensions/)
-- snapping (ibid)

hs.window.animationDuration = 0

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
obj.logger = hs.logger.new('Fenestra')

-- grid size
hs.grid.MARGINX = 0
hs.grid.MARGINY = 0
hs.grid.GRIDWIDTH = 8
hs.grid.GRIDHEIGHT = 4

-- grid ui
hs.grid.ui.textSize = 40
-- hs.grid.ui.cellStrokeColor = {0,0,0}
hs.grid.ui.highlightColor = {0,1,0,0.3}
hs.grid.ui.highlightStrokeColor = {0,1,0,0.4}
hs.grid.ui.cellStrokeColor = {1,1,1,1}
hs.grid.ui.cellStrokeWidth = 2
hs.grid.ui.highlightStrokeWidth = 20
hs.grid.ui.fontName = 'Apercu Mono' -- should guard against this as it's not default
hs.grid.ui.showExtraKeys = false

-- custom grid hints
-- because i dont want to use fn keys
hs.grid.HINTS={
    { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }, 
    { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" },
    { "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P" }, 
    { "A", "S", "D", "F", "G", "H", "J", "K", "L", ";" }, 
    { "Z", "X", "C", "V", "B", "N", "M", ",", ".", "/" },
}

-- these are the basics i want for now
-- but im going to reevaliate them in future
obj.defaultHotkeys = {
    showGrid =              { {"ctrl"},                     "Space"},
    maxWin =                { {"alt"},                      "Space"},
    leftHalf =              { {"cmd", "alt"},               "left"},
    rightHalf =             { {"cmd", "alt"},               "right"},
    leftMaj =               { {"cmd", "alt", "ctrl"},       "left"},
    rightMin =              { {"cmd", "alt", "ctrl"},       "right"},
    pushWin =               { {"cmd", "alt", "ctrl"},       "N"},
    pullWin =               { {"cmd", "alt", "ctrl"},       "P"},
    undo =                  { {"cmd", "alt", "ctrl"},       "Z"},
}

-- hotkey binding not working
function obj:bindHotkeys(keys)
    assert(keys['showGrid'], "Hotkey variable is 'showGrid'")
    assert(keys['maxWin'], "Hotkey variable is 'maxWin'")
    assert(keys['leftHalf'], "Hotkey variable is 'leftHalf'")
    -- should finish asserts?

    hs.hotkey.bindSpec(
        keys["showGrid"],
        function()
            undo:push()
            hs.grid.show()
        end
    )
    hs.hotkey.bindSpec(
        keys["maxWin"],
        function()
            self:maxWin()
        end
    )
    hs.hotkey.bindSpec(
        keys["leftHalf"],
        function()
            self:leftHalf()
        end
    )
    hs.hotkey.bindSpec(
        keys["rightHalf"],
        function()
            self:rightHalf()
        end
    )
    hs.hotkey.bindSpec(
        keys["leftMaj"],
        function()
            self:leftMaj()
        end
    )
    hs.hotkey.bindSpec(
        keys["rightMin"],
        function()
            self:rightMin()
        end
    )
    hs.hotkey.bindSpec(
        keys["pushWin"],
        function()
            self:pushWin()
        end
    )
    hs.hotkey.bindSpec(
        keys["pullWin"],
        function()
            self:pullWin()
        end
    )
    hs.hotkey.bindSpec(
        keys["undo"],
        "Undoing last layout change",
        function()
            undo:pop() 
        end
    )
end

function obj:maxWin()
    undo:push()
    hs.grid.maximizeWindow()
end

function obj:pushWin()
    undo:push()
    hs.grid.pushWindowNextScreen()
end

function obj:pullWin()
    undo:push()
    hs.grid.pullWindowNextScreen()
end

function obj:placeWindow(x, y, w, h)
    function fn(cell)
        cell.x = x
        cell.y = y
        cell.w = w
        cell.h = h
        return hs.grid
    end
    hs.grid.adjustWindow(fn)
end

function obj:leftHalf()
    undo:push()
    obj:placeWindow(0, 0, 4, 4)
end

function obj:rightHalf()
    undo:push()
    obj:placeWindow(4, 0, 4, 4)
end

function obj:leftMaj()
    undo:push()
    obj:placeWindow(0, 0, 6, 4)
end

function obj:rightMin()
    undo:push()
    obj:placeWindow(6, 0, 2, 4)
end

-- undo for window operations
-- Borrowed undo implementation from:
-- github.com/heptal // https://goo.gl/HcebTk
local function rect(rect)
    return function()
      undo:push()
      local win = fw()
      if win then win:move(rect) end
    end
end

undo = {}

function undo:push()
  local win = fw()
  if win and not undo[win:id()] then
    self[win:id()] = win:frame()
  end
end

function undo:pop()
  local win = fw()
  if win and self[win:id()] then
    win:setFrame(self[win:id()])
    self[win:id()] = nil
  end
end

function obj:start()
  print("-- Starting fenestra")
  return self
end
  
function obj:stop()
  print("-- Stopping fenestra")

  if self.hotkeyShow then
      self.hotkeyShow:disable()
  end

  return self
end

function obj:init()
  return self
end

return obj