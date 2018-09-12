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

-----------------------------------------------------------

todo:
* make this whole thing a proper state machine!

* invoke do not disturb on when not at home
* store state in an object?
    * eg: 
        * state.location
            * vals: home, school, other
        * state.docked

    Outline of:
    - Properties to init
    - How it's computed
    - Effect of properties

    - Docked: Bool
        - Computed from:
            - number of screens
            - names of displays
            - name of SSID
        - Effect:
            - dock position
            - provide correct 'changeres' options
            - set window layout?
    * Location

]]
local obj = {}
obj.__index = obj

-- Metadata
obj.name = "SystemContexts"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.hotkeyShow = nil

obj.wifiWatcher = nil
obj.cafWatcher = nil
obj.currentSSID = nil
local homeSSID = "ComfortInn VIP"
local schoolSSID = "MacEwanSecure"
local hostName = hs.host.localizedName() -- maybe not needed?

-- not needed but included
local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

obj.spoonPath = script_path()

--
-- settings to apply based on context:
--    screen lock time
--    volume
--    dock position
--    default app layouts



------------------------------------------------------------------------------
-- Location based functions to change system settings
------------------------------------------------------------------------------
-- functions for different locations
-- configure things like drive mounts, display sleep (for security), etc.
-- sets displaysleep to 90 minutes if at home
-- should be called based on ssid
-- not the most secure since someone could fake ssid I guess
-- might want some other level of verification-- makes new window from current tab in safari
-- could maybe send it to next monitor immediately if there is one?
-- differentiate between settings for laptop vs desktop
-- Mostly lifted from:
-- https://github.com/cmsj/hammerspoon-config/blob/master/init.lua
------------------------------------------------------------------------------
-- Don't love the logic of how this is implemented
-- If computer is in between networks (say, woken from sleep in new location)
-- Then desired settings like volume mute are not applied until after a delay
-- Maybe implement a default setting that is applied when computer is 'in limbo'
-- Move to env variable / .env?

function obj.ssidChangedCallback()
    print("\nWifi CB fired\n")
    local newSSID = hs.wifi.currentNetwork()

    if (newSSID == homeSSID) and (obj.currentSSID ~= homeSSID) then
        -- we are at home!
        obj.homeArrived()
    elseif newSSID ~= homeSSID then
        obj.homeDeparted()
    end

    obj.currentSSID = newSSID
end

function obj.homeArrived()
  -- Should really have device specific settings (desktop vs laptop)
  -- requires modified sudoers file
  -- <YOUR USERNAME> ALL=(root) NOPASSWD: pmset -b displaysleep *
    os.execute("sudo pmset -b displaysleep 5 sleep 10")
    os.execute("sudo pmset -c displaysleep 5 sleep 10")
    hs.audiodevice.defaultOutputDevice():setMuted(false)
  -- new arrive home alert
    hs.alert(" ☛ ⌂ ", 3)
end

-- sets displaysleep to lowervalue
-- eventually should unmount disks and perform other functions?
function obj.homeDeparted()
    -- set volume to 0
    hs.audiodevice.defaultOutputDevice():setMuted(true)
    -- new leave home alert
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
    if (eventType == hs.caffeinate.watcher.systemDidWake and hs.wifi.currentNetwork() ~= homeSSID) then
        obj.homeDeparted()
    end
end

function obj:initCafWatcher()
    obj.cafWatcher = hs.caffeinate.watcher.new(obj.muteOnWake)
end

function obj:moveDockLeft() 
    hs.applescript.applescript(
      [[
        tell application "System Events" to set the autohide of the dock preferences to true
        tell application "System Events" to set the screen edge of the dock preferences to left
      ]])
  end
  
  function obj:moveDockDown() 
    hs.applescript.applescript(
      [[
        tell application "System Events" to set the autohide of the dock preferences to false
        tell application "System Events" to set the screen edge of the dock preferences to bottom
      ]])
  end
----------------------------------------------------------
-- screenWatcher
----------------------------------------------------------
-- Cinema Display Name: "Cinema HD"
-- Cinema Display ID: 69489838

-- Issues: 
-- affinity designer triggers screen change?
-- gets called multiple times as sometimes add multiple displays
  -- if called multiple times, our conditional logic is broken?
-- figure out how to batch the updates?

--[[ display contexts:
    @desk:
        * cinema display detected
        * wifi: home
        * display count: 1-3
        * actions:
            * entry: 
                moveDockDown()
                audioOn()
                applyLayouts?
            * exit: 

    @duet:
        * display count: 2
        * wifi: any
        * ipad display detected?
        * actions:spo
    @else:
        * display count: 1
        * wifi: any
]]

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
        hs.alert("screenwatcher: fired, state: " .. obj.currentScreens, 3)
    elseif hs.screen.find(69489838) then
        -- if we have a different amount of displays and one of them is 
        -- our cinema display, we are @desk
        hs.alert("@desk")
        obj.currentScreens = "@desk"
        obj:moveDockDown()
    elseif #hs.screen.allScreens() == 1 and hs.screen.find("Color LCD") and obj.currentScreens == "@desk" then
        hs.alert("@undocking", 3)
        obj.currentScreens = "@mobile"
        obj:moveDockLeft()
        obj.checkAndEject("ExternalSSD")
    elseif #hs.screen.allScreens() == 1 and hs.screen.find("Color LCD") then
        hs.alert("@mobile", 3)
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
  print("-- Starting SystemContexts")
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
  print("-- Stopping SystemContexts")
  if self.hotkeyShow then
      self.hotkeyShow:disable()
  end

  obj.wifiWatcher:stop()
  obj.cafWatcher:stop()
  obj.currentSSID = nil
  return self
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
return obj