--- === Context ===
---
--- Mute audio when leaving home wifi (or waking from sleep somewhere else),
--- unmute when arriving back home.
---
--- Home networks are read from `hs.settings.get("homeSSIDs")`.
---
--- Also publishes the "context" watchable so other spoons can react to
--- system state changes:
---   * context.location      -- "home" | "away"
---   * context.currentSSID   -- string | nil
---   * context.primaryScreen -- hs.screen object (Resolute watches this)

local obj = {}
obj.__index = obj

obj.name = "Context"
obj.version = "2.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.logger = hs.logger.new("Context")

obj.location = nil -- "home" | "away"
obj.currentSSID = nil

obj.wifiWatcher = nil
obj.cafWatcher = nil
obj.screenWatcher = nil
obj.wakeTimer = nil

obj.contextValues = hs.watchable.new("context", true)

local function atHome(ssid)
    for _, homeSSID in ipairs(hs.settings.get("homeSSIDs") or {}) do
        if homeSSID == ssid then
            return true
        end
    end

    return false
end

--- Context:setLocation(newLocation)
--- Method
--- Apply the side effects of a location change (mute away, unmute home).
--- No-op if the location hasn't changed.
---
--- Parameters:
---  * newLocation - "home" or "away"
---
--- Returns:
---  * None
function obj:setLocation(newLocation)
    if newLocation == self.location then
        return
    end

    self.location = newLocation
    self.contextValues.location = newLocation

    if newLocation == "home" then
        hs.audiodevice.defaultOutputDevice():setMuted(false)
        hs.alert(" ☛ ⌂ ", 2)
    else
        hs.audiodevice.defaultOutputDevice():setMuted(true)
        hs.alert("~(☛ ⌂)", 1)
    end

    self.logger.i("location: " .. newLocation)
end

--- Context:checkLocation()
--- Method
--- Read the current SSID and update location accordingly.
--- No wifi counts as away.
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:checkLocation()
    self.currentSSID = hs.wifi.currentNetwork()
    self.contextValues.currentSSID = self.currentSSID
    self:setLocation(atHome(self.currentSSID) and "home" or "away")
end

function obj.cafChangedCallback(eventType)
    if eventType ~= hs.caffeinate.watcher.systemDidWake then
        return
    end

    -- Check immediately so audio is muted right away if we woke somewhere
    -- new, then again after wifi has had time to reassociate (it usually
    -- hasn't reconnected yet when the wake event fires).
    obj:checkLocation()
    obj.wakeTimer = hs.timer.doAfter(5, function ()
        obj:checkLocation()
    end)
end

function obj.screenWatcherCallback()
    obj.contextValues.primaryScreen = hs.screen.primaryScreen()
end

--- Context:init()
--- Method
--- init
---
--- Parameters:
---  * None
---
--- Returns:
---  * The Context object
function obj:init()
    self.wifiWatcher = hs.wifi.watcher.new(function ()
        self:checkLocation()
    end)
    self.cafWatcher = hs.caffeinate.watcher.new(self.cafChangedCallback)
    self.screenWatcher = hs.screen.watcher.new(self.screenWatcherCallback)

    return self
end

--- Context:start()
--- Method
--- start
---
--- Parameters:
---  * None
---
--- Returns:
---  * The Context object
function obj:start()
    self.logger.i("-- Starting Context")

    -- populate initial state
    self:checkLocation()
    self.screenWatcherCallback()

    self.wifiWatcher:start()
    self.cafWatcher:start()
    self.screenWatcher:start()

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
---  * The Context object
function obj:stop()
    self.logger.i("-- Stopping Context")

    self.wifiWatcher:stop()
    self.cafWatcher:stop()
    self.screenWatcher:stop()

    if self.wakeTimer then
        self.wakeTimer:stop()
        self.wakeTimer = nil
    end

    self.currentSSID = nil
    self.location = nil

    return self
end

return obj
