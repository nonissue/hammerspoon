--- === ToggleDarkMode ===
---
--- Darkmode menubar toggle
---

local obj = {}
obj.__index = obj

obj.name = "ToggleDarkMode"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.logger = hs.logger.new("ToggleDarkMode")
obj.hotkeyShow = nil

obj.menubar = nil
obj.menu = {}

obj.shownInMenu = false

--- ToggleDarkMode.darkModeIsOn
--- Variable
--- Flag for darkmode status, 'false' means darkmode off, 'true' means on.
obj.darkModeIsOn = nil

obj.darkModeScript =
    [[
    tell application "System Events"
	    tell appearance preferences
		    set dark mode to not dark mode
	    end tell
    end tell
]]

function obj.toggleSystemAppearance()
    hs.osascript.applescript(obj.darkModeScript)
end

function obj:init()
    obj.logger.i("-- ToggleDarkMode initialized")

    if obj.menubar then
        obj.menubar:delete()
    end

    obj.darkModeIsOn = false

    return self
end

function obj:start(options)
    obj.init()

    if options then
        obj.shownInMenu = options.showMenu or obj.shownInMenu
    end

    --create icon on the menu bar and set flag to 'false'
    if obj.shownInMenu then
        obj.menubar = hs.menubar.new()
        obj.menubar:setTitle("☀︎")
        obj.menubar:setClickCallback(obj.toggleSystemAppearance)
        obj.menubar:setTooltip("ToggleDarkMode")
    end

    return
end

--- ToggleDarkMode:stop()
--- Method
--- Turn the overlay off, delete any timers
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:stop()
    obj.logger.df("-- Stopping ToggleDarkMode")

    obj.darkModeIsOn = false
    obj.menubar:setTitle("︎︎︎☀︎")
end

--- ToggleDarkMode.disable()
--- Method
--- Stops the spoon and removes it from menubar
--- Cleans up any variables
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:disable()
    if obj.menubar then
        obj.menubar:delete()
    end

    obj.menubar = nil
end

return obj
