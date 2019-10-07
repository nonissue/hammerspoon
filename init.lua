------------------------------------------------------------------------------
-- init.lua
------------------------------------------------------------------------------
-- By: Andy Williams / hammerspoon [ at ] nonissue dot org
------------------------------------------------------------------------------
-- A hammerspoon config
-- If you have concerns (about my sanity or anything else) feel free to
-- email me at the above address
------------------------------------------------------------------------------

-- load basic modules / utils first
package.path = package.path .. ";lib/?.lua"
local styles = require("styles")
local utils = require("utilities")
require("console")

-- bind our alert style to default alert style
for k, v in pairs(styles.alert_default) do
    hs.alert.defaultStyle[k] = v
end

if not hs.ipc.cliStatus() then
    local cliInstallResult = hs.ipc.cliInstall()
    if cliInstallResult then
        require('hs.ipc')
    else
        hs.alert('hs.ipc error!')
    end
else
    require('hs.ipc')
end

-- set logger level
hs.logger.defaultLogLevel = "debug"

-- This is great, disables all the superfluous hotkey logging
require("hs.hotkey").setLogLevel("warning")

-- Add WIP Spoons to path
package.path = hs.configdir .. "/WIP/?.spoon/init.lua;" .. package.path

-- Add WIP files to path
package.path = package.path .. ";WIP/?.lua"

hostname = hs.host.localizedName()
hs_config_dir = os.getenv("HOME") .. "/.hammerspoon/"

-- a MUST / disables window movement jank
hs.window.animationDuration = 0

-- aliases
i = hs.inspect
fw = hs.window.focusedWindow
bind = hs.hotkey.bind
clear = hs.console.clearConsole
reload = hs.reload
pbcopy = hs.pasteboard.setContents
print_t = utils.print_r
print_r = utils.print_r

-- hotkey groups
local mash = {"cmd", "alt", "ctrl"}
-- local hyper = {"cmd", "alt"}

-- console window hotkey
hs.hotkey.bind(mash, "y", function() hs.toggleConsole() hs.window.frontmostWindow():focus() end)

-- TODO: Let user enable/display spoons as desired.
-- i feel like these two should be spoons
-- because they rely on watchers
-- TODO: Move the below to spoons
local hs_reload = require("hammerspoon_config_reload")
hs_reload.init()

------------------------------------------------------------------------------
--                              START OF SPOONS                             --
------------------------------------------------------------------------------
-- ControlEscape.spoon / https://github.com/jasonrudolph/ControlEscape.spoon
------------------------------------------------------------------------------
-- I wanted this to resolve my issues with my locking capslock key on my
-- AEKII m3501, but I don't think it does
-- It does replace Karabiner Elements for me though, which is nice!
-- EDIT: maybe check this
-- https://gist.github.com/zcmarine/f65182fe26b029900792fa0b59f09d7f
------------------------------------------------------------------------------
-- hs.loadSpoon('CTRLESC')
hs.loadSpoon('CTRLESC'):start()

------------------------------------------------------------------------------
-- Context.spoon / by me
------------------------------------------------------------------------------
-- Watches for wifi ssid changes + screen resolution changes
-- If changes are detected and match a series of rules
-- Systemwide settings are configured
-- For example:
--  * On wifi ssid change, if isn't one of our home networks
--    system is muted and screenlock is set to a short time
--
-- PARAMS:
-- [Optional] Accepts a boolean which dictates whether the menubar item is shownd
-- Defaults to false if nothing is passed
------------------------------------------------------------------------------
hs.settings.set("homeSSIDs", {"BROMEGA", "ComfortInn VIP", "BROMEGA-5", "1614 Apple II"})
local drives = {"ExternalSSD", "Win-Stuff", "Photos"}
local display_ids = {mbp = 2077750265, cinema = 69489832, sidecar = 4128829}

hs.settings.set("context.drives", drives)
hs.settings.set("context.display_ids", display_ids)

hs.loadSpoon("Context"):start({ showMenu = false, display_ids = display_ids, drives = drives})

------------------------------------------------------------------------------
-- SafariKeys.spoon / by me
------------------------------------------------------------------------------
hs.loadSpoon("SafariKeys")
spoon.SafariKeys:bindHotkeys(spoon.SafariKeys.defaultHotkeys)

------------------------------------------------------------------------------
-- PaywallBuster.spoon / by me
------------------------------------------------------------------------------
-- Ultimately this probably isn't necessary, but I do occasionally use it
------------------------------------------------------------------------------
hs.loadSpoon("PaywallBuster")
hs.hotkey.bind(mash, "B", function() spoon.PaywallBuster:show() end)

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
-- TODO: use default hotkeys
hs.hotkey.bind(mash, "S", function() spoon.Zzz.chooser:show() end)

------------------------------------------------------------------------------
-- Resolute.spoon / by me
------------------------------------------------------------------------------
-- Menubar item + modal for quickly changing display resolution
-- Currently, you have to specify the choices manually
-- May change that in future
------------------------------------------------------------------------------
-- TODO: use default hotkeys
hs.loadSpoon("Resolute")
-- hs.hotkey.bind(mash, "L", function() spoon.Resolute:show() end)
-- spoon.Resolute:bindHotkeys(spoon.Resolute.defaultHotkeys)
hs.hotkey.bind(mash, "L", function() spoon.Resolute:show() end)

------------------------------------------------------------------------------
-- Fenestra.spoon / by me
------------------------------------------------------------------------------
-- My window management stuff
-- Resize active windows, move stuff between monitors, etc
------------------------------------------------------------------------------
hs.loadSpoon("Fenestra")
spoon.Fenestra:bindHotkeys(spoon.Fenestra.defaultHotkeys)

------------------------------------------------------------------------------
-- [WIP] AfterDark.spoon / by me
------------------------------------------------------------------------------
-- Dark mode toggle in menubar
-- PARAMS:
-- [Optional] Accepts a boolean which dictates whether the menubar item is shown
-- Defaults to false if nothing is passed
------------------------------------------------------------------------------
hs.loadSpoon("AfterDark"):start({showMenu = true})

------------------------------------------------------------------------------
-- Clippy.spoon / by me
------------------------------------------------------------------------------
-- Copy screenshot to clipboard and save to disk
------------------------------------------------------------------------------
hs.loadSpoon("Clippy"):start()

------------------------------------------------------------------------------
-- Crib.spoon / by me
------------------------------------------------------------------------------
-- WIP, not finished at all
------------------------------------------------------------------------------
-- hs.loadSpoon("Crib")
-- spoon.Crib:bindHotkeys(spoon.Crib.defaultHotkeys)
------------------------------------------------------------------------------

-- WIP Stuff
-- hs.loadSpoon("PlexMini")
-- require("sql3-test")
-- hs.loadSpoon("QuickAdd")
-- require("callbacks")
-- hs.loadSpoon("SysInfo")
-- spoon.SysInfo:startFor(0.1)
hs.loadSpoon("Alarm")
------------------------------------------------------------------------------
--                                END OF SPOONS                             --
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--                                NONSENSE                                  --
------------------------------------------------------------------------------

-- random stuff
-- local yay = "ᕙ(⇀‸↼‶)ᕗ"
-- local boo = "ლ(ಠ益ಠლ)"
local kirby = "¯\\_(ツ)_/¯"

local function showKirby()
    hs.alert(kirby, styles.alert_loader, 5)
    hs.pasteboard.setContents("¯\\_(ツ)_/¯")
end

hs.hotkey.bind(mash, "K", showKirby)
-- hs.hotkey.showHotkeys(mash, "space")

-- COPIED FROM: https://github.com/af/dotfiles/blob/63370411e709e006b26f07781376da1e6d7ae2c8/hammerspoon/utils.lua#L51
-- Close all open notifications
local function dismissAllNotifications()
    local success, result = hs.applescript([[
    tell application "System Events"
        tell process "Notification Center"
            set theWindows to every window
            repeat with i from 1 to number of items in theWindows
                set this_item to item i of theWindows
                try
                    click button 1 of this_item
                end try
            end repeat
        end tell
    end tell
    ]])
    if not success then
        hs.logger.e("Error dismissing notifcations")
        hs.logger.e(result)
    end
end

hs.hotkey.bind(mash, "N", dismissAllNotifications)

-- hs.textDroppedToDockIconCallback()
-- hs.dockIconClickCallback()
-- hs.dockIcon(true)
-- initial testing with using the 'send to' contextual menu functionality
hs.textDroppedToDockIconCallback = function(value)
    hs.alert(string.format("Text dropped to dock icon: %s", value))
end

