--- === Context 2.0 ===
---
--- Change settings based on location and displays
--- Also, indicate current 'system' context with menubar item
--- eg. indicate which gpu is currently being used on computers with iGPU and dGPUs
---
--- MODEL:
--- watcher callback -> update applicable contextValues key -> actions fired on key change
--- How do we know what key to update? Okay, some logic in callback
---
--- event fires -->
--- event handler processes event, ascertains what has changed -->
--- change corresponding observable in obj.contextValues -->
--- watched detects change, rebuilds menu

--- screenWatcherCallback
---

local obj = {}
obj.__index = obj

obj.name = "Context 2.0"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.logger = hs.logger.new("Context")
obj.hotkeyShow = nil

obj.wifiWatcher = nil
obj.screenWatcher = nil
obj.cafWatcher = nil

obj.menubar = nil

obj.location = nil
obj.docked = nil

obj.currentSSID = nil
obj.currentScreens = nil
obj.lastNumberOfScreens = #hs.screen.allScreens()
obj.currentGPU = nil

obj.contextValues = hs.watchable.new("context", true)

-- spoon options
obj.shownInMenu = false
obj.display_ids = {}
obj.drives = {}
obj.homeSSIDs = hs.settings.get("homeSSIDs")

local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

obj.spoonPath = script_path()

obj.menuIcon = hs.image.imageFromPath(obj.spoonPath .. "/bold.grid.circle.fill.pdf"):setSize({w = 20, h = 20})

-- get value with obj.contextValuesWatcher:value('location')

--[[
    UPDATE: This whole thing needs a rewrite, way too complicated.
    Todo:
    - [ ] combine alerts when multiple callbacks are fired
    - [x] move SSIDs in hs key value store
    - [x] make sure all wake events are handle (screen, system)
    - [x] make sure everything is cleaned up if spoon is destroyed/unloaded
    - [x] move displays to hs key value store
    - [x] move list of drives to eject to hs key value store
    - [ ] somehow intuit which display is focused
]]
-- fetched from hs key/value store

-- exists in utilies library, but not accessible from spoon
local function has_value(tab, val)
    for index, value in ipairs(tab) do -- luacheck: ignore
        if value == val then
            return true
        end
    end

    return false
end

local function atHome(SSID)
    return has_value(homeSSIDs, SSID)
end

local function moveDockLeft()
    hs.applescript.applescript(
        [[
            tell application "System Events" to set the autohide of the dock preferences to true
            tell application "System Events" to set the screen edge of the dock preferences to left
        ]]
    )
end

local function moveDockDown()
    hs.applescript.applescript(
        [[
            tell application "System Events" to set the autohide of the dock preferences to false
            tell application "System Events" to set the screen edge of the dock preferences to bottom
      ]]
    )
end

--- Context.checkAndEject()
--- Method
--- check and eject
---
--- Parameters:
--- * target - a string containing the name of the drive we wish to eject
---
--- Returns:
---  * None
function obj.checkAndEject(target)
    target = "/Volumes/" .. target
    if hs.fs.volume.eject(target) then
        hs.alert.show("SUCCESS: Ejected " .. target, 3)
    else
        hs.alert.show("ERROR: Unable to eject " .. target, 3)
    end
end

function obj.screenChangeCallback()
    local newSSID = hs.wifi.currentNetwork()
    local currentSSID = obj.contextValues.currentSSID

    if (currentSSID == newSSID) then
        obj.logger.i("No change")
    elseif (atHome(newSSID)) then
        -- obj.homeArrived()
        obj.logger.i("@home")
        obj.contextValues.location = "@home"
    elseif not atHome(newSSID) and newSSID then
        -- obj.homeDeparted()
        obj.logger.i("@away")
        obj.contextValues.location = "@away"
    else
        -- obj.homeDeparted()
        if newSSID ~= nil then
            obj.logger.e("[#] Unhandled SSID: " .. newSSID)
        else
            obj.logger.e("[#] No SSID found!")
        end

        obj.contextValues.location = "@away"
    end

    obj.contextValues.currentSSID = newSSID
end

function obj.networkChangeCallback()
end

--- Context.watchers()
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj.watchers()
    obj.contextValuesWatcher =
        hs.watchable.watch(
        "context.*",
        function(_, _, key, old_value, new_value)
            hs.alert(
                "Watcher!\n" ..
                    tostring(key) .. " was changed from " .. tostring(old_value) .. " to " .. tostring(new_value)
            )
            hs.alert(obj.contextValues.location)
            obj.menubar:setMenu(
                obj.createMenu(obj.contextValues.location, obj.contextValues.docked, obj.contextValues.currentGPU)
            )
        end
    )
end

--- have different watchers for each value?

--- Context:init()
--- Method
--- init
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:init()
    if self.menubar then
        self.menubar:delete()
    end

    obj.display_ids = hs.settings.get("context.display_ids") or {}
    obj.drives = hs.settings.get("context.drives") or {}

    -- if options then
    --     obj.shownInMenu = options.showMenu or obj.shownInMenu
    --     obj.display_ids = options.display_ids or {}
    --     obj.drives = options.drives or {}
    -- end

    obj.initWifiWatcher()
    obj.initCafWatcher()
    obj.initScreenWatcher()

    obj.watchers()

    return self
end

--- Context:start()
--- Method
--- start
---
--- Parameters:
---  * options - An optional table containing spoon configuration options
---     showMenu - boolean which indicates whether menubar item is shown
---     animate - boolean which indicates whether ui mode toggle is animated
---
--- Returns:
---  * None
function obj:start(options)
    obj.logger.i("-- Starting Contexts")
    if self.hotkeyShow then
        self.hotkeyShow:enable()
    end

    if options then
        obj.shownInMenu = options.showMenu or obj.shownInMenu
        obj.display_ids = options.display_ids or {}
        obj.drives = options.drives or {}
    end

    obj.wifiWatcher:start()
    obj.cafWatcher:start()
    obj.screenWatcher:start()

    -- creates menubar item if desired
    -- currently menu functions dont do anything
    if obj.shownInMenu then
        obj.menubar = hs.menubar.new():setIcon(obj.menuIcon)
        obj.menubar:setMenu(obj.createMenu(_, _, obj.currentGPU))
    end

    return self
end

--- Context:stop()
--- Method
--- stop
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:stop()
    obj.logger.df("-- Stopping Contexts")
    if self.hotkeyShow then
        self.hotkeyShow:disable()
    end

    if obj.menubar then
        obj.menubar:delete()
    end

    obj.wifiWatcher:stop()
    obj.cafWatcher:stop()
    obj.screenWatcher:stop()
    obj.currentSSID = nil

    return self
end

return obj
