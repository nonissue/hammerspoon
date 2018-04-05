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

hs.loadSpoon("AClock")
hs.loadSpoon("SystemContexts")
hs.loadSpoon("SafariKeys")
hs.loadSpoon("Countdown")
hs.loadSpoon("SysInfo")

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

local safariHotkeys =  {
	tabToNewWin = {mash, "T"},
	mailToSelf = {mash, "U"},
	mergeAllWindows = {mash, "M"},
	pinOrUnpinTab = {hyper, "P"},
	cycleUserAgent = {mash, "7"},
}

spoon.SafariKeys:bindHotkeys(safariHotkeys)

apw_go({
  "apps.utilities",
  "apps.hammerspoon_config_reload",
  "apps.hammerspoon_toggle_console",
  "apps.change_resolution",
  -- "battery.burnrate",
  -- "sounds.sounds",
  -- "apps.btc_menu",
})

-- init grid
hs.grid.MARGINX         = 0
hs.grid.MARGINY         = 0
hs.grid.GRIDWIDTH       = 10
hs.grid.GRIDHEIGHT      = 10

-- disable animation 
hs.window.animationDuration = 0

local display_laptop = "Color LCD"

local numberOfScreens = #hs.screen.allScreens()
local current_screen_name = hs.screen.mainScreen():name()

-- Handles desktop set up if I'm using one monitor or two
if current_screen_name == display_desktop_main or numberOfScreens == 2 then
  spoon.SystemContexts:moveDockDown()
-- If I'm only using one monitor and it's laptop, then move that dock
elseif current_screen_name == display_laptop and numberOfScreens == 1 then
	spoon.SystemContexts:moveDockLeft()
end

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

------------------------------------------------------------------------------
-- Location based functions to change system settings
------------------------------------------------------------------------------
-- functions for different locations
-- configure things like drive mounts, display sleep (for security), etc.
-- sets displaysleep to 90 minutes if at home
-- should be called based on ssid
-- not the most secure since someone could fake ssid I guess
-- might want some other level of verification-- makes new window from current tab in safari
-- could maybe send it to next monitor immediately if there is one?
-- differentiate between settings for laptop vs desktop
-- Mostly lifted from:
-- https://github.com/cmsj/hammerspoon-config/blob/master/init.lua
------------------------------------------------------------------------------
-- Don't love the logic of how this is implemented
-- If computer is in between networks (say, woken from sleep in new location)
-- Then desired settings like volume mute are not applied until after a delay
-- Maybe implement a default setting that is applied when computer is 'in limbo'
local homeSSID = "ComfortInn VIP"
-- local homeSSID5G = "BROMEGA"
local schoolSSID = "MacEwanSecure"
local lastSSID = hs.wifi.currentNetwork()
local hostName = hs.host.localizedName()

function ssidChangedCallback()
  newSSID = hs.wifi.currentNetwork()

  if (newSSID == homeSSID or newSSID == homeSSID5G) and (lastSSID ~= homeSSID) then
    -- we are at home!
    home_arrived()
  elseif newSSID ~= homeSSID and lastSSID == homeSSID then
    -- we are away from home!
    -- why do we need the validation check for lastSSID?
    -- We can infer from newSSID ~= homeSSID that we aren't home?
    home_departed()
  end

  lastSSID = newSSID
end

function home_arrived()
  -- Should really have device specific settings (desktop vs laptop)
  -- requires modified sudoers file
  -- <YOUR USERNAME> ALL=(root) NOPASSWD: pmset -b displaysleep *
  os.execute("sudo pmset -b displaysleep 5 sleep 10")
  os.execute("sudo pmset -c displaysleep 5 sleep 10")
  hs.audiodevice.defaultOutputDevice():setMuted(false)
  hs.notify.new({
        title = 'Wi-Fi Status',
        subTitle = "Home Detected",
        informativeText = "Home Settings Enabled",
        -- contentImage = wifiicon,
        autoWithdraw = true,
        hasActionButton = false,
      }):send()
  -- new arrive home alert
  hs.alert.show("☛ ⌂", alerts_nobg, 2)
  -- TODO: set audiodevice to speakers
end

-- sets displaysleep to lowervalue
-- eventually should unmount disks and perform other functions?
function home_departed()
  -- set volume to 0
  hs.audiodevice.defaultOutputDevice():setMuted(true)
  os.execute("sudo pmset -a displaysleep 1 sleep 10")
  hs.alert.show("Away Settings Enabled", alerts_nobg, 0.7)
  -- new leave home alert
  hs.alert.show("☛ ≠ ⌂", alerts_nobg, 1.5)
end

wifiWatcher = hs.wifi.watcher.new(ssidChangedCallback)  
wifiWatcher:start()

if hs.wifi.currentNetwork() == "ComfortInn VIP" or hs.wifi.currentNetwork() == "ComfortInn Guest" or hostName == "apw@me.com" then
  home_arrived()
else
  home_departed()
end
