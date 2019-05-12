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
obj.menuIcon = "@"
obj.menu = {}
obj.location = nil
obj.docked = nil

obj.currentSSID = nil
obj.currentScreens = nil
obj.lastNumberOfScreens = #hs.screen.allScreens()

-- move to key value store
local homeSSIDs = {"BROMEGA", "ComfortInn Plus", "1614 Apple II"}

local function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local function atHome(SSID)
    return has_value(homeSSIDs, SSID)
end

function obj.ssidChangedCallback()
    local newSSID = hs.wifi.currentNetwork()

    if (obj.currentSSID == newSSID) then
        obj.logger.i("no change")
    elseif (atHome(newSSID)) and (not has_value(homeSSIDs, obj.currentSSID)) then
        obj.logger.i("@home")
        obj.homeArrived()
    elseif not atHome(newSSID) then
        obj.logger.i("@away")
        obj.homeDeparted()
    else
        if newSSID ~= nil then
            obj.logger.e("[SC] Unhandled SSID: " .. newSSID)
        end

        obj.logger.e("[SC] No SSID found!")
    end

    obj.currentSSID = newSSID
end

function obj.homeArrived()
    -- Should really have device specific settings (desktop vs laptop)
    -- requires modified sudoers file.
    -- For Example!
    -- IN /etc/sudoers.d/power_mgmt (sudo visudo -f /etc/sudoers.d/power_mgmt)
    -- andrewwilliams ALL=(root) NOPASSWD: /usr/bin/pmset *
    os.execute("sudo pmset -b displaysleep 2 sleep 10")
    os.execute("sudo pmset -c displaysleep 5 sleep 15")
    hs.audiodevice.defaultOutputDevice():setMuted(false)

    hs.alert(" ☛ ⌂ ", 3)
    obj.location = "@home"
end

-- sets displaysleep to lowervalue
-- eventually should unmount disks and perform other functions?
function obj.homeDeparted()
    hs.audiodevice.defaultOutputDevice():setMuted(true)
    hs.alert("~(☛ ⌂)", 1)
    os.execute("sudo pmset -a displaysleep 1 sleep 5")

    obj.location = "@away"
end

-- this catches situations where we get somewhere, computer wakes from sleep,
-- but doesn't connect to a network automatically. I still want things set
function obj.cafChangedCallback(eventType)
    -- handle both?:
        -- hs.caffeinate.watcher.screensDidWake
        -- hs.caffeinate.watcher.systemDidWake
    local didWake = hs.caffeinate.watcher.systemDidWake

    if (eventType == didWake and (not atHome(obj.currentSSID))) then
        obj.logger.i("[CW] Woke from sleep, not @home")
        obj.homeDeparted()
    elseif (eventType == didWake) and (atHome(obj.currentSSID)) then
        obj.logger.i("[CW] Woke from sleep, @home")
        obj.homeArrived()
    elseif (eventType ~= didWake) then
        obj.logger.i("[CW] nonWakeEvent: " .. eventType)
    end
end

function obj.moveDockLeft()
    hs.applescript.applescript(
        [[
            tell application "System Events" to set the autohide of the dock preferences to true
            tell application "System Events" to set the screen edge of the dock preferences to left
        ]]
    )
end

function obj.moveDockDown()
    hs.applescript.applescript(
        [[
            tell application "System Events" to set the autohide of the dock preferences to false
            tell application "System Events" to set the screen edge of the dock preferences to bottom
      ]]
    )
end

function obj.checkAndEject(target)
    target = "/Volumes/" .. target
    if hs.fs.volume.eject(target) then
        hs.alert.show("SUCCESS: Ejected " .. target, 3)
    else
        hs.alert.show("ERROR: Unable to eject " .. target, 3)
    end
end

function obj.screenWatcherCallback()
    local newNumberOfScreens = #hs.screen.allScreens()

    -- if #hs.screen.allScreens() == obj.lastNumberOfScreens and obj.currentScreens then
    if #hs.screen.allScreens() == obj.lastNumberOfScreens and obj.docked and obj.location then
        obj.logger.i("[SW] no change")
        -- handle unnecessary/redundant screenWatcher callbacks
    elseif hs.screen.find("Cinema HD") then
        -- wat. somehow this changed? 18-11-02: it is now 69489832, was 69489838
        -- Changed above line to use "Cinema HD" as display ID was not reliable?
        -- if we have a different amount of displays and one of them is
        -- our cinema display, we are @desk
        obj.logger.i("[SW] no change")

        -- hs.alert("[SW] desk", 1)
        obj.docked = "docked"
        obj.moveDockDown()
    elseif #hs.screen.allScreens() == 1 and hs.screen.find("Color LCD") and obj.docked == "@desk" then
        obj.logger.i("[SW] undocking")
        -- hs.alert("[SW] undocking", 3)

        obj.docked = "mobile"
        obj.moveDockLeft()

        -- Move these to a hs key value store?
        obj.checkAndEject("ExternalSSD")
        obj.checkAndEject("Win-Stuff")
    elseif #hs.screen.allScreens() == 1 and hs.screen.find("Color LCD") then
        obj.logger.i("[SW] mobile")
        -- hs.alert("[SW] mobile", 3)

        obj.docked = "mobile"

        obj:moveDockLeft()
    else
        obj.logger.e("[SW] Error!")
        hs.alert("ERROR: Unhandled screenWatcher case", 1)

        obj.docked = "error"
    end

    obj.lastNumberOfScreens = newNumberOfScreens
end

function obj.initWifiWatcher()
    -- if location hasn't been set,
    -- run the callback once to populate it
    if not obj.location then
        obj.ssidChangedCallback()
    end

    obj.wifiWatcher = hs.wifi.watcher.new(obj.ssidChangedCallback)
end

function obj.initCafWatcher()
    obj.cafWatcher = hs.caffeinate.watcher.new(obj.cafChangedCallback)
end

function obj.initScreenWatcher()
    -- if docked hasn't been set,
    -- run the callback once to populate it
    if not obj.docked then
        obj.screenWatcherCallback()
    end

    obj.screenWatcher = hs.screen.watcher.new(obj.screenWatcherCallback)
end

function obj:init()
    if self.menubar then
        self.menubar:delete()
    end

    obj.menubar = hs.menubar.new():setTitle(obj.menuIcon)
    --[[
        submenu
            - current location (@home, ~@home)
            - docked? (@desk, @mobile)
            -
    ]]

    obj.initWifiWatcher()
    obj.initCafWatcher()
    obj.initScreenWatcher()

    obj.menu = {
        {
            title = hs.styledtext.new(obj.location),
            fn = function()
                hs.alert("location clicked")
            end
        },
        {
            title = hs.styledtext.new(obj.docked),
            fn = function()
                hs.alert("docked clicked")
            end
        }
    }

    obj.menubar:setMenu(obj.menu)

    return self
end

-- start watchers
function obj:start()
    obj.logger.i("-- Starting Contexts")
    if self.hotkeyShow then
        self.hotkeyShow:enable()
    end

    -- obj:init()

    obj.wifiWatcher:start()
    obj.cafWatcher:start()
    obj.screenWatcher:start()
    return self
end

-- stop watchers
function obj:stop()
    obj.logger.df("-- Stopping Contexts")
    if self.hotkeyShow then
        self.hotkeyShow:disable()
    end

    obj.menubar:delete()

    obj.wifiWatcher:stop()
    obj.cafWatcher:stop()
    obj.screenWatcher:stop()
    obj.currentSSID = nil

    return self
end

return obj
