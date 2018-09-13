--- === Fenestra ===
---
--- Window Manipulaiton

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "Fenestra"
obj.version = "0.1"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"
-- end Metadata

-- init logger
obj.logger = hs.logger.new('Fenestra')

-- init grid
hs.grid.MARGINX = 0
hs.grid.MARGINY = 0
hs.grid.GRIDWIDTH = 8
hs.grid.GRIDHEIGHT = 4
hs.grid.ui.textSize = 25
hs.grid.ui.cellStrokeColor = {0,0,0}
hs.grid.ui.highlightColor = {0,1,0,0.3}
hs.grid.ui.highlightStrokeColor = {0,1,0,1}
hs.grid.ui.cellStrokeColor = {1,1,1,0.3}

-- custom hints because i dont want to have to use function keys
-- also have to dupe first line otherwise the order gets fucked?
hs.grid.HINTS={
    { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }, 
    { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" },
    { "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P" }, 
    { "A", "S", "D", "F", "G", "H", "J", "K", "L", ";" }, 
    { "Z", "X", "C", "V", "B", "N", "M", ",", ".", "/" },
}

-- init obj history for undo
obj.history = {}

-- these are the basics i want for now
-- but im going to reevaliate them in future
obj.defaultHotkeys = {
    showGrid =              { {"ctrl"},                     "Space"},
    maxWin =                { {"alt"},                      "Space"},
    leftHalf =              { {"cmd", "alt"},               "left"},
    rightHalf =             { {"cmd", "alt"},               "right"},
    left75 =                { {"cmd", "alt", "ctrl"},       "left"},
    right25 =               { {"cmd", "alt", "ctrl"},       "right"},
    pushWindowNext =        { {"cmd", "alt", "ctrl"},       "N"},
    pushwindowPrevious =    { {"cmd", "alt", "ctrl"},       "P"},
}

-- hotkey binding not working
function obj:bindHotkeys(keys)
    assert(keys['showGrid'], "Hotkey variable is 'showGrid'")
    assert(keys['maxWin'], "Hotkey variable is 'maxWin'")
    assert(keys['leftHalf'], "Hotkey variable is 'leftHalf'")

    hs.hotkey.bindSpec(
        keys["showGrid"],
        function()
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
end

-- init grid


-- disable animation
hs.window.animationDuration = 0

function obj:maxWin()
    hs.grid.maximizeWindow()
end

-- how do i easily replicate this shit with grid?
function obj:leftHalf()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    f.x = max.x
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h
    win:setFrame(f)
end

-- Fenestra:undo()
function obj:undo()
    local cwin = hs.window.focusedWindow()
    local cwinid = cwin:id()
    for idx,val in ipairs(obj.history) do
        -- Has this window been stored previously?
        if val[1] == cwinid then
            cwin:setFrame(val[2])
        end
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