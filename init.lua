------------------------------------------------------------------------------
-- init.lua
------------------------------------------------------------------------------
-- By: Andy Williams / hammerspoon [ at ] nonissue dot org
------------------------------------------------------------------------------
-- A hammerspoon config
-- If you have concerns (about my sanity or anything else) feel free to
-- email me at the above address
------------------------------------------------------------------------------

--- WIP
-- spaces = require("hs._asm.undocumented.spaces")
---

package.path = package.path .. ";_lib/?.lua"
package.path = hs.configdir .. "/_Spoons/?.spoon/init.lua;" .. package.path
package.path = hs.configdir .. "/WIP/?.spoon/init.lua;" .. package.path
package.path = package.path .. ";_scratch/?.lua"
local styles = require("styles")
local utils = require("utilities")
local hs_reload = require("hammerspoon_config_reload")

hs_reload.init()
require("console")

-- bind our alert style to default alert style
for k, v in pairs(styles.alert_default) do
    hs.alert.defaultStyle[k] = v
end

-- can't remember if/what depends on this

-- if not hs.ipc.cliStatus() then
--     local cliInstallResult = hs.ipc.cliInstall()
--     if cliInstallResult then
--         require("hs.ipc")
--     else
--         hs.alert("hs.ipc error!")
--     end
-- else
--     hs.ipc.cliSaveHistory(true)
--     require("hs.ipc")
-- end

-- sane defaults
hs.logger.defaultLogLevel = 5
require("hs.hotkey").setLogLevel("warning")
hs.window.animationDuration = 0

i = hs.inspect
fw = hs.window.focusedWindow
bind = hs.hotkey.bind
clear = hs.console.clearConsole
reload = hs.reload
pbcopy = hs.pasteboard.setContents
print_t = utils.print_r
print_r = utils.print_r
hostname = hs.host.localizedName()
-- access location early to trigger macOS location services permission dialog on first run
-- and to load hs.locaiton on future runs because:
-- hs.wifi.currentNetwork() relies on user's location as of macOS 14
local location = hs.location.get()
local mash = { "cmd", "alt", "ctrl" }

-- ==========================================================================
-- START OF SPOONS
-- ==========================================================================

--[[

    ┌────────────────┬───────────────┐
    │    Spoon:      │    Clippy     │
    ├────────────────┼───────────────┤
    │    Author:     │    Me         │
    └────────────────┴───────────────┘

    Copy screenshot to clipboard AND save to disk at the same time
    which is weirdly not possible on macOS

]]

hs.loadSpoon("Clippy"):start()

--[[

    ┌────────────────┬───────────────┐
    │    Spoon:      │    CTRLESC    │
    ├────────────────┼───────────────┤
    │    Author:     │    Me         │
    └────────────────┴───────────────┘

    Inspiraction/prior art:
    ControlEscape.spoon / https://github.com/jasonrudolph/ControlEscape.spoon

    —

    I wanted this to resolve my issues with my locking capslock key on my
    AEKII m3501, but I don't think it does
    It does replace Karabiner Elements for me though, which is nice!
    EDIT: maybe check this
    https://gist.github.com/zcmarine/f65182fe26b029900792fa0b59f09d7f

]]

hs.loadSpoon("CTRLESC"):start()

--[[

    ┌────────────────┬───────────────┐
    │    Spoon:      │    Context    │
    ├────────────────┼───────────────┤
    │    Author:     │    Me         │
    └────────────────┴───────────────┘

    Watches for wifi ssid changes + screen resolution changes
    If changes are detected and match a series of rules
    Systemwide settings are configured
    For example:
    * On wifi ssid change, if isn't one of our home networks
    system is muted and screenlock is set to a short time

    PARAMS:
    [Optional] Accepts a boolean which dictates whether the menubar item is shown
    Defaults to false if nothing is passed

 ]]

--- this is config for contexts, not ideal atm
local drives = { "ExternalSSD", "Win-Stuff", "Photos" }
local display_ids = { mbp = 2077750265, cinema = 69489832, sidecar = 4128829 }

hs.settings.set(
    "homeSSIDs",
    {
        "BROMEGA",
        "ComfortInn VIP",
        "BROMEGA-5",
        "1614 Apple II",
        "RamadaGuest",
        "RamadaVIP",
        "RamadaExecutive",
        "RamadaExecutive_5G"
    }
)
hs.settings.set("context.drives", drives)
hs.settings.set("context.display_ids", display_ids)

-- Load spoon
hs.loadSpoon("Context"):start(
    {
        showMenu = true,
        display_ids = display_ids,
        drives = drives
    }
)

--[[

    ┌────────────────┬───────────────────┐
    │    Spoon:      │    SafariKeys     │
    ├────────────────┼───────────────────┤
    │    Author:     │    Me             │
    └────────────────┴───────────────────┘

    Custom hotkeys for safari that target commands or actions
    available in the menubar but that don't have a hotkey bound to them.
    For example, move tab to new window or merge all windows are available
    in the menu system but are annoying to find and invoke.

]]

hs.loadSpoon("SafariKeys")
spoon.SafariKeys:bindHotkeys(spoon.SafariKeys.defaultHotkeys)


--[[
    ┌────────────────┬───────────────────┐
    │    Spoon:      │    SafariKeys     │
    ├────────────────┼───────────────────┤
    │    Author:     │    Me             │
    └────────────────┴───────────────────┘

    Ultimately this probably isn't necessary, but I do occasionally use it
    TODO: bind default hotkey in spoon
]]
--[[
    hs.loadSpoon("PaywallBuster")
    hs.hotkey.bind(
        mash,
        "B",
        function()
            spoon.PaywallBuster:show()
        end
    )
]]

--[[
    ┌────────────────┬───────────────────┐
    │    Spoon:      │    SafariKeys     │
    ├────────────────┼───────────────────┤
    │    Author:     │    Me             │
    └────────────────┴───────────────────┘

    Ultimately this probably isn't necessary, but I do occasionally use it
    TODO: bind default hotkey in spoon
    hs.loadSpoon("PaywallBuster")
    hs.hotkey.bind(
        mash,
        "B",
        function()
            spoon.PaywallBuster:show()
        end
    )
]]
------------------------------------------------------------------------------
-- Zzz.spoon / by me
------------------------------------------------------------------------------
-- Sleep timer, puts computer to sleep after an interval
-- Shows a countdown in the menubar
-- Can be triggered from menubar
-- Menubar also provides snooze/shorten functions
-- There is also a modal to let users enter custom times
------------------------------------------------------------------------------

hs.loadSpoon("Zzz")
spoon.Zzz:bindHotkeys(spoon.Zzz.defaultHotkeys)

------------------------------------------------------------------------------
-- EasyTOTP.spoon / by me
------------------------------------------------------------------------------
-- Get current TOTP token, copy to clipboard and type in frontmost window
------------------------------------------------------------------------------

-- hs.loadSpoon("EasyTOTP")

------------------------------------------------------------------------------
-- Resolute.spoon / by me
------------------------------------------------------------------------------
-- Menubar item + modal for quickly changing display resolution
-- Currently, you have to specify the choices manually
-- May change that in future
------------------------------------------------------------------------------
-- hs.loadSpoon("Resolute")
-- spoon.Resolute:bindHotkeys(spoon.Resolute.defaultHotkeys)

------------------------------------------------------------------------------
-- Fenestra.spoon / by me
------------------------------------------------------------------------------
-- My window management stuff
-- Resize active windows, move stuff between monitors, etc
------------------------------------------------------------------------------
hs.loadSpoon("Fenestra")
spoon.Fenestra:bindHotkeys(spoon.Fenestra.defaultHotkeys)



------------------------------------------------------------------------------
-- Wip
------------------------------------------------------------------------------
-- hs.loadSpoon("Layers"):start()
-- Look for Spoons in ~/.hammerspoon/MySpoons as well
-- hs.loadSpoon("HammerText")
-- hs.loadSpoon("CMDTAB"):start()
-- hs.loadSpoon("HammerMenu"):start()
------------------------------------------------------------------------------
--                                END OF SPOONS                             --
------------------------------------------------------------------------------

TextInflator = require("TextInflator")
TextInflator:init()

-- Messing around wtih asmagills spoon formatting but it's weird
-- hs.loadSpoon is easier for me to reason about

-- hs.loadSpoon("BuildBot")
-- spoon.BuildBot:bindHotkeys(spoon.BuildBot.defaultHotkeys)


-- hs.loadSpoon("CMDESC"):start()

-- hs.loadSpoon("LoPo"):init()
-- hs.loadSpoon("LoPo"):start()

-- hs.loadSpoon("KSheet"):init()
-- KSheetDefaultHotkeys = {
--     toggle = {{"ctrl", "alt", "cmd"}, "K"}
-- }
-- spoon.KSheet:bindHotkeys(KSheetDefaultHotkeys)

-- Map the middle mouse to the alt key
-- function captureMouseButtons()
--     eventtapOtherMouseDown =
--         hs.eventtap.new(
--         {hs.eventtap.event.types.otherMouseDown},
--         function(event)
--             if (event:getType() == hs.eventtap.event.types.otherMouseDown) then
--                 hs.alert.show("otherMouseDown" .. event:getType())
--
--                 return true, {hs.eventtap.event.newKeyEvent({"alt"}, hs.keycodes.map.alt, true)}
--             end
--             return false -- shouldn't ever reach here, but just in case
--         end
--     ):start()
--
--     eventtapOtherMouseUp =
--         hs.eventtap.new(
--         {hs.eventtap.event.types.otherMouseUp},
--         function(event)
--             if (event:getType() == hs.eventtap.event.types.otherMouseUp) then
--                 hs.alert.show("otherMouseUp" .. event:getType())
--                 return true, {hs.eventtap.event.newKeyEvent({}, hs.keycodes.map.alt, false)}
--             end
--             return false -- shouldn't ever reach here, but just in case
--         end
--     ):start()
-- end

-- wst =
--     hs.websocket.new(
--     "wss://client.pushover.net/push",
--     function(e, m)
--         if e == "open" then
--             wst:send(
--                 "login:5h8zicnjp715k6qimv41r6jjueuht3c937ahpgvi:s4kbk6erc3ojz8m7ya7g8f4fy69h695nk4az7u8acy4ciaxv99jen1epx4u6",
--                 false
--             )
--         else
--             hs.alert(string.format("event: %s", e))
--             hs.alert(string.format("message: %s", m))
--             print(string.format("event: %s", e))
--             print(string.format("message: %s", m))
--         end
--     end
-- )

-- if (wst:status() == "open") then
-- local sendres =
--     wst:send(
--     "login:5h8zicnjp715k6qimv41r6jjueuht3c937ahpgvi:s4kbk6erc3ojz8m7ya7g8f4fy69h695nk4az7u8acy4ciaxv99jen1epx4u6",
--     false
-- )
-- hs.alert(sendres)
-- end

--[[

ALLOW APPLESCRIPT VIA HAMMERSPOON TO ACCESS REMINDERS/CONTACTS/CALENDAR

There is a bug with doing something like this:

    local _, _, test = hs.osascript._osascript(
                        'tell application "Reminders" to return properties of lists',
                        "AppleScript")

    print_r(test)

WE NEED TO RUN THIS ONCE FOR EACH APP FIRST TO ALLOW ACCESS

    hs.execute('osascript -e \'tell application "Reminders" to return default account\'')

Repeat as needed for each app.

-- ]]

-- local BuildBot = hs.loadSpoon("BuildBot")
-- BuildBot:bindHotkeys({
--     start = { { "ctrl", "alt", "cmd" }, "S" },
--     pause = { { "ctrl", "alt", "cmd" }, "P" },
--     resume = { { "ctrl", "alt", "cmd" }, "R" },
--     stop = { { "ctrl", "alt", "cmd" }, "X" },
--     toggle = { { "ctrl", "alt", "cmd" }, "H" },
--     reload = { { "ctrl", "alt", "cmd" }, "L" },
-- })
-- BuildBot:setGameFilter("com.blizzard.starcraft2")
-- BuildBot:loadBuild({
--     { time = 0,   supply = "12", action = "SCV" },
--     { time = 17,  supply = "13", action = "SCV" },
--     { time = 25,  supply = "14", action = "Supply Depot" },
--     { time = 34,  supply = "14", action = "SCV" },
--     { time = 55,  supply = "15", action = "SCV" },
--     { time = 58,  supply = "15", action = "Barracks" },
--     { time = 64,  supply = "16", action = "Refinery" },
--     { time = 72,  supply = "16", action = "SCV" },
--     { time = 89,  supply = "17", action = "SCV" },
--     { time = 106, supply = "18", action = "SCV" },
--     { time = 123, supply = "19", action = "Orbital Command" },
--     { time = 137, supply = "19", action = "Command Center" },
--     { time = 152, supply = "19", action = "Barracks" },
--     { time = 160, supply = "19", action = "Barracks Reactor" },
--     { time = 170, supply = "19", action = "Supply Depot" },
--     { time = 177, supply = "19", action = "SCV" },
--     { time = 195, supply = "20", action = "Refinery" },
--     { time = 204, supply = "20", action = "SCV" },
--     { time = 206, supply = "20", action = "Factory" },
--     { time = 214, supply = "21", action = "Marine x2" },
--     { time = 225, supply = "23", action = "SCV" },
--     { time = 230, supply = "24", action = "Barracks Tech Lab" },
--     { time = 240, supply = "24", action = "Marine x2" },
--     { time = 252, supply = "28", action = "Stimpack" },
--     { time = 255, supply = "28", action = "Marine" },
--     { time = 265, supply = "29", action = "Marine" },
--     { time = 269, supply = "29", action = "Starport, Factory Reactor" },
--     { time = 282, supply = "30", action = "Marine x2" },
--     { time = 288, supply = "30", action = "Orbital Command" },
--     { time = 292, supply = "32", action = "Marine" },
--     { time = 316, supply = "34", action = "Marine, Supply Depot" },
--     { time = 336, supply = "36", action = "Medivac x2" },
--     { time = 348, supply = "42", action = "Factory Tech Lab" },
--     { time = 358, supply = "45", action = "Supply Depot" },
--     { time = 375, supply = "47", action = "Siege Tank" },
--     { time = 415, supply = "57", action = "Medivac" },
--     { time = 422, supply = "61", action = "Supply Depot" },
--     { time = 426, supply = "61", action = "Refinery" },
--     { time = 455, supply = "62", action = "Siege Tank" },
--     { time = 482, supply = "69", action = "Command Center" },
--     { time = 491, supply = "69", action = "Engineering Bay" },
--     { time = 527, supply = "63", action = "Siege Tank" },
--     { time = 533, supply = "66", action = "Terran Infantry Weapons Level 1" },
--     { time = 543, supply = "67", action = "Barracks x3" },
--     { time = 571, supply = "72", action = "Refinery" },
--     { time = 572, supply = "72", action = "Siege Tank" },
--     { time = 597, supply = "75", action = "Medivac" },
-- })

hs.alert("config reloaded")
