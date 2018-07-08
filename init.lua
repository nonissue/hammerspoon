------------------------------------------------------------------------------
-- VERY VERY early hammerspoon init.lua
------------------------------------------------------------------------------
-- By: Andrew Williams / andy@nonissue.org
------------------------------------------------------------------------------
-- Still a goddamn mess, but may be useful to someone
-- Haven't done much of anything, most of it is just experimenting
-- If you have concerns (about my sanity or anything else) feel free to
-- email me at the above address
------------------------------------------------------------------------------

-- TODO:
-- [ ] really should create objects with the properties of laptop and desktop / EDIT: ADD TO apw-lib.lua
-- [ ] right now, if something changes, multiple references are scattered
-- in the code in a bunch of places (like if display type for desktop changes)
-- [ ] Energy Activity Use Indicator while mobile
-- [ ] Plugin-ify non-standard config
-- [ ] Move plugins to plugins folder, load dynamically?
-- [ ] Use Spoons

-- Plugins (not finished):
-- SleepTimer
-- BurnRate 

-- Plugins (to pluginify):
-- DisplayRes
-- CasualSafari
-- WarmKeys
-- WinWin
-- OnLocation
-- UsefulUtilites
require('apw-lib')
require('init-plugins')

hs.loadSpoon("SystemContexts")
hs.loadSpoon("SafariKeys")
hs.loadSpoon("SysInfo")
hs.loadSpoon("PaywallBuster")
-- hs.loadSpoon("Resolute")
hs.loadSpoon("Zzz")
-- hs.loadSpoon("SpoonInstall")
-- hs.loadSpoon("MenubarTimer")

-- spoon.MenubarTimer:start()

-- hs.console.clearConsole()


-- Conditional to multiple montior set up.
-- Contexts in which computer can be used:
--    At home, plugged in to monitors / egpu
--    At home, not plugged in
--    Away from home
--
-- settings to apply based on context:
--    screen lock time
--    volume
--    dock position
--    default app layouts

---------
-- Vars
------------------------------------------------------------------------------
-- var for hyper key and mash
-- SWITCHING THESE ON SEPT 16 2015. Previously MASH was HYPER.
-- Doesn't make any sense though both in terms of naming and use.
local mash =    {"cmd", "alt", "ctrl" }
local hyper =   {"cmd", "alt"         }
local alt =     {"alt"                }

apw_go({
    "apps.utilities",
    "apps.hammerspoon_config_reload",
    "apps.hammerspoon_toggle_console",
    "apps.change_resolution",
    "battery.burnrate",
    "sounds.sounds",
})


spoon.Zzz:init()
-- spoon.Resolute:init()

local safariHotkeys =  {
    tabToNewWin = {mash, "T"},
    mailToSelf = {mash, "U"},
    mergeAllWindows = {mash, "M"},
    pinOrUnpinTab = {hyper, "P"},
    cycleUserAgent = {mash, "7"},
}

spoon.SafariKeys:bindHotkeys(safariHotkeys)

hs.hotkey.bind(mash, "J", function()
    spoon.Resolute:show()
end)

hs.hotkey.bind(mash, "B", function()
    spoon.PaywallBuster:show()
end)

hs.hotkey.bind(mash, "S", function()
    spoon.Zzz:show()
end)

-- init grid
hs.grid.MARGINX         = 0
hs.grid.MARGINY         = 0
hs.grid.GRIDWIDTH       = 10
hs.grid.GRIDHEIGHT      = 10

-- disable animation 
hs.window.animationDuration = 0

----------------------------------------------------------
-- WHY IS THIS HERE?
----------------------------------------------------------
-- Screen watcher stuff
-- Seems buggy, affinity designer triggers screen change?
local screens = #hs.screen.allScreens()

local lastNumberOfScreens = #hs.screen.allScreens()

function screenWatcher()
    newNumberOfScreens = #hs.screen.allScreens()
  
    if newNumberOfScreens == 1 then
        hs.alert.show("Screens: internal display", alerts_nobg, 1.5)
    elseif newNumberOfScreens == 2 then
        hs.alerts.show("Screens: +1", alerts_nobg, 1.5)
    end
    
    hs.alert.show("Screens count: " .. newNumberOfScreens, alerts_nobg, 1.5)
    lastNumberOfScreens = newNumberOfScreens
end

local display_laptop = "Color LCD"

local current_screen_name = hs.screen.mainScreen():name()

-- Handles desktop set up if I'm using one monitor or two
if current_screen_name == display_desktop_main or lastNumberOfScreens == 2 then
    spoon.SystemContexts:moveDockDown()
-- If I'm only using one monitor and it's laptop, then move that dock
elseif current_screen_name == display_laptop and lastNumberOfScreens == 1 then
    spoon.SystemContexts:moveDockLeft()
end

----------------------------------------------------------
-- /end of WHY IS THIS HERE?
----------------------------------------------------------

hs.hotkey.bind(alt, 'space', hs.grid.maximizeWindow)

hs.hotkey.bind(hyper, "H", function()
    hs.hints.windowHints()
end)

------------------------------------------------------------------------------
-- Layout stuff
-- http://larryhynes.net/2015/02/switching-from-slate-to-hammerspoon.html
------------------------------------------------------------------------------
-- Not very DRY but simple to understand and one of the first things I
-- wrote for hammerspoon
------------------------------------------------------------------------------
-- Moves window to left half of screen
hs.hotkey.bind(hyper, "left", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    f.x = max.x
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h
    win:setFrame(f)
end)

-- Moves window/sets width to right half of screen
hs.hotkey.bind(hyper, "right", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    f.x = max.x + (max.w / 2)
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h
    win:setFrame(f)
end)

-- Moves window to right, sets to 1/4 width
hs.hotkey.bind(mash, "right", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    f.x = max.x + (max.w * 0.75)
    f.y = max.y
    f.w = max.w * 0.25
    f.h = max.h
    win:setFrame(f)
end)

--Moves window to left, sets to 3/4 width
hs.hotkey.bind(mash, "left", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    f.x = max.x
    f.w = max.w * 0.75
    f.h = max.h
    f.y = max.y
    win:setFrame(f)
end)

hs.hotkey.bind(mash, "N", function()
    hs.grid.maximizeWindow()
    hs.grid.pushWindowNextScreen()
end)

hs.hotkey.bind(mash, 'N', hs.grid.pushWindowNextScreen)
hs.hotkey.bind(mash, 'P', hs.grid.pushWindowPrevScreen)

function kirby()
    test = hs.alert.show(" ¯\\_(ツ)_/¯ ", alerts_nobg, 1.5)
    hs.pasteboard.setContents("¯\\_(ツ)_/¯")
end

hs.hotkey.bind(mash, 'K', kirby)

