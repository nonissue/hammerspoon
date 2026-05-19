--- === InputOverride ===
---
--- Keep the system input device pinned to a preferred device when it is available.
---
---
---     26-05-18: Disabled for now
---
---      • Menu bar item would disappear randomly
---      • Interacting with input in other apps (like changing the input in facetime)
---        caused instability and apps to crash. Something wonky going on.
---
---

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "InputOverride"
obj.version = "0.1"
obj.author = "Andy Williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue/hammerspoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- InputOverride.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('InputOverride')

local settingsKey = "InputOverride.preferredInputDevice"
local menuRefreshDelay = 0.2

local function audioEventAffectsInput(eventName)
    if type(eventName) ~= "string" then
        return false
    end

    return eventName:find("dIn", 1, true) ~= nil or eventName:find("dev#", 1, true) ~= nil
end

local function stopMenuRefreshTimer(self)
    if self.menuRefreshTimer then
        self.menuRefreshTimer:stop()
        self.menuRefreshTimer = nil
    end
end

local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

obj.menubarIcon = hs.image.imageFromPath(script_path() .. "/microphone.circle.fill.svg")
obj.menuRefreshTimer = nil

--- InputOverride:getPreferredInputDevice()
--- Method
--- Get the stored preferred input device.
---
--- Parameters:
---  * None
---
--- Returns:
---  * A table containing the preferred device name and uid, or nil if no preferred device is set.
function obj:getPreferredInputDevice()
    return hs.settings.get(settingsKey)
end

--- InputOverride:setPreferredInputDevice(device)
--- Method
--- Store the given device as the preferred input device and switch to it immediately.
---
--- Parameters:
---  * device - an `hs.audiodevice` input device object.
---
--- Returns:
---  * The InputOverride object
function obj:setPreferredInputDevice(device)
    hs.settings.set(settingsKey, {
        name = device:name(),
        uid = device:uid()
    })

    device:setDefaultInputDevice()
    self:updateMenubarMenu()

    return self
end

--- InputOverride:clearPreferredInputDevice()
--- Method
--- Clear the stored preferred input device.
---
--- Parameters:
---  * None
---
--- Returns:
---  * The InputOverride object
function obj:clearPreferredInputDevice()
    hs.settings.clear(settingsKey)
    self:updateMenubarMenu()

    return self
end

--- InputOverride:findInputDeviceByUid(uid)
--- Method
--- Find an available input device by its UID.
---
--- Parameters:
---  * uid - the input device UID to look for.
---
--- Returns:
---  * An `hs.audiodevice` input device object, or nil if no matching device is available.
function obj:findInputDeviceByUid(uid)
    if not uid then
        return nil
    end

    local inputDevices = hs.audiodevice.allInputDevices()

    for i = 1, #inputDevices do
        if inputDevices[i]:uid() == uid then
            return inputDevices[i]
        end
    end

    return nil
end

--- InputOverride:enforcePreferredInputDevice()
--- Method
--- Switch the system input device back to the preferred device when it is available.
---
--- Parameters:
---  * None
---
--- Returns:
---  * The InputOverride object
---
--- Notes:
---  * If the preferred device is unavailable, this method leaves the current system input unchanged.
function obj:enforcePreferredInputDevice()
    local preferredInputDevice = self:getPreferredInputDevice()
    local preferredUid = preferredInputDevice and preferredInputDevice.uid
    local preferredDevice = self:findInputDeviceByUid(preferredUid)
    local defaultInputDevice = hs.audiodevice.defaultInputDevice()

    if preferredDevice and (not defaultInputDevice or defaultInputDevice:uid() ~= preferredUid) then
        preferredDevice:setDefaultInputDevice()
    end

    return self
end

--- InputOverride:generateMenubarMenuItems()
--- Method
--- Generate the menu items used by the menubar item.
---
--- Parameters:
---  * None
---
--- Returns:
---  * A table of menubar menu items.
---
--- Notes:
---  * The checked menu item represents the current system input device.
---  * Selecting a device stores it as the preferred input device.
function obj:generateMenubarMenuItems()
    local menuItems = {}
    local inputDevices = hs.audiodevice.allInputDevices()
    local defaultInputDevice = hs.audiodevice.defaultInputDevice()
    local defaultInputUid = defaultInputDevice and defaultInputDevice:uid()
    local preferredInputDevice = self:getPreferredInputDevice()
    local preferredInputUid = preferredInputDevice and preferredInputDevice.uid
    local preferredInputName = preferredInputDevice and preferredInputDevice.name or "None"

    table.insert(menuItems, {
        title = "Preferred input: " .. preferredInputName,
        disabled = true
    })

    table.insert(menuItems, {
        title = "Clear preferred input",
        disabled = preferredInputDevice == nil,
        fn = function ()
            self:clearPreferredInputDevice()
        end
    })

    table.insert(menuItems, { title = "-" })

    for i = 1, #inputDevices do
        local device = inputDevices[i]
        local deviceUid = device:uid()
        local title = device:name()

        if deviceUid == preferredInputUid then
            title = title .. " (preferred)"
        end

        table.insert(menuItems,
            {
                title = title,
                fn = function ()
                    local selectedDevice = self:findInputDeviceByUid(deviceUid)

                    if selectedDevice then
                        self:setPreferredInputDevice(selectedDevice)
                    else
                        self:updateMenubarMenu()
                    end
                end,
                checked = deviceUid == defaultInputUid
            })
    end

    return menuItems
end

--- InputOverride:updateMenubarMenu()
--- Method
--- Replace the menubar menu with freshly generated menu items.
---
--- Parameters:
---  * None
---
--- Returns:
---  * The InputOverride object
function obj:updateMenubarMenu()
    if self.menubarMenu then
        self.menubarMenu:setMenu(self:generateMenubarMenuItems())
    end

    return self
end

--- InputOverride:scheduleMenubarMenuUpdate()
--- Method
--- Schedule a short debounced update of the preferred input and menubar menu.
---
--- Parameters:
---  * None
---
--- Returns:
---  * The InputOverride object
---
--- Notes:
---  * The delay gives macOS time to finish updating the default input after an audio device event.
function obj:scheduleMenubarMenuUpdate()
    stopMenuRefreshTimer(self)

    self.menuRefreshTimer = hs.timer.doAfter(menuRefreshDelay, function ()
        self:enforcePreferredInputDevice()
        self:updateMenubarMenu()
        self.menuRefreshTimer = nil
    end)

    return self
end

--- InputOverride:start()
--- Method
--- Create the input override menubar item, apply the preferred input device if available, and start the audio device watcher.
---
--- Parameters:
---  * None
---
--- Returns:
---  * The InputOverride object
function obj:start()
    self.logger.i("Starting InputOverride")

    if self.menubarMenu then
        self.menubarMenu:delete()
    end

    stopMenuRefreshTimer(self)

    self:enforcePreferredInputDevice()

    self.menubarMenu = hs.menubar.new():setMenu(self:generateMenubarMenuItems())
    self.menubarMenu:setIcon(self.menubarIcon)

    hs.audiodevice.watcher.setCallback(function (eventName)
        self.logger.df("%s", tostring(eventName))

        if audioEventAffectsInput(eventName) then
            self:scheduleMenubarMenuUpdate()
        end
    end)

    hs.audiodevice.watcher:start()

    return self
end

--- InputOverride:stop()
--- Method
--- Stop the audio device watcher, pending menu refreshes, and remove the menubar item.
---
--- Parameters:
---  * None
---
--- Returns:
---  * The InputOverride object
function obj:stop()
    hs.audiodevice.watcher:stop()
    stopMenuRefreshTimer(self)

    if self.menubarMenu then
        self.menubarMenu:delete()
        self.menubarMenu = nil
    end

    return self
end

return obj
