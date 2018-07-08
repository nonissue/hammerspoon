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


tell application "System Events"
  tell dock preferences
    get properties
  end tell
end tell
-----------------------------------------------------------
--]]

-- [ ] Migrate stuff from CHANGE_RES @ line 44

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "SystemContexts"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.chooser = nil
obj.hotkeyShow = nil
obj.plugins = {}
obj.commands = {}

local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

obj.spoonPath = script_path()


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
local homeSSID = "ComfortInn VIP"
-- local homeSSID5G = "BROMEGA"
local schoolSSID = "MacEwanSecure"
local lastSSID = hs.wifi.currentNetwork()
local hostName = hs.host.localizedName()

local wifiicon = hs.image.imageFromPath('media/assets/airport.png')

function ssidChangedCallback()
  newSSID = hs.wifi.currentNetwork()

    if (newSSID == homeSSID or newSSID == homeSSID5G) and (lastSSID ~= homeSSID) then
        -- we are at home!
        home_arrived()
    elseif newSSID ~= homeSSID and lastSSID == homeSSID then
        -- we are away from home!
        -- why do we need the validation check for lastSSID?
        -- We can infer from newSSID ~= homeSSID that we aren't home?
        home_departed()
    end

    lastSSID = newSSID
end

function home_arrived()
  -- Should really have device specific settings (desktop vs laptop)
  -- requires modified sudoers file
  -- <YOUR USERNAME> ALL=(root) NOPASSWD: pmset -b displaysleep *
    os.execute("sudo pmset -b displaysleep 5 sleep 10")
    os.execute("sudo pmset -c displaysleep 5 sleep 10")
    hs.audiodevice.defaultOutputDevice():setMuted(false)
    hs.notify.new({
        title = 'Hammerspoon',
        subTitle = "ENV: Home Detected",
        informativeText = "Home Settings Enabled",
        setIdImage = wifiicon,
        -- hasReplyButton = true,
        -- autoWithdraw = true,
        -- hasActionButton = true,
        -- actionButtonTitle = "Test",
    }):send()
  -- new arrive home alert
    hs.alert(" ☛ ⌂ ", alerts_large_alt, 5)
    -- hs.alert.show("☛ ⌂", alerts_nobg, 2)
    -- TODO: set audiodevice to speakers
end

-- sets displaysleep to lowervalue
-- eventually should unmount disks and perform other functions?
function home_departed()
    -- set volume to 0
    hs.audiodevice.defaultOutputDevice():setMuted(true)
    os.execute("sudo pmset -a displaysleep 1 sleep 10")
    hs.alert.show("Away Settings Enabled", alerts_nobg, 0.7)
    -- new leave home alert
    hs.alert("~(☛ ⌂)", alerts_large_alt, 3)
    os.execute("sudo pmset -a displaysleep 1 sleep 10")
    hs.alert.show("Away Settings Enabled", alerts_nobg, 0.7)
    -- new leave home alert
    hs.alert("~(☛ ⌂)", alerts_large_alt, 3)

end

wifiWatcher = hs.wifi.watcher.new(ssidChangedCallback)  
wifiWatcher:start()

if 
    hs.wifi.currentNetwork() == "ComfortInn VIP" 
    or hs.wifi.currentNetwork() == "ComfortInn Guest" 
    or hostName == "apw@me.com" 
then
    home_arrived()
else
    home_departed()
end

-- generalize this for systemcontexts so we can check
-- several things when we wake from sleep?
-- not responsible for uaskin hs.shutdownCallback error
function muteOnWake(eventType)
    if (eventType == hs.caffeinate.watcher.systemDidWake) then
        local output = hs.audiodevice.defaultOutputDevice()
        output:setMuted(true)
    end
end

caffeinateWatcher = hs.caffeinate.watcher.new(muteOnWake)
caffeinateWatcher:start()
--- SystemContexts:start()
--- Method
--- Starts ___
---
--- Parameters:
---  * None
---
--- Returns:
---  * The ___ object
---
--- Notes:
---  * Some ___ plugins will continue performing background work even after this call (e.g. Spotlight searches)
function obj:start()
    print("-- Starting SystemContexts")
    if self.hotkeyShow then
        self.hotkeyShow:enable()
    end
    return self
end

--- SystemContexts:stop()
--- Method
--- Stops ___
---
--- Parameters:
---  * None
---
--- Returns:
---  * The ___ object
---
--- Notes:
---  * Some ___ plugins will continue performing background work even after this call (e.g. Spotlight searches)
function obj:stop()
    print("-- Stopping SystemContexts")
    if self.hotkeyShow then
        self.hotkeyShow:disable()
    end
    return self
end

--- SystemContexts:moveDockLeft()
--- Method
--- Stops ___
---
--- Parameters:
---  * None
---
--- Returns:
---  * The ___ object
---
--- Notes:
---  * Some ___ plugins will continue performing background work even after this call (e.g. Spotlight searches)
function obj:moveDockLeft() 
  hs.applescript.applescript(
    [[
      tell application "System Events" to set the autohide of the dock preferences to true
      tell application "System Events" to set the screen edge of the dock preferences to left
    ]])
end

--- SystemContexts:moveDockDown()
--- Method
--- Stops ___
---
--- Parameters:
---  * None
---
--- Returns:
---  * The ___ object
---
--- Notes:
---  * Some ___ plugins will continue performing background work even after this call (e.g. Spotlight searches)
function obj:moveDockDown() 
  hs.applescript.applescript(
    [[
      tell application "System Events" to set the autohide of the dock preferences to false
      tell application "System Events" to set the screen edge of the dock preferences to bottom
    ]])
end



------------------------------------------------------------------------------
------------------------------------------------------------------------------
return obj