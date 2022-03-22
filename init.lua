------------------------------------------------------------------------------
-- init.lua
------------------------------------------------------------------------------
-- By: Andy Williams / hammerspoon [ at ] nonissue dot org
------------------------------------------------------------------------------
-- A hammerspoon config
-- If you have concerns (about my sanity or anything else) feel free to
-- email me at the above address
------------------------------------------------------------------------------

package.path = package.path .. ";_lib/?.lua"
package.path = hs.configdir .. "/_Spoons/?.spoon/init.lua;" .. package.path
package.path = package.path .. ";_scratch/?.lua"
local styles = require("styles")
local utils = require("utilities")
better_alerts = require("better-alerts")
-- better_alerts:alert1()
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
hs.logger.defaultLogLevel = "debug"
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

local mash = {"cmd", "alt", "ctrl"}

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
hs.loadSpoon("CTRLESC"):start()

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
-- [Optional] Accepts a boolean which dictates whether the menubar item is shown
-- Defaults to false if nothing is passed
------------------------------------------------------------------------------

local drives = {"ExternalSSD", "Win-Stuff", "Photos"}
local display_ids = {mbp = 2077750265, cinema = 69489832, sidecar = 4128829}

hs.settings.set("homeSSIDs", {"BROMEGA", "ComfortInn VIP", "BROMEGA-5", "1614 Apple II", "RamadaGuest", "RamadaVIP"})
hs.settings.set("context.drives", drives)
hs.settings.set("context.display_ids", display_ids)

hs.loadSpoon("Context"):start({showMenu = true, display_ids = display_ids, drives = drives})

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
-- TODO: bind default hotkey in spoon
-- hs.loadSpoon("PaywallBuster")
-- hs.hotkey.bind(
--     mash,
--     "B",
--     function()
--         spoon.PaywallBuster:show()
--     end
-- )

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
hs.loadSpoon("Resolute")
spoon.Resolute:bindHotkeys(spoon.Resolute.defaultHotkeys)

------------------------------------------------------------------------------
-- Fenestra.spoon / by me
------------------------------------------------------------------------------
-- My window management stuff
-- Resize active windows, move stuff between monitors, etc
------------------------------------------------------------------------------
hs.loadSpoon("Fenestra")
spoon.Fenestra:bindHotkeys(spoon.Fenestra.defaultHotkeys)

------------------------------------------------------------------------------
-- Clippy.spoon / by me
------------------------------------------------------------------------------
-- Copy screenshot to clipboard and save to disk
------------------------------------------------------------------------------
hs.loadSpoon("Clippy"):start()

------------------------------------------------------------------------------
--                                END OF SPOONS                             --
------------------------------------------------------------------------------

TextInflator = require("TextInflator")
TextInflator:init()

-- hs.loadSpoon("KSheet"):init()
-- KSheetDefaultHotkeys = {
--     toggle = {{"ctrl", "alt", "cmd"}, "K"}
-- }
-- spoon.KSheet:bindHotkeys(KSheetDefaultHotkeys)
