--[[
    Todo:
    - [ ] combine alerts when multiple callbacks are fired
    - [ ] move SSIDs in hs key value store
    - [ ] make sure all wake events are handle (screen, system)
    - [ ] make sure everything is cleaned up if spoon is destroyed/unloaded
    - [ ] move displays to hs key value store
    - [ ] move list of drives to eject to hs key value store
]]


local obj = {}
obj.__index = obj

obj.name = "AfterDark"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.logger = hs.logger.new("MenuTest")
obj.hotkeyShow = nil

obj.menubar = nil
obj.menuIcon = "Test"
obj.menu = {}

--Find out screen size. Currently using only the primary screen
obj.screenSize = hs.screen.primaryScreen()

--Returns a hs.geometry rect describing screen's frame in absolute coordinates, including the dock and menu.
obj.shade = hs.drawing.rectangle(obj.screenSize:fullFrame())

--- Shade.shadeTransparency
--- Variable
--- Contains the alpha (transparency) of the overlay, from 0.0 (completely
--- transparent to 1.0 (completely opaque). Default is 0.5.
obj.shadeTransparency = 1.5


--shade characteristics
--white - the ratio of white to black from 0.0 (completely black) to 1.0 (completely white); default = 0.
--alpha - the color transparency from 0.0 (completely transparent) to 1.0 (completely opaque)
obj.shade:setFillColor({["white"]=0, ["alpha"] = obj.shadeTransparency })
obj.shade:setStroke(false):setFill(true)

--set to cover the whole screen, all spaces and expose
obj.shade:bringToFront(true):setBehavior(17)

--- Shade.darkModeIsOn
--- Variable
--- Flag for Shade status, 'false' means shade off, 'true' means on.
obj.darkModeIsOn = nil

--String containing an ASCII diagram to be rendered as a menu bar icon for when Shade is OFF.
obj.iconOff = "ASCII:" ..
". . . . . . . . . . . . . . . . . . . . .\n" ..
". . . . . . . . . . . . . . . . . . . . .\n" ..
". . . . . . . . . . . . . . . . . . . . .\n" ..
". . . 1 # # # # # # # # # # # # # 1 . . .\n" ..
". . . 4 . . . . . . . . . . . . . 2 . . .\n" ..
". . . # 5 = = = = = = = = = = = 5 # . . .\n" ..
". . . # . . . . . . . . . . . . . # . . .\n" ..
". . . # 6 = = = = = = = = = = = 6 # . . .\n" ..
". . . # . . . . . . . . . . . . . # . . .\n" ..
". . . # 7 = = = = = = = = = = = 7 # . . .\n" ..
". . . # . . . . . . . . . . . . . # . . .\n" ..
". . . # . . . . . . . . . . . . . # . . .\n" ..
". . . # . . . . . . . . . . . . . # . . .\n" ..
". . . # . . . . . . . . . . . . . # . . .\n" ..
". . . # . . . . . . . . . . . . . # . . .\n" ..
". . . # . . . . . . . . . . . . . # . . .\n" ..
". . . 4 . . . . . . . . . . . . . # . . .\n" ..
". . . 3 # # # # # # # # # # # # 3 2 . . .\n" ..
". . . . . . . . . . . . . . . . . . . . .\n" ..
". . . . . . . . . . . . . . . . . . . . .\n" ..
". . . . . . . . . . . . . . . . . . . . ."
--

--String containing an ASCII diagram to be rendered as a menu bar icon for when Shade is ON.
obj.iconOn = "ASCII:" ..
  ". . . . . . . . . . . . . . . . . . . . .\n" ..
  ". . . . . . . . . . . . . . . . . . . . .\n" ..
  ". . . . . . . . . . . . . . . . . . . . .\n" ..
  ". . . 1 # # # # # # # # # # # # # 1 . . .\n" ..
  ". . . 4 . . . . . . . . . . . . . 2 . . .\n" ..
  ". . . # 5 = = = = = = = = = = = 5 # . . .\n" ..
  ". . . # . . . . . . . . . . . . . # . . .\n" ..
  ". . . # 6 = = = = = = = = = = = 6 # . . .\n" ..
  ". . . # . . . . . . . . . . . . . # . . .\n" ..
  ". . . # 7 = = = = = = = = = = = 7 # . . .\n" ..
  ". . . # . . . . . . . . . . . . . # . . .\n" ..
  ". . . # 8 = = = = = = = = = = = 8 # . . .\n" ..
  ". . . # . . . . . . . . . . . . . # . . .\n" ..
  ". . . # 9 = = = = = = = = = = = 9 # . . .\n" ..
  ". . . # . . . . . . . . . . . . . # . . .\n" ..
  ". . . # a = = = = = = = = = = = a # . . .\n" ..
  ". . . 4 . . . . . . . . . . . . . # . . .\n" ..
  ". . . 3 # # # # # # # # # # # # 3 2 . . .\n" ..
  ". . . . . . . . . . . . . . . . . . . . .\n" ..
  ". . . . . . . . . . . . . . . . . . . . .\n" ..
  ". . . . . . . . . . . . . . . . . . . . ."
--

obj.darkModeScript = [[
    tell application "System Events"
	    tell appearance preferences
		    set dark mode to not dark mode
	    end tell
    end tell
]]

function obj.toggleDarkMode()
    obj.start()
    hs.osascript.applescript(obj.darkModeScript)

    -- super ugly transition as change is kind of janky
    local timer
    local origOpacity = obj.shadeTransparency
    timer = hs.timer.doEvery(
        0.05,
        function()
            if obj.shadeTransparency > 0.1 then
            obj.shadeTransparency = obj.shadeTransparency - 0.05
            obj.shade:setFillColor({["white"]=0, ["alpha"] = obj.shadeTransparency })
            else
            timer:stop()
            timer = nil
            obj.shade:hide()
            obj.shadeTransparency = origOpacity
            end
    end)
	-- else
    --     obj.logger.e("Error toggling Dark Mode")
	-- end
end

function obj:init()
    obj.logger.i("-- AfterDark initialized")

    if self.menubar then
        self.menubar:delete()
    end

    --create icon on the menu bar and set flag to 'false'
    self.menubar = hs.menubar.new()
    self.menubar:setIcon(obj.iconOff)
    self.menubar:setClickCallback(obj.toggleDarkMode)
    self.menubar:setTooltip('AfterDark')

    self.darkModeIsOn = false

    return self
end


--- Shade:start()
--- Method
--- Turn the shade on, darkening the screen
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj.start()
    --In case there is already a shade on the screen, first hide this one
    obj.shade:hide()

    --Find out screen size. Currently using only the primary screen
    obj.screenSize = hs.screen.primaryScreen()

    --Returns a hs.geometry rect describing screen's frame in absolute coordinates, including the dock and menu.
    obj.shade = hs.drawing.rectangle(obj.screenSize:fullFrame())

    -- use something like the following to create a transitiion:
    -- https://github.com/Hammerspoon/Spoons/blob/master/Source/FadeLogo.spoon/init.lua
    obj.shade:setFillColor({["alpha"] = obj.shadeTransparency })
    obj.shade:show()
    obj.darkModeIsOn = true
    obj.menubar:setIcon(obj.iconOn)
end

  --- Shade:stop()
  --- Method
  --- Turn the shade off, brightening the screen
  ---
  --- Parameters:
  ---  * None
  ---
  --- Returns:
  ---  * None
function obj.stop()
    obj.logger.df("-- Stopping AfterDark")

    obj.shade:hide()
    obj.darkModeIsOn = false
    obj.menubar:setIcon(obj.iconOff)
end

-- -- start watchers
-- function obj:start()

--     -- if self.hotkeyShow then
--     --     self.hotkeyShow:enable()
--     -- end

--     -- obj:init()

--     return self
-- end

-- stop watchers
-- function obj:stop()
--     obj.logger.df("-- Stopping Contexts")
--     if self.hotkeyShow then
--         self.hotkeyShow:disable()
--     end

--     obj.menubar:delete()

--     return self
-- end

return obj
