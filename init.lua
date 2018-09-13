------------------------------------------------------------------------------
-- init.lua
------------------------------------------------------------------------------
-- By: Andy Williams / hammerspoon [ at ] nonissue dot org
------------------------------------------------------------------------------
-- A messy hammerspoon config
-- If you have concerns (about my sanity or anything else) feel free to
-- email me at the above address
------------------------------------------------------------------------------

-- yada yada
hostname = hs.host.localizedName()
hs_config_dir = os.getenv("HOME") .. "/.hammerspoon/"

-- recall hist
hs.shutdownCallback = function() hs.settings.set('history', hs.console.getHistory()) end
hs.console.setHistory(hs.settings.get('history'))

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

-- load basic modules 
-- that don't need to be spoons
package.path = package.path .. ";lib/?.lua"
styles = require("styles")
utils = require("utilities")

-- i feel like these two should be spoons
-- because they rely on watchers
hs_reload = require("hammerspoon_config_reload")
burnrate = require("burnrate")

-- and they have to be inited
burnrate.init()
hs_reload.init()

-- bind our alert style to default alert style
for k, v in pairs(styles.alert_default) do
    hs.alert.defaultStyle[k] = v
end

-- Load our spoons
hs.loadSpoon("SystemContexts")

hs.loadSpoon("SafariKeys")
local safariHotkeys = {
    tabToNewWin = {mash, "T"},
    mailToSelf = {mash, "U"},
    mergeAllWindows = {mash, "M"},
    pinOrUnpinTab = {hyper, "P"},
    cycleUserAgent = {mash, "7"}
}
spoon.SafariKeys:bindHotkeys(safariHotkeys)

hs.loadSpoon("SysInfo")

hs.loadSpoon("PaywallBuster")
hs.hotkey.bind(mash, "B", function() spoon.PaywallBuster:show() end)

hs.loadSpoon("Zzz")
spoon.Zzz:init()
hs.hotkey.bind(mash, "S", function() spoon.Zzz:show() end)

hs.loadSpoon("Resolute")
spoon.Resolute:init()
hs.hotkey.bind(mash, "J", function() spoon.Resolute:show() end)

hs.loadSpoon("Fenestra")
spoon.Fenestra:bindHotkeys(spoon.Fenestra.defaultHotkeys)


-- end of spoon load

-- random
function kirby()
    hs.alert(" ¯\\_(ツ)_/¯ ", styles.alert_tomfoolery, 5)
    hs.pasteboard.setContents("¯\\_(ツ)_/¯")
end

hs.hotkey.bind(mash, "K", kirby)
hs.hotkey.showHotkeys(mash, "space")
hs.hotkey.bind(mash, "y", function() hs.toggleConsole() end)

------------------------------------------------------------------------------
-- Layout stuff
-- http://larryhynes.net/2015/02/switching-from-slate-to-hammerspoon.html
------------------------------------------------------------------------------
-- Not very DRY but simple to understand and one of the first things I
-- wrote for hammerspoon
------------------------------------------------------------------------------
-- Moves window to left half of screen
-- hs.hotkey.bind(
--     hyper,
--     "left",
--     function()
--         local win = hs.window.focusedWindow()
--         local f = win:frame()
--         local screen = win:screen()
--         local max = screen:frame()
--         f.x = max.x
--         f.y = max.y
--         f.w = max.w / 2
--         f.h = max.h
--         win:setFrame(f)
--     end
-- )

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

