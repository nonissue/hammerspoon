--[[
Module to eject EGPU and drives on sleep so computer is ready to be unplugged at any time
Requires modifying sudoers file

Run:
sudo visudo -f /etc/sudoers.d/toggle_tb

Paste the following, with your username (you can use whoami to verify your username):
<YOURUSERNAME> ALL=(root) NOPASSWD: /sbin/kextunload /System/Library/Extensions/AppleThunderboltPCIAdapters.kext/Contents/PlugIns/AppleThunderboltPCIUpAdapter.kext/
<YOURUSERNAME> ALL=(root) NOPASSWD: /sbin/kextload /System/Library/Extensions/AppleThunderboltPCIAdapters.kext/Contents/PlugIns/AppleThunderboltPCIUpAdapter.kext/
]]

-- syles for alerts
-- way over the top but i had some fun with it
local warningStyle = {textFont = "Helvetica Neue Condensed Bold", strokeWidth = 10, strokeColor = {hex = "#FF3D00", alpha = 0.9}, radius = 1, textColor = {hex = "#FFCCBC", alpha = 1}, fillColor = {hex = "#DD2C00", alpha = 0.95}}
local successStyle = {textFont = "Helvetica Neue Condensed Bold", strokeWidth = 10, strokeColor = {hex = "#1B5E20", alpha = 0.9}, radius = 1, textColor = {hex = "#fff", alpha = 1}, fillColor = {hex = "#2E7D32", alpha = 0.9}}
local loadingStyle = {textFont = "Helvetica Neue Condensed Bold", strokeWidth = 10, strokeColor = {hex = "#263238", alpha = 0.9}, radius = 1, textColor = {hex = "#B0BEC5", alpha = 1}, fillColor = {hex = "#37474F", alpha = 0.9}}

local chipIcon = [[ASCII:
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

local log = hs.logger.new("toggleEGPU", "verbose")
log.i('Initializing toggleEGPU...')

local function kextLoaded()
    if os.execute("kextstat |grep AppleThunderboltPCIUpAdapter") then
        return true
    else
        return false
    end
end

local sleepScript = [[
    tell application "Finder"
	    eject (every disk whose ejectable is true)
    end tell

    do shell script "/usr/bin/SafeEjectGPU Eject"
]]

local ejectAllVolumes = [[
tell application "Finder"
    eject (every disk whose ejectable is true)
end tell
]]

if not kextLoaded() then
    log.w("TB Kext should be loaded but isnt!")
    hs.alert.closeAll(0.1)
    local warning = hs.alert.show("CRITICAL: KEXT ERROR", warningStyle, 3)
      -- attempt to load kext
    log.d("Attempting to reload kext...!")
    os.execute("sudo /sbin/kextload /System/Library/Extensions/AppleThunderboltPCIAdapters.kext/Contents/PlugIns/AppleThunderboltPCIUpAdapter.kext/")

    -- this is so hacky, the issue is either resolved immediatley or not
    -- but i wanted to play with a user inteface a bit
    -- problem is that most of this is synchronous and i want to avoid blocking
    -- the thread
    -- there are probably a million better ways to do this
    local loader = 20
    hs.timer.doAfter(2,
        function()
            hs.timer.doUntil(function() return loader == 0 end,
                function()
                    loader = loader - 1
                    hs.alert.closeAll(0.75)
                    hs.alert("RECOVERING...", loadingStyle, 1.5)
                end,
            2)
        end
    )
  
    if not kextLoaded() then
        log.e("Still can't load kext, something is broke")
        hs.alert("TB KEXT NOT LOADED, CANNOT RECOVER!", 10)
    else
        -- another fake delay for ui reasons
        hs.timer.doAfter(8, 
            function()
                loader = 0
                hs.alert.closeAll(0.5)
                log.i("Issue resolved")
                hs.alert("SUCCESS!", successStyle, 3)
            end
        )
    end
end

local function toggleTB()
    if kextLoaded() then
        os.execute("sudo /sbin/kextunload /System/Library/Extensions/AppleThunderboltPCIAdapters.kext/Contents/PlugIns/AppleThunderboltPCIUpAdapter.kext/")
    else
        os.execute("sudo /sbin/kextload /System/Library/Extensions/AppleThunderboltPCIAdapters.kext/Contents/PlugIns/AppleThunderboltPCIUpAdapter.kext/")
    end
end

function sleepWatch(eventType)
    if (eventType == hs.caffeinate.watcher.systemWillSleep) then
        log.i("Sleeping...")
        if hs.osascript._osascript(sleepScript, "AppleScript") then
            log.i("sleepScript successful!")
        else
            log.e("sleepScript error:" .. result)
        end
    elseif (eventType == hs.caffeinate.watcher.screensDidWake) then
        log.i("Waking...")
        toggleTB()
    end
end

local egpuMenuOptions = {
    { title = "⏏  eGPU & Vols", fn = function() os.execute("/usr/bin/SafeEjectGPU Eject") hs.osascript._osascript(ejectAllVolumes, "AppleScript") end },
    { title = "⏏  eGPU", fn = function() os.execute("/usr/bin/SafeEjectGPU Eject") end}, 
    { title = "⏏  Vols", fn = function() hs.osascript._osascript(ejectAllVolumes, "AppleScript") end},
    { title = "-"},
    { title = "Toggle TB", fn = function() toggleTB() end},
}

local egpuMenuLoaded = false
local egpuMenuMaker = function()
    if egpuMenuLoaded then
        table.remove(egpuMenuOptions)
    end

    egpuMenuLoaded = true

    if kextLoaded() then
        table.insert(egpuMenuOptions, {title = "TB ✔︎", disabled = false})
        return egpuMenuOptions
    else
        table.insert(egpuMenuOptions, {title = "TB ✗", disabled = true})
        return egpuMenuOptions
    end
end

local egpuMenu = hs.menubar.new():setIcon(chipIcon):setMenu(egpuMenuMaker)

local sleepWatcher = hs.caffeinate.watcher.new(sleepWatch)
sleepWatcher:start()