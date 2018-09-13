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

-- init obj history for undo
obj.history = {}

-- Fenestra.defaultHotkeys
--
-- Table containing a sample set of hotkeys that can be
-- assigned to the different operations. These are not bound
-- by default - if you want to use them you have to call:
-- `spoon.Fenestra:bindHotkeys(spoon.Fenestra.defaultHotkeys)`
-- after loading the spoon. Value:
-- ```
--  {
--     screen_left = { {"ctrl", "alt", "cmd"}, "Left" },
--     screen_right= { {"ctrl", "alt", "cmd"}, "Right" },
--  }
-- ```
obj.defaultHotkeys = {
    maxWin = { {"alt"}, "Space" },
 }

obj.hotkeyShow = nil

-- hotkey binding not working
function obj:bindHotkeys(keys)
    hs.hotkey.bindSpec(keys["maxWin"], function()
        self:maxWin()
    end)
end

-- init grid
hs.grid.MARGINX = 0
hs.grid.MARGINY = 0
hs.grid.GRIDWIDTH = 10
hs.grid.GRIDHEIGHT = 10

-- disable animation
hs.window.animationDuration = 0

function obj:maxWin()
    hs.grid.maximizeWindow()
end

--- WinWin:undo()
--- Method
--- Undo the last window manipulation. Only those "moveAndResize" manipulations can be undone.
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