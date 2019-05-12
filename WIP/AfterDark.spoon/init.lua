-- inspiration:
-- https://github.com/Hammerspoon/Spoons/tree/master/Source/Shade.spoon
-- https://github.com/Hammerspoon/Spoons/blob/master/Source/FadeLogo.spoon/init.lua
-- https://github.com/HarshilShah/Nocturnal

--[[
Todo:

- [ ] fix animation
- [ ] handle new event while animating (cancel current?)
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
obj.menu = {}

--Find out screen size. Currently using only the primary screen
obj.screenSize = hs.screen.primaryScreen()

--Returns a hs.geometry rect describing screen's frame in absolute coordinates, including the dock and menu.
-- might be better to do this with canvas?
obj.shade = hs.drawing.rectangle(obj.screenSize:fullFrame())

--- AfterDark.shadeTransparency
--- Variable
--- Set to greater than 1
obj.shadeTransparency = 1.2
obj.timer = nil

--shade characteristics
--white - the ratio of white to black from 0.0 (completely black) to 1.0 (completely white); default = 0.
--alpha - the color transparency from 0.0 (completely transparent) to 1.0 (completely opaque)
obj.shade:setFillColor({["blue"]=0.5, ["alpha"] = obj.shadeTransparency })
obj.shade:setStroke(false):setFill(true)

--set to cover the whole screen, all spaces and expose
obj.shade:bringToFront(false):setBehavior(17)

--- AfterDark.darkModeIsOn
--- Variable
--- Flag for Shade status, 'false' means shade off, 'true' means on.
obj.darkModeIsOn = nil

local lightMode = hs.image.imageFromASCII("1.........2\n" ..
"...........\n" ..
"...........\n" ..
".....b.....\n" ..
"...........\n" ..
"...........\n" ..
"....e.f....\n" ..
"...........\n" ..
"...a...c...\n" ..
"...........\n" ..
"4.........3",
{
{ strokeColor = { red = 1 }, fillColor = { alpha = 0.0 } },
{ strokeColor = { blue = 1 }, fillColor = { alpha = 0.0 }, shouldClose = false },
{ strokeColor = { green = 1 } },
{}
})

local darkMode = hs.image.imageFromASCII("1.........2\n" ..
"...........\n" ..
"...........\n" ..
".....b.....\n" ..
"...........\n" ..
"...........\n" ..
"....e.f....\n" ..
"...........\n" ..
"...a...c...\n" ..
"...........\n" ..
"4.........3",
{
{ strokeColor = { white = .75 }, fillColor = { alpha = 0.5 } },
{ strokeColor = { white = .75 }, fillColor = { alpha = 0.0 }, shouldClose = false },
{ strokeColor = { white = .75 } },
{}
})

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
    if obj.timer then
        hs.alert("Already transitioning!")
        return
    end
    hs.alert.closeAll()
    -- hs.alert("ANIMATING!", 0.5)
    obj.start()
    hs.osascript.applescript(obj.darkModeScript)
    -- super ugly transition as change is kind of janky
    -- idea lifted from: https://github.com/Hammerspoon/Spoons/blob/master/Source/FadeLogo.spoon/init.lua
    -- local timer
    local origOpacity = obj.shadeTransparency
    -- local opacity = obj.shadeTransparency + 0.3
    obj.timer = hs.timer.doEvery(
        1,
        function()
            if obj.shadeTransparency > 0.1 then
                obj.shadeTransparency = obj.shadeTransparency - 0.7
                obj.shade:setFillColor({["white"]=0.5, ["alpha"] = obj.shadeTransparency })
            else
                obj.timer:stop()
                obj.timer = nil
                obj.shade:hide()
                obj.shadeTransparency = origOpacity
            end
    end)
    -- obj.timer = nil
    -- can use the below function to eject during dev
    -- so we dont get a rectangle stuck on the screen covering everything lol
    -- hs.timer.doAfter(1.4, function() hs.alert("Ejecting...") timer:stop() obj:stop() end)
end

function obj:init()
    obj.logger.i("-- AfterDark initialized")

    if self.menubar then
        self.menubar:delete()
    end

    --create icon on the menu bar and set flag to 'false'
    self.menubar = hs.menubar.new()
    self.menubar:setTitle("☀︎")
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
    obj.shade:setFillColor({["alpha"] = obj.shadeTransparency})
    obj.shade:show()
    obj.darkModeIsOn = true
    obj.menubar:setTitle("☀︎")
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
    obj.menubar:setTitle("︎︎︎☀︎")
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
