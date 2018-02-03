--[[ 

===========================================================
SystemContexts Spoon
-----------------------------------------------------------
Set and manage system defaults. Handle and manage config 
options as user env changes. 
  e.g.  * Sleep settings at school vs home
        * When using multiple monitors, diff res choices
        * Autoconfig layout for mobile vs at desk. Things
          like dock position, display arrangement, etc.



-----------------------------------------------------------
--]]


local obj = {}
obj.__index = obj

-- Metadata
obj.name = "SystemContexts"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.chooser = nil
obj.hotkeyShow = nil
obj.plugins = {}
obj.commands = {}

local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end
obj.spoonPath = script_path()

function obj:start()
    print("-- Starting SystemContexts")
    if self.hotkeyShow then
        self.hotkeyShow:enable()
    end
    return self
end

--- SystemContexts:stop()
--- Method
--- Stops ___
---
--- Parameters:
---  * None
---
--- Returns:
---  * The ___ object
---
--- Notes:
---  * Some ___ plugins will continue performing background work even after this call (e.g. Spotlight searches)
function obj:stop()
    print("-- Stopping SystemContexts")
    self.chooser:hide()
    if self.hotkeyShow then
        self.hotkeyShow:disable()
    end
    return self
end



function obj:moveDockLeft() 
  hs.applescript.applescript(
    [[
      tell application "System Events"
        tell dock preferences
          set properties to {dock size:0.2, animate:false, screen edge:left, class:dock preferences object}
        end tell
      end tell
    ]])
end

function obj:moveDockBottom() 
  hs.applescript.applescript(
    [[
      tell application "System Events"
        tell dock preferences
          set properties to {dock size:0.2, animate:false, screen edge:bottom, class:dock preferences object}
        end tell
      end tell
    ]])
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
return obj