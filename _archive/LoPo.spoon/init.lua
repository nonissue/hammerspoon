--- === LoPo ===
---
--- If low power mode is enabled, show it in menuabar.
---

local obj = {}
obj.__index = obj


obj.name = "LoPo"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue/hammerspoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.logger = hs.logger.new("LoPo")
obj.logger.i('Initializing LoPo.spoon logger...')

function obj.batteryWatcherHandler()
    -- pmset -g | grep 'lowpowermode'
    obj.logger.i("LoPo: battery status changed.")
    hs.alert("Battery Watcher!")

end

function obj:init()
    obj.logger.i("LoPo.spoon Initializing")
    obj.batteryWatcher = hs.battery.watcher.new(obj.batteryWatcherHandler)

end

function obj:start()
    self.logger.i("LoPo.spoon Starting")

    obj.batteryWatcher:start()
    -- obj.menubar = hs.menubar.new()
    -- obj.menubar:setTitle("CMDTAB: IDLE")
end

function obj:stop()
    self.logger.i("LoPo.spoon Stopping")

    self.batteryWatcher:stop()
end

return obj
