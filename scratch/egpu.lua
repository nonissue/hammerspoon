--[[
Module to eject EGPU and drives on sleep so computer is ready to be unplugged at any time
Requires modifying sudoers file

Run:
sudo visudo -f /etc/sudoers.d/toggle_tb

Paste the following, with your username (you can use whoami to verify your username):
<YOURUSERNAME> ALL=(root) NOPASSWD: /sbin/kextunload /System/Library/Extensions/AppleThunderboltPCIAdapters.kext/Contents/PlugIns/AppleThunderboltPCIUpAdapter.kext/
<YOURUSERNAME> ALL=(root) NOPASSWD: /sbin/kextload /System/Library/Extensions/AppleThunderboltPCIAdapters.kext/Contents/PlugIns/AppleThunderboltPCIUpAdapter.kext/
]]
os.execute("sudo /sbin/kextunload /System/Library/Extensions/AppleThunderboltPCIAdapters.kext/Contents/PlugIns/AppleThunderboltPCIUpAdapter.kext/")
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
    log.w("TB Kext should be loaded but isnt!")
    hs.alert.closeAll(0.1)
    local warning = hs.alert.show("CRITICAL: KEXT ERROR", styles.alert_warning, 4)
      -- attempt to load kext
    log.d("Attempting to reload kext...!")
      -- hs.alert.closeAll(10)
    os.execute("sudo /sbin/kextload /System/Library/Extensions/AppleThunderboltPCIAdapters.kext/Contents/PlugIns/AppleThunderboltPCIUpAdapter.kext/")
    -- hs.timer.doAfter(4, 
    --     function()
    --         hs.alert.closeAll(1)
    --         -- hs.alert.closeSpecific(warning, 4)
    --         hs.alert("Attempting Recovery...", styles.alert_warning, 6)
    --     end
    -- )

    local loader = 20
    -- hs.alert.closeAll(0.4)
    -- hs.timer.usleep(3000000)

    hs.timer.doAfter(2,
        function()
            -- hs.alert("Attempting Recovery...", styles.alert_warning, 1)
            -- hs.alert.closeSpecific(warning, 0.1)
            -- hs.alert.closeAll(1.5)
            hs.timer.doUntil(function() return loader == 0 end,
                function()
                    loader = loader - 1
                    hs.alert.closeAll(2)
                    hs.alert("Attempting Recovery...", styles.alert_loader, 1.75)
                end,
            2)
        end
    )
  

    if not kextLoaded() then
        log.e("Still can't load kext, something is broke")
        hs.alert("TB KEXT NOT LOADED, CANNOT RECOVER!", styles.alert_warning_lrg, 10)
    else
        hs.timer.doAfter(10, 
            function()
                loader = 0
                hs.alert.closeAll(0.5)
                log.i("Issue resolved")
                hs.alert("Issue resolved!", styles.alert_success, 3)
            end
        )
    end
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
            log.e("Could not unload kext")
            hs.alert("COULDNT UNLOAD KEXT!", styles.alert_warning_lrg, 3)
        end
        os.execute("sudo /sbin/kextload /System/Library/Extensions/AppleThunderboltPCIAdapters.kext/Contents/PlugIns/AppleThunderboltPCIUpAdapter.kext/")
        if not kextLoaded() then
            log.e("Issue loading thunderbolt kext!")
            log.e("INVESTIGATE!")
            hs.alert("TB KEXT SHOULD BE LOADED BUT ISNT!", styles.alert_warning_lrg, 10)
        end
        log.d("Display should be connecting...")
        hs.alert("TB Toggle Success!", styles.alert_success, 3)
    end
end
    
local sleepWatcher = hs.caffeinate.watcher.new(sleepWatch)
sleepWatcher:start()