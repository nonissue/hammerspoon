--[[
Module to eject EGPU and drives on sleep so computer is ready to be unplugged at any time
Requires modifying sudoers file

Run:
sudo visudo -f /etc/sudoers.d/toggle_tb

Paste the following, with your username (you can use whoami to verify your username):
<YOURUSERNAME> ALL=(root) NOPASSWD: /sbin/kextunload /System/Library/Extensions/AppleThunderboltPCIAdapters.kext/Contents/PlugIns/AppleThunderboltPCIUpAdapter.kext/
<YOURUSERNAME> ALL=(root) NOPASSWD: /sbin/kextload /System/Library/Extensions/AppleThunderboltPCIAdapters.kext/Contents/PlugIns/AppleThunderboltPCIUpAdapter.kext/
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

if not kextLoaded() then
    log.e("TB Kext should be loaded but isnt!")
    hs.alert("TB Kext should be loaded but isnt!", 5)
    -- hs.alert("TB Kext should be loaded but isnt!", styles.alert_warning_lrg, 5)
end


function sleepWatch(eventType)
    if (eventType == hs.caffeinate.watcher.systemWillSleep) then
        log.i("Sleeping...")
        -- local res = 
        if hs.osascript._osascript(sleepScript, "AppleScript") then
            log.i("sleepScript successful!")
        else
            log.e("sleepScript error:" .. result)
        end
    elseif (eventType == hs.caffeinate.watcher.screensDidWake) then
        log.d("Waking...")
        os.execute("sudo /sbin/kextunload /System/Library/Extensions/AppleThunderboltPCIAdapters.kext/Contents/PlugIns/AppleThunderboltPCIUpAdapter.kext/")
        if not kextLoaded() then
            log.i("kext unloaded successfully?!")
        else
            log.e("Issue toggling thunderbolt kext!")
            hs.alert("Issue toggling thunderbolt after sleep")
        end
        os.execute("sudo /sbin/kextload /System/Library/Extensions/AppleThunderboltPCIAdapters.kext/Contents/PlugIns/AppleThunderboltPCIUpAdapter.kext/")
        log.d("Display should be connecting...")
    end
end
    
local sleepWatcher = hs.caffeinate.watcher.new(sleepWatch)
sleepWatcher:start()