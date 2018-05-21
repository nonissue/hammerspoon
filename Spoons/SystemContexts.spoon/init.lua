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


tell application "System Events"
  tell dock preferences
    get properties
  end tell
end tell
-----------------------------------------------------------
--]]

-- [ ] Migrate stuff from CHANGE_RES @ line 44

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

--- SystemContexts:start()
--- Method
--- Starts ___
---
--- Parameters:
---  * None
---
--- Returns:
---  * The ___ object
---
--- Notes:
---  * Some ___ plugins will continue performing background work even after this call (e.g. Spotlight searches)
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

--- SystemContexts:moveDockLeft()
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
function obj:moveDockLeft() 
  hs.applescript.applescript(
    [[
      tell application "System Events" to set the autohide of the dock preferences to true
      tell application "System Events" to set the screen edge of the dock preferences to left
    ]])
end

--- SystemContexts:moveDockDown()
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
function obj:moveDockDown() 
  hs.applescript.applescript(
    [[
      tell application "System Events" to set the autohide of the dock preferences to false
      tell application "System Events" to set the screen edge of the dock preferences to bottom
    ]])
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
return obj