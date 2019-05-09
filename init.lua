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

-- bind our alert style to default alert style
for k, v in pairs(styles.alert_default) do
    hs.alert.defaultStyle[k] = v
end

-- set logger level
hs.logger.defaultLogLevel = "debug"

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
local hyper = {"cmd", "alt"}

-- console window hotkey
hs.hotkey.bind(mash, "y", function() hs.toggleConsole() hs.window.frontmostWindow():focus() end)

-- load scratch stuff
-- package.path = package.path .. ";scratch/?.lua"

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
hs.loadSpoon('CTRLESC')
hs.loadSpoon('CTRLESC'):start()

------------------------------------------------------------------------------
-- SystemContexts.spoon / by me
------------------------------------------------------------------------------
hs.loadSpoon("SystemContexts")

------------------------------------------------------------------------------
-- SafariKeys.spoon / by me
------------------------------------------------------------------------------
hs.loadSpoon("SafariKeys")

local safariHotkeys = {
    tabToNewWin = {mash, "T"},
    mailToSelf = {mash, "U"},
    mergeAllWindows = {mash, "M"},
    pinOrUnpinTab = {hyper, "P"},
    cycleUserAgent = {mash, "7"},
    addToReadingList = {mash, "R"}
}

 -- TODO: use default hotkeys
spoon.SafariKeys:bindHotkeys(safariHotkeys)

------------------------------------------------------------------------------
-- PaywallBuster.spoon / by me
------------------------------------------------------------------------------
-- Ultimately this probably isn't necessary, but I do occasionally use it
------------------------------------------------------------------------------
hs.loadSpoon("PaywallBuster")
-- TODO: use default hotkeys
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

-- hs.loadSpoon("Timers")


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
-- Crib.spoon / by me
------------------------------------------------------------------------------
-- WIP, not finished at all
------------------------------------------------------------------------------
-- hs.loadSpoon("Crib")
-- spoon.Crib:bindHotkeys(spoon.Crib.defaultHotkeys)

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
hs.hotkey.showHotkeys(mash, "space")

-- hs.textDroppedToDockIconCallback()
-- hs.dockIconClickCallback()
-- hs.dockIcon(true)
-- initial testing with using the 'send to' contextual menu functionality
hs.textDroppedToDockIconCallback = function(value)
    hs.alert(string.format("Text dropped to dock icon: %s", value))
end