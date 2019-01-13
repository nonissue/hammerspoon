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
-- that don't need to be spoons
package.path = package.path .. ";lib/?.lua"
styles = require("styles")
utils = require("utilities")

-- bind our alert style to default alert style
for k, v in pairs(styles.alert_default) do
    hs.alert.defaultStyle[k] = v
end

-- set logger level
hs.logger.defaultLogLevel = "error"

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

-- hotkey groups
local mash = {"cmd", "alt", "ctrl"}
local hyper = {"cmd", "alt"}
local alt = {"alt"}

-- console window hotkey
hs.hotkey.bind(mash, "y", function() hs.toggleConsole() end)

-- load scratch stuff
package.path = package.path .. ";scratch/?.lua"

-- TODO: Let user enable/display spoons as desired.
-- i feel like these two should be spoons
-- because they rely on watchers
-- TODO: Move the below to spoons
hs_reload = require("hammerspoon_config_reload")
hs_reload.init()

------------------------------------------------------------------------------
--                              START OF SPOONS                             --
------------------------------------------------------------------------------
-- ControlEscape.spoon / https://github.com/jasonrudolph/ControlEscape.spoon
------------------------------------------------------------------------------
-- I wanted this to resolve my issues with my locking capslock key on my
-- AEKII m3501, but I don't think it does
-- It does replace Karabiner Elements for me though, which is nice!
------------------------------------------------------------------------------
hs.loadSpoon('ControlEscape'):start()

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
    cycleUserAgent = {mash, "7"}
}

spoon.SafariKeys:bindHotkeys(safariHotkeys) -- TODO: use default hotkeys

------------------------------------------------------------------------------
-- PaywallBuster.spoon / by me
------------------------------------------------------------------------------
-- Ultimately this probably isn't necessary, but I do occasionally use it
------------------------------------------------------------------------------
hs.loadSpoon("PaywallBuster")
hs.hotkey.bind(mash, "B", function() spoon.PaywallBuster:show() end) -- TODO: use default hotkeys

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
hs.hotkey.bind(mash, "S", function() spoon.Zzz.chooser:show() end) -- TODO: use default hotkeys

------------------------------------------------------------------------------
-- Resolute.spoon / by me
------------------------------------------------------------------------------
-- Menubar item + modal for quickly changing display resolution
-- Currently, you have to specify the choices manually
-- May change that in future
------------------------------------------------------------------------------
hs.loadSpoon("Resolute")
hs.hotkey.bind(mash, "L", function() spoon.Resolute:show() end) -- TODO: use default hotkeys

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
hs.loadSpoon("Crib")
spoon.Crib:bindHotkeys(spoon.Crib.defaultHotkeys)

------------------------------------------------------------------------------
--                                END OF SPOONS                             --
------------------------------------------------------------------------------


------------------------------------------------------------------------------
--                                NONSENSE                                  --
------------------------------------------------------------------------------

-- random stuff
local yay = "ᕙ(⇀‸↼‶)ᕗ"
local boo = "ლ(ಠ益ಠლ)"
local kirby = "¯\\_(ツ)_/¯"

local function showKirby()
    hs.alert(kirby, styles.alert_loader, 5)
    hs.pasteboard.setContents("¯\\_(ツ)_/¯")
end

hs.hotkey.bind(mash, "K", showKirby)
hs.hotkey.showHotkeys(mash, "space")
