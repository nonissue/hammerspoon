--- === Coach ===
---
--- SC2 Build Coach Overlay
---

--[[ 
  
Notes:
Overlay shown when games are in windowed (fullscreen) mode
Doesn't appear on top in true fullscreen mode
see: 
https://github.com/asmagill/hs._asm.guitk/blob/a93d53cb3cff70a6ff0d9de98a1cb238b65cb061/Examples/slidingPanel.lua
https://github.com/asmagill/hs._asm.undocumented.spaces/blob/master/examples/transition.lua
https://github.com/Hammerspoon/hammerspoon/issues/1184
]] --

-- inspiration:
-- https://github.com/Hammerspoon/Spoons/tree/master/Source/Shade.spoon

local obj = {}
obj.__index = obj

obj.name = "Coach"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.logger = hs.logger.new("Coach")
obj.hotkeyShow = nil

obj.menubar = nil
obj.menu = {}
obj.menubarIcon = "⚒︎"

obj.shownInMenu = true
obj.animate = false

obj.overlayShown = false
obj.textOverlay = nil

--- Coach:createOverlay()
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
    obj.textOverlay = hs.drawing.rectangle(obj.screenSize)

    -- use something like the following to create a transitiion:
    obj.overlay:setFillColor({["alpha"] = obj.overlayTransparency})
    -- obj.textOverlay:setFillColor({["alpha"] = obj.overlayTransparency})
    -- obj.menubar:setTitle("☀︎")
end

function obj.toggleOverlay()
    if obj.overlayShown then
        obj.overlay:hide()
        obj.textOverlay:hide()
    else
        obj.overlay:show()
        obj.textOverlay:show()
    end

    obj.overlayShown = not obj.overlayShown
end

--- Coach:init()
--- Method
--- Initialize our Coach spoon
--- - Deletes any existing menubars
--- - Deletes any leftover overlays
--- - Creates a new rect with current screenSize
--- - Sets rect properties
--- - Creates menubar item, adds it to menubar
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:init()
    obj.logger.i("-- Coach initialized")

    if obj.menubar then
        obj.menubar:delete()
    end

    if obj.overlay then
        obj.overlay:delete()
    end

    --Find out screen size. Currently using only the primary screen
    obj.screenSize = hs.screen.primaryScreen():fullFrame()

    -- Returns a hs.geometry rect describing screen's frame in absolute coordinates, including the dock and menu.
    -- might be better to do this with canvas?
    obj.overlay = hs.drawing.rectangle(obj.screenSize)
    obj.textOverlay = hs.drawing.text(obj.screenSize, "Coach")

    --- Coach.overlayTransparency
    --- Variable
    --- Set to greater than 1 so there is a slight delay before overlay starts fading out
    --- Probably not the best way to do this though
    obj.overlayTransparency = 0.9
    obj.timer = nil

    --white - the ratio of white to black from 0.0 (completely black) to 1.0 (completely white); default = 0.
    --alpha - the color transparency from 0.0 (completely transparent) to 1.0 (completely opaque)
    --Overlay characteristics
    obj.overlay:setFillColor({["white"] = 0.0, ["alpha"] = obj.overlayTransparency})

    obj.overlay:setStroke(false):setFill(true)

    obj.textOverlay:setTextColor({["white"] = 1.0, ["alpha"] = 1})
    obj.textOverlay:setText("Coach")
    obj.textOverlay:setBehavior(1500)

    --set to cover the whole screen, all spaces and expose
    obj.overlay:setBehavior(1500)

    obj.darkModeIsOn = false

    return self
end

--- Coach:start()
--- Method
--- Start
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
        obj.menubar:setTitle(obj.menubarIcon)
        obj.menubar:setClickCallback(obj.toggleOverlay)
        obj.menubar:setTooltip("Coach")
    end

    return
end

--- Coach:stop()
--- Method
--- Turn the overlay off, delete any timers
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:stop()
    obj.logger.df("-- Stopping Coach")

    if obj.overlay then
        obj.overlay:hide()
    end

    obj.timer = nil

    obj.darkModeIsOn = false
    obj.menubar:setTitle(obj.menubarIcon)
end

--- Coach.disable()
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

    if obj.overlay then
        obj.overlay:delete()
    end

    obj.overlay = nil
    obj.menubar = nil
    obj.screenSize = nil
    obj.timer = nil
end

return obj
