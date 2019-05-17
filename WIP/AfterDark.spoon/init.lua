-- inspiration:
-- https://github.com/Hammerspoon/Spoons/tree/master/Source/Shade.spoon
-- https://github.com/Hammerspoon/Spoons/blob/master/Source/FadeLogo.spoon/init.lua
-- https://github.com/HarshilShah/Nocturnal

--[[
Todo:
- [x] fix animation
- [x] handle new event while animating (cancel current?)
- [x] handle screensize change after init
- [x] add option to disable animation (Menubar dropdown?)
]]

local obj = {}
obj.__index = obj

obj.name = "AfterDark"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.logger = hs.logger.new("AfterDark")
obj.hotkeyShow = nil

obj.menubar = nil
obj.menu = {}

--- Spoon options
obj.shownInMenu = false
obj.animate = false

--- AfterDark.darkModeIsOn
--- Variable
--- Flag for Shade status, 'false' means shade off, 'true' means on.
obj.darkModeIsOn = nil

obj.darkModeScript = [[
    tell application "System Events"
	    tell appearance preferences
		    set dark mode to not dark mode
	    end tell
    end tell
]]

--- AfterDark:createOverlay()
--- Method
--- creates overlay that will be used during transition
--- This function checks the screen resolution in case it has
--- changed, and generates new rect if it has
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj.createOverlay()
    --In case there is already a overlay on the screen, first hide this one
    obj.overlay:hide()

    -- Find out screen size. Currently using only the primary screen
    -- obj.screenSize = hs.screen.primaryScreen():fulleFrame()
    if not obj.screenSize == hs.screen.primaryScreen():fullFrame() then
        obj.logger.i("screenSize changed since init, adjusting...")
        obj.screenSize = hs.screen.primaryScreen():fullFrame()
    end

    --Returns a hs.geometry rect describing screen's frame in absolute coordinates, including the dock and menu.
    obj.overlay = hs.drawing.rectangle(obj.screenSize)

    -- use something like the following to create a transitiion:
    obj.overlay:setFillColor({["alpha"] = obj.overlayTransparency})
    -- obj.menubar:setTitle("☀︎")
end

--- AfterDark:toggleDarkMode()
--- Method
--- Toggles dark mode while fading a rect that covers the whole screen
--- from black to completely transparent
--- This is done because there is sometimes a display with darkMode switch
--- in apps like safari
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj.toggleDarkMode()
    if obj.timer then
        hs.alert("Already transitioning!")
        return
    end

    hs.alert.closeAll()

    -- create our default overlay
    -- the createOverlay function also adjusts rect size
    -- if screen dimensions have changed
    if obj.animate then
        obj.createOverlay()
        obj.overlay:show()
    end

    hs.osascript.applescript(obj.darkModeScript)

    -- Kind of janky screen overlay / transition.
    -- Idea lifted and mispurposed from:
    -- https://github.com/Hammerspoon/Spoons/blob/master/Source/FadeLogo.spoon/init.lua
    if obj.animate then
        local origOpacity = obj.overlayTransparency
        obj.timer = hs.timer.doEvery(
            0.1,
            function()
                if obj.overlayTransparency > 0.1 then
                    obj.overlayTransparency = obj.overlayTransparency - 0.1
                    obj.overlay:setFillColor({["white"]=0.0, ["alpha"] = obj.overlayTransparency })
                else
                    obj.timer:stop()
                    obj.timer = nil
                    obj.overlay:hide()
                    obj.overlayTransparency = origOpacity
                end
        end)
    end

    -- In case we want an escape to make sure the rectangle overlay is truly gone
    -- hs.timer.doAfter(1.4, function() hs.alert("Ejecting...") timer:stop() obj:stop() end)
end


--- AfterDark:init()
--- Method
--- Initialize our AfterDark spoon
--- * Deletes any existing menubars
--- * Deletes any leftover overlays
--- * Creates a new rect with current screenSize
--- * Sets rect properties
--- * Creates menubar item, adds it to menubar
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:init()
    obj.logger.i("-- AfterDark initialized")

    if obj.menubar then
        obj.menubar:delete()
    end

    if obj.overlay then
        obj.overlay:delete()
    end

    --Find out screen size. Currently using only the primary screen
    obj.screenSize = hs.screen.primaryScreen():fullFrame()

    --Returns a hs.geometry rect describing screen's frame in absolute coordinates, including the dock and menu.
    -- might be better to do this with canvas?
    obj.overlay = hs.drawing.rectangle(obj.screenSize)

    --- AfterDark.rectTransparency
    --- Set to greater than 1 so there is a slight delay before overlay starts fading out
    --- Probably not the best way to do this though
    obj.overlayTransparency = 1.2
    obj.timer = nil

    --white - the ratio of white to black from 0.0 (completely black) to 1.0 (completely white); default = 0.
    --alpha - the color transparency from 0.0 (completely transparent) to 1.0 (completely opaque)
    --Overlay characteristics
    obj.overlay:setFillColor({ ["white"] = 0.0, ["alpha"] = obj.overlayTransparency })
    obj.overlay:setStroke(false):setFill(true)

    --set to cover the whole screen, all spaces and expose
    obj.overlay:bringToFront(false):setBehavior(17)

    obj.darkModeIsOn = false

    return self
end

--- AfterDark:start()
--- Method
---
--- Parameters:
---  * options - An optional table containing spoon configuration options
---
--- Returns:
---  * None
function obj:start(options)
    obj.init()

    if options then
        obj.shownInMenu = options.showMenu or obj.shownInMenu
        obj.animate = options.animate or obj.animate
    end

    --create icon on the menu bar and set flag to 'false'
    if obj.shownInMenu then
        obj.menubar = hs.menubar.new()
        obj.menubar:setTitle("☀︎")
        obj.menubar:setClickCallback(obj.toggleDarkMode)
        obj.menubar:setTooltip('AfterDark')
    end

    return
end

  --- AfterDark:stop()
  --- Method
  --- Turn the overlay off, delete any timers
  ---
  --- Parameters:
  ---  * None
  ---
  --- Returns:
  ---  * None
function obj.stop()
    obj.logger.df("-- Stopping AfterDark")

    if obj.overlay then
        obj.overlay:hide()
    end

    obj.timer = nil

    obj.darkModeIsOn = false
    obj.menubar:setTitle("︎︎︎☀︎")
end


--- AfterDark.disable()
--- Method
--- Stops the spoon and removes it from menubar
--- Cleans up any variables
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj.disable()
    if obj.menubar then
        obj.menubar:delete()
    end

    if obj.overlay then
        obj.overlay:delete()
    end

    obj.overlay = nil
    obj.menubar = nil
    obj.screenSize = nil
    obj.timer = nil
end

return obj
