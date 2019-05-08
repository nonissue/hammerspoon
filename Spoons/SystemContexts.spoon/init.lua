local obj = {}
obj.__index = obj

obj.name = "SystemContexts"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.logger = hs.logger.new("SystemContexts")
obj.hotkeyShow = nil
obj.wifiWatcher = nil
obj.cafWatcher = nil
obj.currentSSID = nil
-- move to key value store
local homeSSIDs = {"BROMEGA", "ComfortInn Plus", "1614 Apple II"}

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function obj.ssidChangedCallback()
    local newSSID = hs.wifi.currentNetwork()

    if (has_value(homeSSIDs, newSSID)) and
        (not has_value(homeSSIDs, obj.currentSSID)) then
        -- we are at home!
        obj.logger.i("@home")
        obj.homeArrived()
    elseif not has_value(homeSSIDs, newSSID) then
        obj.logger.i("@away")
        obj.homeDeparted()
    else
        if newSSID ~= nil then
            obj.logger.e("SC: Unhandled SSID!" .. newSSID)
        end
        obj.logger.e("SC: Unhandled SSID case!")
        hs.alert("SystemContexts Error")
    end

    obj.currentSSID = newSSID
end

function obj.homeArrived()
  -- Should really have device specific settings (desktop vs laptop)
  -- requires modified sudoers file.
  -- For Example!
  -- IN /etc/sudoers.d/power_mgmt (sudo visudo -f /etc/sudoers.d/power_mgmt)
  -- andrewwilliams ALL=(root) NOPASSWD: /usr/bin/pmset *
    os.execute("sudo pmset -b displaysleep 5 sleep 10")
    os.execute("sudo pmset -c displaysleep 5 sleep 10")
    hs.audiodevice.defaultOutputDevice():setMuted(false)
    hs.notify.show("@home", "", "")
    hs.alert(" ☛ ⌂ ", 3)
end

-- sets displaysleep to lowervalue
-- eventually should unmount disks and perform other functions?
function obj.homeDeparted()
    hs.audiodevice.defaultOutputDevice():setMuted(true)
    hs.alert("~(☛ ⌂)", 3)
    os.execute("sudo pmset -a displaysleep 1 sleep 5")
end

function obj.initWifiWatcher()
    if not obj.currentNetwork then
        obj.ssidChangedCallback()
    end

    obj.wifiWatcher = hs.wifi.watcher.new(obj.ssidChangedCallback)
end

-- this catches situations where we get somewhere, computer wakes from sleep,
-- but doesn't connect to a network automatically. I still want things set
function obj.muteOnWake(eventType)
    if (eventType == hs.caffeinate.watcher.systemDidWake and (not has_value(homeSSIDs, hs.wifi.currentNetwork()))) then
        obj.homeDeparted()
    end
end

function obj.initCafWatcher()
    obj.cafWatcher = hs.caffeinate.watcher.new(obj.muteOnWake)
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
      ]])
end

obj.lastNumberOfScreens = #hs.screen.allScreens()
obj.currentScreens = hs.screen.allScreens()
obj.currentScreens = nil

function obj.checkAndEject(target)
    target = "/Volumes/" .. target
    if hs.fs.volume.eject(target) then
        hs.alert.show("SUCCESS: Ejected " .. target, 3)
    else
        hs.alert.show("ERROR: Unable to eject " .. target, 3)
    end
end

function obj.screenWatcher()
    local newNumberOfScreens = #hs.screen.allScreens()

    if #hs.screen.allScreens() == obj.lastNumberOfScreens and obj.currentScreens then
        -- handle unnecessary/redundant screenWatcher callbacks
        hs.alert("SW:" .. obj.currentScreens, 3)
    elseif hs.screen.find("Cinema HD") then -- wat. somehow this changed? 18-11-02: it is now 69489832, was 69489838
        -- Changed above line to use "Cinema HD" as display ID was not reliable?
        -- if we have a different amount of displays and one of them is
        -- our cinema display, we are @desk
        hs.alert("@desk")
        obj.currentScreens = "@desk"
        obj.moveDockDown()
    elseif #hs.screen.allScreens() == 1 and hs.screen.find("Color LCD") and obj.currentScreens == "@desk" then
        hs.alert("@undocking", 3)
        obj.currentScreens = "@mobile"
        obj.moveDockLeft()
        obj.checkAndEject("ExternalSSD")
        obj.checkAndEject("Win-Stuff")
    elseif #hs.screen.allScreens() == 1 and hs.screen.find("Color LCD") then
        -- hs.notify.show("@mobile", "", "")
        obj.currentScreens = "@mobile"
        obj:moveDockLeft()
    else
        hs.alert("ERROR: Unhandled screenWatcher case")
        obj.currentState = "@error"
    end

    obj.lastNumberOfScreens = newNumberOfScreens
end

obj.screenWatcher()
hs.screen.watcher.new(obj.screenWatcher):start()

function obj:init()
    obj.initWifiWatcher()
    obj.initCafWatcher()
    obj.wifiWatcher:start()
    obj.cafWatcher:start()

    return self
end

-- start watchers
function obj:start()
    obj.logger.i("-- Starting Contexts")
  if self.hotkeyShow then
      self.hotkeyShow:enable()
  end

  obj.initWifiWatcher()
  obj.wifiWatcher:start()
  obj.cafWatcher:start()
  return self
end

-- stop watchers
function obj:stop()
    obj.logger.df("-- Stopping Contexts")
  if self.hotkeyShow then
      self.hotkeyShow:disable()
  end

  obj.wifiWatcher:stop()
  obj.cafWatcher:stop()
  obj.currentSSID = nil
  return self
end

return obj