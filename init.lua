------------------------------------------------------------------------------
-- init.lua
------------------------------------------------------------------------------
-- By: Andrew Williams / andy@nonissue.org
------------------------------------------------------------------------------
-- A messy hammerspoon config
-- If you have concerns (about my sanity or anything else) feel free to
-- email me at the above address
------------------------------------------------------------------------------

-- TODO:
-- [ ] Load utilities module immediately
-- [ ] Overwrite default alert styles

-- Plugins (not finished):
-- SleepTimer
-- BurnRate

-- Plugins (to pluginify):
-- [x] DisplayRes
-- WarmKeys
-- [ ] Window Management
-- [x] OnLocation
-- [x] SafariKeys
-- [ ] UsefulUtilites

require("apw-lib")

package.path = package.path .. ";lib/?.lua"
styles = require("styles")
utils = require("utilities")
hs_reload = require("hammerspoon_config_reload")
burnrate = require("burnrate")

burnrate.init()
hs_reload.init()

-- bind our alert style to default alert style
for k, v in pairs(styles.alert_default) do
    hs.alert.defaultStyle[k] = v
end 

hs.loadSpoon("SystemContexts")
hs.loadSpoon("SafariKeys")
hs.loadSpoon("SysInfo")
hs.loadSpoon("PaywallBuster")
hs.loadSpoon("Zzz")
hs.loadSpoon("Resolute")

---------
-- Vars
------------------------------------------------------------------------------
-- var for hyper key and mash
-- SWITCHING THESE ON SEPT 16 2015. Previously MASH was HYPER.
-- Doesn't make any sense though both in terms of naming and use.
local mash = {"cmd", "alt", "ctrl"}
local hyper = {"cmd", "alt"}
local alt = {"alt"}

-- apw_go(
--     {
--         "lib.hammerspoon_config_reload",
--         "lib.burnrate",
--     }
-- )

spoon.Zzz:init()
spoon.Resolute:init()

local safariHotkeys = {
    tabToNewWin = {mash, "T"},
    mailToSelf = {mash, "U"},
    mergeAllWindows = {mash, "M"},
    pinOrUnpinTab = {hyper, "P"},
    cycleUserAgent = {mash, "7"}
}

spoon.SafariKeys:bindHotkeys(safariHotkeys)

hs.hotkey.bind(
    mash,
    "J",
    function()
        spoon.Resolute:show()
    end
)

hs.hotkey.bind(
    mash,
    "B",
    function()
        spoon.PaywallBuster:show()
    end
)

hs.hotkey.bind(
    mash,
    "S",
    function()
        spoon.Zzz:show()
    end
)

hs.hotkey.bind(
    {"cmd", "alt", "ctrl"},
    "y",
    function()
        hs.toggleConsole()
    end
)

-- init grid
hs.grid.MARGINX = 0
hs.grid.MARGINY = 0
hs.grid.GRIDWIDTH = 10
hs.grid.GRIDHEIGHT = 10

-- disable animation
hs.window.animationDuration = 0

----------------------------------------------------------
-- /end of WHY IS THIS HERE?
----------------------------------------------------------

hs.hotkey.bind(alt, "space", hs.grid.maximizeWindow)

hs.hotkey.bind(
    hyper,
    "H",
    function()
        hs.hints.windowHints()
    end
)

------------------------------------------------------------------------------
-- Layout stuff
-- http://larryhynes.net/2015/02/switching-from-slate-to-hammerspoon.html
------------------------------------------------------------------------------
-- Not very DRY but simple to understand and one of the first things I
-- wrote for hammerspoon
------------------------------------------------------------------------------
-- Moves window to left half of screen
hs.hotkey.bind(
    hyper,
    "left",
    function()
        local win = hs.window.focusedWindow()
        local f = win:frame()
        local screen = win:screen()
        local max = screen:frame()
        f.x = max.x
        f.y = max.y
        f.w = max.w / 2
        f.h = max.h
        win:setFrame(f)
    end
)

-- Moves window/sets width to right half of screen
hs.hotkey.bind(
    hyper,
    "right",
    function()
        local win = hs.window.focusedWindow()
        local f = win:frame()
        local screen = win:screen()
        local max = screen:frame()
        f.x = max.x + (max.w / 2)
        f.y = max.y
        f.w = max.w / 2
        f.h = max.h
        win:setFrame(f)
    end
)

-- Moves window to right, sets to 1/4 width
hs.hotkey.bind(
    mash,
    "right",
    function()
        local win = hs.window.focusedWindow()
        local f = win:frame()
        local screen = win:screen()
        local max = screen:frame()
        f.x = max.x + (max.w * 0.75)
        f.y = max.y
        f.w = max.w * 0.25
        f.h = max.h
        win:setFrame(f)
    end
)

--Moves window to left, sets to 3/4 width
hs.hotkey.bind(
    mash,
    "left",
    function()
        local win = hs.window.focusedWindow()
        local f = win:frame()
        local screen = win:screen()
        local max = screen:frame()
        f.x = max.x
        f.w = max.w * 0.75
        f.h = max.h
        f.y = max.y
        win:setFrame(f)
    end
)

hs.hotkey.bind(
    mash,
    "N",
    function()
        hs.grid.maximizeWindow()
        hs.grid.pushWindowNextScreen()
    end
)

hs.hotkey.bind(mash, "N", hs.grid.pushWindowNextScreen)
hs.hotkey.bind(mash, "P", hs.grid.pushWindowPrevScreen)

function kirby()
    hs.alert(" ¯\\_(ツ)_/¯ ", styles.alert_lrg, 1.5)
    hs.pasteboard.setContents("¯\\_(ツ)_/¯")
end

hs.hotkey.bind(mash, "K", kirby)
