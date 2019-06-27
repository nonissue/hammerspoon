--[[

Module to eject EGPU and drives on sleep so computer is ready to be unplugged at any time
Requires modifying sudoers file
WARNING: Do so at own risk, this potentially could cause hardware damage / security problems 

Run:
sudo visudo -f /etc/sudoers.d/toggle_tb

Paste the following, with your username (you can use whoami to verify your username):
<YOURUSERNAME> ALL=(root) NOPASSWD: /sbin/kextunload /System/Library/Extensions/AppleThunderboltPCIAdapters.kext/Contents/PlugIns/AppleThunderboltPCIUpAdapter.kext/
<YOURUSERNAME> ALL=(root) NOPASSWD: /sbin/kextload /System/Library/Extensions/AppleThunderboltPCIAdapters.kext/Contents/PlugIns/AppleThunderboltPCIUpAdapter.kext/

]]

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "eGPU"
obj.version = "0.1"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"
-- end Metadata

-- init logger
obj.logger = hs.logger.new('eGPU', 'verbose')
obj.logger.i('Initializing toggleEGPU...')

-- syles for alerts
-- way over the top but i had some fun with it
local warningStyle = {textFont = "Helvetica Neue Condensed Bold", strokeWidth = 10, strokeColor = {hex = "#FF3D00", alpha = 0.9}, radius = 1, textColor = {hex = "#FFCCBC", alpha = 1}, fillColor = {hex = "#DD2C00", alpha = 0.95}}
local successStyle = {textFont = "Helvetica Neue Condensed Bold", strokeWidth = 10, strokeColor = {hex = "#1B5E20", alpha = 0.9}, radius = 1, textColor = {hex = "#fff", alpha = 1}, fillColor = {hex = "#2E7D32", alpha = 0.9}}
local loadingStyle = {textFont = "Helvetica Neue Condensed Bold", strokeWidth = 10, strokeColor = {hex = "#263238", alpha = 0.9}, radius = 1, textColor = {hex = "#B0BEC5", alpha = 1}, fillColor = {hex = "#37474F", alpha = 0.9}}

obj.chipIcon = [[ASCII:
....................
....................
....................
.....G..E..C..A.....
....................
....................
...1.G..E..C..A.1...
...7............5...
....................
....................
....................
....................
...7............5...
...3.g..e..c..a.3...
....................
....................
.....g..e..c..a.....
....................
....................
....................
]]

function obj.kextLoaded()
    -- stupidly verbose but to guard against nil
    if os.execute("kextstat |grep AppleThunderboltPCIUpAdapter") then 
        return true 
    else 
        return false
    end
end

function obj.ejectEGPU()
    -- returns true + result on success
    -- otherwise returns false and the error
    return hs.osascript._osascript(
    [[
        do shell script "/usr/bin/SafeEjectGPU Eject"
    ]],
    "AppleScript"
    )
end

function obj.ejectAllVolumes()
    -- returns true + result on success
    -- otherwise returns false and the error
    return hs.osascript._osascript([[
        tell application "Finder"
	        eject (every disk whose ejectable is true)
        end tell
        ]],
        "AppleScript"
    )
end

function obj.undock()
    -- returns true if both scripts are executed
    -- but this doesn't necessarily reflect their affects
    return obj.ejectEGPU() and obj.ejectAllVolumes()
end

function obj.unloadTB()
    return os.execute("sudo /sbin/kextunload /System/Library/Extensions/AppleThunderboltPCIAdapters.kext/Contents/PlugIns/AppleThunderboltPCIUpAdapter.kext/")
end

function obj.loadTB()
    return os.execute("sudo /sbin/kextload /System/Library/Extensions/AppleThunderboltPCIAdapters.kext/Contents/PlugIns/AppleThunderboltPCIUpAdapter.kext/")
end

function obj.resetTB()
    -- returns the result of loadTB() which is all we really care about
    obj.unloadTB()
    return obj.loadTB()
end

function obj.loadCheck()
    hs.alert(obj.kextLoaded(), loadingStyle, 5)
end

function obj.spoonLoaded()
    local kextStatus = obj.kextLoaded()
    if not kextStatus then
        obj.logger.e("kextStatus: " .. tostring(kextStatus))
        obj.logger.w("TB Kext should be loaded but isnt!")
        hs.alert.closeAll(0.1)
        local warning = hs.alert.show("CRITICAL: KEXT ERROR", warningStyle, 3)
        -- attempt to load kext
        obj.logger.d("Attempting to reload kext...!")
        obj.logger.d(obj.resetTB())

        -- this is so hacky, the issue is either resolved immediatley or not
        -- but i wanted to play with a user inteface a bit
        -- problem is that most of this is synchronous and i want to avoid blocking
        -- the thread
        -- there are probably a million better ways to do this
        local loader = 10
        hs.timer.doAfter(2,
            function()
                hs.timer.doUntil(function() return loader == 0 end,
                    function()
                        loader = loader - 1
                        hs.alert("RECOVERING...", loadingStyle, 0.5)
                    end,
                1)
        end)
        if not obj.kextLoaded() then
            obj.logger.e("Still can't load kext, something is broke")
            hs.alert("TB KEXT NOT LOADED, CANNOT RECOVER!", warningStyle, 10)
        else
            -- another fake delay for ui reasons
            hs.timer.doAfter(8, 
                function()
                    loader = 0 -- immediately kills fake recovery flasher
                    hs.alert.closeAll(0.5)
                    obj.logger.i("Issue resolved")
                    hs.alert("SUCCESS!", successStyle, 3)
                end
            )
        end
    end
end

obj.egpuMenuOptions = { 
    { title = "⏏  eGPU & Vols", fn = function() obj.logger.d(obj.undock()) end},
    { title = "⏏  eGPU", fn = function() obj.logger.d(obj.ejectEGPU()) end}, 
    { title = "⏏  Vols", fn = function() obj.logger.d(obj.ejectAllVolumes()) end},
    { title = "♻︎  Reset TB", fn = function() local res = obj.resetTB() hs.alert(res and "TB: Reset" or "TB: Error", res and successStyle or warningStyle, 3) obj.logger.d(res) end},
}

local function sleepWatch(eventType)
    if (eventType == hs.caffeinate.watcher.systemWillSleep) then
        obj.logger.i("Sleeping...")
        if obj.undock() then
            obj.logger.i("sleepScript success!")
        else
            obj.logger.e("sleepScript error")
        end
    elseif (eventType == hs.caffeinate.watcher.screensDidWake) then
        obj.logger.i("Waking...")
        obj.logger.d(obj.resetTB())
    end
end

function obj:enableMenu()
    obj.egpuMenu = hs.menubar.new()
    obj.egpuMenu:setIcon(obj.chipIcon):setMenu(obj.egpuMenuOptions)
end

function obj:disableMenu()
    obj.egpuMenu:delete()
end

function obj:init()
    obj.spoonLoaded()
    obj.sleepWatcher = hs.caffeinate.watcher.new(sleepWatch)
end

function obj:start()
    obj.sleepWatcher:start()
    obj:enableMenu()
    return obj
end

function obj:stop()
    obj.sleepWatcher:stop()
    obj.egpuMenu:disableMenu()
    return obj
end

return obj