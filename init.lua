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
spoon.SystemContexts:moveDockLeft()
-- spoon.SystemContexts:moveDockBottom()
-- spoon.AClock:toggleShow()
-- hs.loadSpoon("CircleClock")
-- spoon.CircleClock:start()
-- hs.spoons.isLoaded(spoon.AClock)
-- AClock:start()

-- require 'sleeptimer'
-- require 'DemoChooser'

-- DemoChooser.new()

apw_go({
  "apps.utilities",
  "apps.hammerspoon_config_reload",
  "apps.hammerspoon_toggle_console",
  "DemoChooser",
  "apps.change_resolution",
  -- "battery.burnrate",
  -- "sounds.sounds",
  -- "apps.btc_menu",
})


-- hs.spoons.isLoaded(AClock)
-- hs.spoons.isInstalled("AClock")
---------
-- Changing hs.notify contentImage test
------------------------------------------------------------------------------
-- Started playing with hs.notify images
-- all files in media folder taken from https://github.com/scottcs/dot_hammerspoon
------------------------------------------------------------------------------
local wifiicon = hs.image.imageFromPath('media/Misc Assets/airport.png')

-- init grid
hs.grid.MARGINX         = 0
hs.grid.MARGINY         = 0
hs.grid.GRIDWIDTH       = 10
hs.grid.GRIDHEIGHT      = 10

-- disable animation 
hs.window.animationDuration = 0

---------
-- Vars
------------------------------------------------------------------------------
-- var for hyper key and mash
-- SWITCHING THESE ON SEPT 16 2015. Previously MASH was HYPER.
-- Doesn't make any sense though both in terms of naming and use.
local mash =    {"cmd", "alt", "ctrl" }
local hyper =   {"cmd", "alt"         }
local alt =     {"alt"                }

local display_laptop = "Color LCD"

local notebook = {
  {"Safari",            nil,          display_laptop, hs.layout.maximized, nil, nil},
  {"2Do",               nil,          display_laptop, hs.layout.maximized, nil, nil},
  {"Mail",              nil,          display_laptop, hs.layout.maximized, nil, nil},
  {"Slack",             nil,          display_laptop, hs.layout.maximized, nil, nil},
  {"1Password",         nil,          display_laptop, hs.layout.maximized, nil, nil},
  {"Messages",          nil,          display_laptop, hs.layout.maximized, nil, nil},
  {"iTunes",            "iTunes",     display_laptop, hs.layout.maximized, nil, nil},
}

-- These are no longer correct display names
-- Also, I no longer have a second monitor for this computer
-- Both these monitors are gone...
local display_desktop_main = "Acer B286HK"

local desktop = {
  {"2Do",               nil,          display_desktop_aux,  hs.layout.maximized, nil, nil},
  {"Slack",             nil,          display_desktop_aux,  hs.layout.maximized, nil, nil},
  {"Emacs",             nil,          display_desktop_main, hs.layout.maximized, nil, nil},
  {"Dash",              nil,          display_desktop_aux,  hs.layout.left75,    nil, nil},
  {"iTunes",            "iTunes",     display_desktop_aux,  hs.layout.maximized, nil, nil},
  {"Fantastical",       nil,          display_desktop_aux,  hs.layout.maximized, nil, nil},
  {"Messages",          nil,          display_desktop_aux,  hs.layout.maximized, nil, nil}
}

local numberOfScreens = #hs.screen.allScreens()
local current_screen_name = hs.screen.mainScreen():name()

-- I don't really think I care about this anymore?
-- disabling to see if I care
if current_screen_name == display_desktop_main then
  -- hs.layout.apply(desktop)
elseif current_screen_name == display_laptop then
  -- hs.layout.apply(notebook)
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

function alert_repeat(text, style, interval, start, stop)
  -- kind of a cool little affect, not sure if i love it 
  -- but i can kind of tile alerts overthemselves
  -- another idea would be to have variable sizes using some random 
  -- gen for alert style table
  hs.alert.closeAll()
  local cur_dur = start
  for i=start,stop,interval do
    cur_dur = cur_dur + interval
    hs.alert.show(text, style, cur_dur)
  end
end
-- test1 = hs.alert.show("BR𝛀", alerts_nobg, 1.5)
-- alert_repeat("BR𝛀", alerts_nobg, 0.2, 1, 3)

function alert_test()
  -- Attemtpign to figure out the padding problem with 
  -- hs.alerts.
  local test_string = " test ⌂ "
  local test_color = {red=255/255,blue=120/255,green=120/255,alpha=1}
  local text_style = hs.styledtext.new(test_string, { font = { size=80 }, color=test_color })
  print_r(text_style)
  local text_style1 = hs.styledtext.new(
    test_string,
      {
        font={size=14},
        color=test_color,
        -- paragraphStyle={alignment="left"}
      }
    )
  
  local test_alert_style = {
    fillColor = { white = 0, alpha = 0.2}, 
    -- radius = 60, 
    strokeColor = { white = 0, alpha = 0.2 }, 
    strokeWidth = 10, 
    -- textSize = 55, 
    -- textColor = { white = 0, alpha = 1}, 
    textStyle = text_style,
  }

  hs.alert.show(" ⌂ ", test_alert_style, 3)
end

------------------------------------------------------------------------------
-- End of safari stuff
------------------------------------------------------------------------------


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
local homeSSID = "BROMEGA-5G"
local homeSSID5G = "BROMEGA"
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
  os.execute("sudo pmset -a displaysleep 1 sleep 15")
  hs.alert.show("Away Settings Enabled", alerts_nobg, 0.7)
  -- new leave home alert
  hs.alert.show("☛ ≠ ⌂", alerts_nobg, 1.5)
  
end

wifiWatcher = hs.wifi.watcher.new(ssidChangedCallback)  
wifiWatcher:start()

if hs.wifi.currentNetwork() == "BROMEGA-5G" or hs.wifi.currentNetwork() == "BROMEGA" or hostName == "iMac" then
  home_arrived()
else
  home_departed()
end
