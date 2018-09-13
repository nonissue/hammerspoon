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

-- figure out how to show hotkeys to user
obj.hotkeyShow = nil

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