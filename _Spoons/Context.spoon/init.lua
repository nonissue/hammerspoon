--- === Context ===
---
--- Change settings based on location and displays
--- Also, indicate current 'system' context with menubar item
--- eg. indicate which gpu is currently being used on computers with iGPU and dGPUs
---
--- TODO:

--- Handle ACD 30" @ line 288
--- use watchable to make logic simpler?
--- https://www.hammerspoon.org/docs/hs.watchable.html
--- eg. watch values, update menu when values change
--- have it working below!
--- hmmm, batch updates?
--- [x] observables implemented, and are firing menu recreation.
--- [ ] just need to simplify logic handling for action
--- [ ] reload resolute on docked <-> undocked transition
--- note: making something like this without good patterns
--- highlights the utility of sometihng like redux379752
--- watcher callback -> update applicable contextValues key -> actions fired on key change

--- event fires -->
--- event handler processes event, ascertains what has changed -->
--- change corresponding observable in obj.contextValues -->
--- watched detects change, rebuilds menu

local obj = {}
obj.__index = obj

obj.name = "Context"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.logger = hs.logger.new("Context")
obj.hotkeyShow = nil

obj.pendingAlert = false

obj.wifiWatcher = nil
obj.screenWatcher = nil
obj.cafWatcher = nil

obj.menubar = nil
-- obj.menuIcon = "@"

obj.menu = {}
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

local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

obj.spoonPath = script_path()

-- right so i like this one the best visually, but maybe it should change if unknown state is encoutered
-- or if there is a warning (eg. dgpu enabled?)
obj.menuIcon = hs.image.imageFromPath(obj.spoonPath .. "/bold.grid.circle.fill.pdf"):setSize({w = 20, h = 20})
-- obj.menuIcon = hs.image.imageFromPath(obj.spoonPath .. "/bold.number.circle.fill.pdf"):setSize({w = 18, h = 18})

-- get value with obj.contextValuesWatcher:value('location')

--[[
    UPDATE: This whole thing needs a rewrite, way too complicated.
    Todo:
    - [ ] combine alerts when multiple callbacks are fired
    - [x] move SSIDs in hs key value store
    - [x] make sure all wake events are handle (screen, system)
    - [ ] make sure everything is cleaned up if spoon is destroyed/unloaded
    - [x] move displays to hs key value store
    - [ ] move list of drives to eject to hs key value store
    - [ ] somehow intuit which display is focused
    Values stored in hs.settings:
    -- homeSSIDs
]]
-- fetched from hs key/value store
local homeSSIDs = hs.settings.get("homeSSIDs")

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

--- Context.moveDockLeft()
--- Function
--- movedockleft
---
--- Parameters:
--- * None
---
--- Returns:
---  * None
function obj.moveDockLeft()
    hs.applescript.applescript(
        [[
            tell application "System Events" to set the autohide of the dock preferences to true
            tell application "System Events" to set the screen edge of the dock preferences to left
        ]]
    )
end

--- Context.moveDockDown()
--- Method
--- movedockdown
---
--- Parameters:
--- * None
---
--- Returns:
---  * None
function obj.moveDockDown()
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

--- Context.homeArrived()
--- Method
--- home arrived
---
--- Parameters:
--- * None
---
--- Returns:
---  * None
function obj.homeArrived()
    -- Should really have device specific settings (desktop vs laptop)
    -- requires modified sudoers file.
    -- For Example!
    -- IN /etc/sudoers.d/power_mgmt (sudo visudo -f /etc/sudoers.d/power_mgmt)
    -- <yourusername> ALL=(root) NOPASSWD: /usr/bin/pmset *
    os.execute("sudo pmset -b displaysleep 2 sleep 10")
    os.execute("sudo pmset -c displaysleep 5 sleep 15")
    hs.audiodevice.defaultOutputDevice():setMuted(false)

    hs.alert(" ☛ ⌂ ", 3)
    obj.contextValues.location = "home"
    obj.location = "home"
end

--- Context.homeDeparted()
--- Method
--- home departed
---
--- Parameters:
--- * None
---
--- Returns:
---  * None
function obj.homeDeparted()
    hs.audiodevice.defaultOutputDevice():setMuted(true)
    hs.alert("~(☛ ⌂)", 1)
    os.execute("sudo pmset -a displaysleep 1 sleep 5")

    obj.contextValues.location = "away"
    obj.location = "away"
end

--- Context.ssidChangedCallback()
--- Method
--- ssidChangedCallback
---
--- Parameters:
--- * None
---
--- Returns:
---  * None
function obj.ssidChangedCallback()
    -- this only accounts for the SSID changing, and not
    -- disconnecting from a current network, but not reconnecting
    local newSSID = hs.wifi.currentNetwork()
    obj.logger.i(hs.wifi.currentNetwork())

    if (obj.currentSSID == newSSID) then
        obj.logger.i("no change")
    elseif (atHome(newSSID)) and (not has_value(homeSSIDs, obj.currentSSID)) then
        obj.logger.i("home")
        obj.homeArrived()
    elseif not atHome(newSSID) then
        obj.logger.i("away")
        obj.homeDeparted()
    else
        if newSSID ~= nil then
            obj.logger.e("[SC] Unhandled SSID: " .. newSSID)
        end

        obj.logger.e("[SC] No SSID found!")
    end

    obj.currentSSID = newSSID
    obj.contextValues.currentSSID = newSSID

    -- Try calling this, which is poorly named, but recreates the menu
    -- Need to separate state changes from ui updates...
    obj.screenWatcherCallback()
end

-- --------------------------------------------------------------------------
-- Callback functions (which are called based on certain changes)
-- ---------------------------------------------------------------------------

--- Context.cafChangedCallback()
--- Method
--- cafChangeCallback
---
--- Parameters:
--- * eventType - a number which represents the ID of the eventType
---
--- Returns:
---  * None
function obj.cafChangedCallback(eventType)
    -- I think both are handled?
    -- hs.caffeinate.watcher.screensDidWake
    -- hs.caffeinate.watcher.systemDidWake
    local didWake = hs.caffeinate.watcher.systemDidWake

    if (eventType == didWake and (not atHome(obj.currentSSID))) then
        obj.logger.i("[CW] Woke from sleep, not @home")
        obj.homeDeparted()
    elseif (eventType == didWake) and (atHome(obj.currentSSID)) then
        obj.logger.i("[CW] Woke from sleep, @home")
        obj.homeArrived()
    end
end

--- Context.screenWatcherCallback()
--- Method
--- screenWatcherCallback
---
--- Parameters:
--- * None
---
--- Returns:
---  * None
function obj.screenWatcherCallback()
    local newNumberOfScreens = #hs.screen.allScreens()
    obj.logger.i("[SW] Fired")
    -- hs.alert("[SW] Fired")
    -- obj.logger.d("\n\n~~~~~~~~~~" .. i(obj.display_ids) .. "\n\n")

    -- ugly as hell way to find out which display is in use
    -- uses sed to cut all text between "Intel" and "Displays"
    -- If Radeon (our discrete gpu) occurs between these strings,
    -- then we know that the displays are assigned to the Radeon and it is
    -- the current gpu in use. If there is no occurrence of Radeon between
    -- "Intel" and "Displays", it means we are using the integrated gpu

    -- Warning: not sure if this would work with egpus, not sure if it matters
    -- alternate sed:
    -- system_profiler SPDisplaysDataType | sed -e '/Intel/,/Displays/!d' | grep Radeon
    -- system_profiler SPDisplaysDataType | sed -e '/Intel/,/Radeon/!d' | grep Displays

    -- this shoudl work for any discrete gpu?
    -- if we find "Displays" after Chipset Mode: Intel but before a blank line
    -- then we know displays are attached to integrated gpu
    -- system_profiler SPDisplaysDataType | sed -e '/Chipset Model: Intel/,/^\\s*$/!d' | grep Displays
    --
    -- Use UUIDs for logic
    -- Cinema HD: 12C25E80-CE33-A29C-DA8C-E02B2E982D59
    -- Color LCD: 120F5D25-16F2-160F-2DC6-FE73F87D696C
    local res,
        success,
        exit = --luacheck: ignore
        hs.execute(
        "system_profiler SPDisplaysDataType | \
        sed -n '/Intel/,/Displays/p' | grep Radeon | tr -d '[:space:]'"
    )
    if res == "" then
        obj.currentGPU = "iGPU"
        obj.contextValues.currentGPU = "iGPU"
    else
        obj.currentGPU = "dGPU"
        obj.contextValues.currentGPU = "dGPU"
    end
    -- rcreate menu on change
    -- obj.createMenu()
    -- Move this to end of function?
    -- if obj.menubar ~= nil then
    --     obj.menubar:setMenu(obj.createMenu(obj.currentGPU))
    -- end
    -- maybe check how long the dedicated gpu has been in use?
    if obj.currentGPU == "discrete" then
        hs.notify.new(
            {
                title = "GPU Status",
                subtitle = "Warning",
                informativeText = "Dedicated GPU in use",
                alwaysPresent = true,
                autoWithdraw = false
            }
        ):send()
    end

    if #hs.screen.allScreens() == obj.lastNumberOfScreens and obj.docked and obj.location then
        obj.logger.i("[SW] no change")
    elseif hs.screen.find("12C25E80-CE33-A29C-DA8C-E02B2E982D59") then
        obj.logger.i("[SW] no change") -- how do i know this is no change?
        obj.docked = "docked"
        obj.contextValues.docked = "docked"
        obj.moveDockDown()
    elseif #hs.screen.allScreens() == 1 and hs.screen.find("Color LCD") and obj.docked == "@desk" then
        obj.logger.i("[SW] undocking")
        obj.docked = "mobile"
        obj.contextValues.docked = "mobile"
        obj.moveDockLeft()

        for i = 1, #obj.drives do
            obj.checkAndEject(obj.drives[i])
        end
    elseif #hs.screen.allScreens() == 2 and hs.screen.find(obj.display_ids["sidecar"]) then
        obj.logger.i("[SW] Sidecar Mode")
        obj.moveDockDown()
    elseif
        #hs.screen.allScreens() == 1 and
            (hs.screen.find("Color LCD") or hs.screen.mainScreen():getUUID() == "120F5D25-16F2-160F-2DC6-FE73F87D696C")
     then
        -- Screen loses name for some reason? No longer called Color LCD in catalina. just unnamed?
        -- Need to find by id but don't know if that's stable. Hmmm.
        -- Okay, UUID seems stable after restarting, connecting external display.
        obj.logger.i("[SW] Mobile")
        obj.docked = "mobile"
        obj.contextValues.docked = "mobile"
        obj.moveDockLeft()
    else
        obj.logger.e("[SW] Error!")
        obj.contextValues.docked = "error"
        obj.docked = "error"
    end

    obj.lastNumberOfScreens = newNumberOfScreens
end

-- ---------------------------------------------------------------------------
-- Watchers
-- ---------------------------------------------------------------------------

--- Context.initWifiWatcher()
--- Method
--- initWifiWatcher
---
--- Parameters:
--- * None
---
--- Returns:
---  * None
function obj.initWifiWatcher()
    -- if location hasn't been set,
    -- run the callback once to populate it
    if not obj.location then
        obj.ssidChangedCallback()
    end

    obj.wifiWatcher = hs.wifi.watcher.new(obj.ssidChangedCallback)
end

--- Context.initCafWatcher()
--- Method
--- initCafWatcher
---
--- Parameters:
--- * None
---
--- Returns:
---  * None
function obj.initCafWatcher()
    obj.cafWatcher = hs.caffeinate.watcher.new(obj.cafChangedCallback)
end

--- Context.initScreenWatcher()
--- Method
--- initScreenWatcher
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj.initScreenWatcher()
    -- if docked hasn't been set,
    -- run the callback once to populate it
    if not obj.docked then
        obj.screenWatcherCallback()
    end

    obj.screenWatcher = hs.screen.watcher.new(obj.screenWatcherCallback)
end

-- ---------------------------------------------------------------------------
-- Default spoon api methods
-- ---------------------------------------------------------------------------

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

function obj.createMenu(location, docked, gpu)
    local newMenu = {
        {
            title = hs.styledtext.new(
                "@" .. (location or obj.location or "error"),
                {font = "TT Interfaces", size = "10"}
            ),
            fn = function()
                hs.alert("Current Wifi: " .. obj.currentSSID)
            end
        },
        {
            title = hs.styledtext.new((docked or obj.docked or "error"), {font = "TT Interfaces", size = "10"}),
            fn = function()
                hs.alert("docked clicked")
            end
        },
        {
            title = hs.styledtext.new((gpu or obj.currentGPU or "error"), {font = "TT Interfaces", size = "10"}),
            fn = function()
                hs.alert("Launching activity monitor...")
                hs.application.launchOrFocus("Activity Monitor")
            end
        },
        {
            title = "-"
        },
        {
            title = hs.styledtext.new(
                "Refresh",
                {
                    font = {name = "TT Interfaces", size = 14},
                    -- baselineOffset = 10,
                    color = {hex = "#FF6F00"},
                    paragraphStyle = {
                        headIndent = 5,
                        tailIndex = 1,
                        lineSpacing = 5
                        -- maximumLineHeight = 10
                    }
                }
            ),
            fn = function()
                obj.menubar:setMenu(obj.createMenu(_, _, _))
            end
        }
    }

    -- spoon.Context.menubar:setMenu(spoon.Context.createMenu(_, _, _))
    return newMenu
    -- obj.menubar:setMenu(newMenu)
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

    -- obj.logger.d(i(options))

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
        -- obj.createMenu()
        obj.menubar = hs.menubar.new():setIcon(obj.menuIcon)
        obj.menubar:setMenu(obj.createMenu(_, _, obj.currentGPU))
    -- hs.alert(obj.docked, 5)
    -- local currentMenu = createMenu()
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

return obj
