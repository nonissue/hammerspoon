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
-- require('apw-lib')
require('init-plugins')

apw_go({
  "apps.utilities",
  "apps.hammerspoon_config_reload",
  "apps.hammerspoon_toggle_console",
  "apps.change_resolution",
  "battery.burnrate",
  "skunkworks.demomodal",
  "skunkworks.kellan",
  -- "skunkworks.redshift",
  -- "skunkworks.capslockfix",
})

-- init grid
hs.grid.MARGINX         = 0
hs.grid.MARGINY         = 0
hs.grid.GRIDWIDTH       = 7
hs.grid.GRIDHEIGHT      = 7

-- disable animation
hs.window.animationDuration = 0

---------
-- Vars
---------
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

hs.hotkey.bind(mash, 'N', hs.grid.pushWindowNextScreen)
hs.hotkey.bind(mash, 'P', hs.grid.pushWindowPrevScreen)

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- SAFARI STUFF STARTS
------------------------------------------------------------------------------
-- cycle_safari_agents
------------------------------------------------------------------------------
-- Taken from: http://www.hammerspoon.org/go/#applescript
-- modified to toggle between iOS and default
-- Useful for sites that insist on flash installations
-- Tricking them into thinking device is mobile is

-- This is pretty brittle (it breaks when safari is updated)
-- and I do it largely to force sites to present
-- HTML5 video when flash is offered by default
--
-- Probably a better way to do it.
------------------------------------------------------------------------------
function cycle_safari_agents()
  hs.application.launchOrFocus("Safari")
  local safari = hs.appfinder.appFromName("Safari")

  local str_default = {"Develop", "User Agent", "Default (Automatically Chosen)"}
  local str_iPad = {"Develop", "User Agent", "Safari — iOS 10 — iPad"}

  local default = safari:findMenuItem(str_default)
  local iPad = safari:findMenuItem(str_iPad)

  if (default and default["ticked"]) then
    safari:selectMenuItem(str_iPad)
    hs.alert.show("iPad")
  end
  if (iPad and iPad["ticked"]) then
    safari:selectMenuItem(str_default)
    hs.alert.show("Default")
  end
end

hs.hotkey.bind({"cmd", "alt", "ctrl"}, '7', cycle_safari_agents)

------------------------------------------------------------------------------
-- mailToSelf
------------------------------------------------------------------------------
-- Gets current url from active safari tab and mails it to specified address
------------------------------------------------------------------------------
function mailToSelf()
  script = [[
    tell application "Safari"
    set currentURL to URL of document 1
    end tell
    return currentURL
  ]]

ok, result = hs.applescript(script)
if (ok) then
  hs.applescript.applescript([[
    tell application "Safari"
    set result to URL of document 1
    end tell
    tell application "Mail"
    set theMessage to make new outgoing message with properties {subject: "MTS: " & result, content:result, visible:true}
    tell theMessage
    make new to recipient with properties {name:"Mail to Self", address:"hammerspoon@nonissue.org"}
    send
    end tell
    end tell
  ]])
hs.alert("Page successfully emailed to self")
end
end

-- mails current url to myself using mailtoself function
hs.hotkey.bind(mash, 'U', mailToSelf)

------------------------------------------------------------------------------
-- tabToNewWindow
------------------------------------------------------------------------------
-- makes new window from current tab in safari
-- could maybe send it to next monitor immediately if there is one?
------------------------------------------------------------------------------
function tabToNewWindow()
  hs.application.launchOrFocus("Safari")
  local safari = hs.appfinder.appFromName("Safari")

  local target_item_in_menu = {"Window", "Move Tab to New Window"}
  safari:selectMenuItem(target_item_in_menu)

  hs.alert.show("making new window from tab")
end

hs.hotkey.bind(mash, 'T', tabToNewWindow)

------------------------------------------------------------------------------
-- mergeAllWindows
------------------------------------------------------------------------------
-- Merges all separate windows into one window
------------------------------------------------------------------------------
function mergeAllWindows()
  hs.application.launchOrFocus("Safari")
  local safari = hs.appfinder.appFromName("Safari")

  local target_item_in_menu = {"Window", "Merge All Windows"}
  safari:selectMenuItem(target_item_in_menu)

  hs.alert.show("Merging all windows")
end

hs.hotkey.bind(mash, 'M', mergeAllWindows)

------------------------------------------------------------------------------
-- pinOrUnpinTab
------------------------------------------------------------------------------
-- Pins or unpins current tab
------------------------------------------------------------------------------
function pinOrUnpinTab()
  hs.application.launchOrFocus("Safari")
  local safari = hs.appfinder.appFromName("Safari")

  local pin_tab = {"Window", "Pin Tab"}
  local unpin_tab = {"Window", "Unpin Tab"}

  if (safari:findMenuItem(pin_tab)) then
    hs.alert.show("Pinning current tab")
    safari:selectMenuItem(pin_tab)
  else
    hs.alert.show("Unpinning current tab")
    safari:selectMenuItem(unpin_tab)
  end
end

hs.hotkey.bind(mash, 'P', pinOrUnpinTab)

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
  -- notify("OnLocation:", "Home settings enabled")
  hs.alert("Home settings enabled!", 1)
  -- TODO: set audiodevice to speakers
end

-- sets displaysleep to lowervalue
-- eventually should unmount disks and perform other functions?
function home_departed()
  -- set volume to 0
  hs.audiodevice.defaultOutputDevice():setMuted(true)
  os.execute("sudo pmset -a displaysleep 1 sleep 15")
  notify("OnLocation: ", "Away settings enabled")
  hs.alert("Away settings enabled!", 1)
end

wifiWatcher = hs.wifi.watcher.new(ssidChangedCallback)
wifiWatcher:start()

if hs.wifi.currentNetwork() == "BROMEGA-5G" or hs.wifi.currentNetwork() == "BROMEGA" or hostName == "iMac" then
  home_arrived()
else
  home_departed()
end
