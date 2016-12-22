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
-- [ ] Energy Activity Use Indicator for Mobile
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

require('init-plugins')

apw_go({
  "apps.hammerspoon_config_reload",
  "battery.burnrate",
})

-- I find it a little more flexible than hs.inspect for developing
function print_r ( t )
  local print_r_cache={}
  local function sub_print_r(t,indent)
    if (print_r_cache[tostring(t)]) then
      print(indent.."*"..tostring(t))
    else
      print_r_cache[tostring(t)]=true
      if (type(t)=="table") then
        for pos,val in pairs(t) do
          if (type(val)=="table") then
            print(indent.."["..pos.."] => "..tostring(t).." {")
            sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
            print(indent..string.rep(" ",string.len(pos)+6).."}")
          elseif (type(val)=="string") then
            print(indent.."["..pos..'] => "'..val..'"')
          else
            print(indent.."["..pos.."] => "..tostring(val))
          end
        end
      else
        print(indent..tostring(t))
      end
    end
  end
  if (type(t)=="table") then
    print(tostring(t).." {")
    sub_print_r(t,"  ")
    print("}")
  else
    sub_print_r(t,"  ")
  end
  print()
end

-- init grid
hs.grid.MARGINX 	= 0
hs.grid.MARGINY 	= 0
hs.grid.GRIDWIDTH 	= 7
hs.grid.GRIDHEIGHT 	= 7

-- disable animation
hs.window.animationDuration = 0

---------
-- Vars
---------
-- var for hyper key and mash
-- SWITCHING THESE ON SEPT 16 2015. Previously MASH was HYPER.
-- Doesn't make any sense though both in terms of naming and use.
local mash = {"cmd", "alt", "ctrl"}
local hyper = {"cmd", "alt"}
local alt = {"alt"}

-- Self-explanatory
hs.hotkey.bind({"cmd", "alt", "ctrl"}, 'y', hs.toggleConsole)

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

print(hs.screen.mainScreen())

if current_screen_name == display_desktop_main then
  hs.layout.apply(desktop)
elseif current_screen_name == display_laptop then
  hs.layout.apply(notebook)
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
-- ChangeResolution
------------------------------------------------------------------------------
-- Modal hotkey to change a monitors resolution
-- Also includes basic menu bar item, which is dynamically generated
-- You do have to set the resolutions you want manually, and if
-- you have multiple computers, you'll have to apply the layouts
-- appropriately
--
-- [ ] should make this it's own extension/file
-- [ ] check the menu bar item corresponding to current res
------------------------------------------------------------------------------
-- possible resolutions for 15 MBPr
local laptopResolutions = {
  {w = 1440, h = 900, s = 2},
  {w = 1680, h = 1050, s = 2},
  {w = 1920, h = 1200, s = 2}
}

-- possible resolutions for 4k Dell monitor
local desktopResolutions = {
  -- first 1920 is for retina resolution @ 30hz
  -- might not be neede as 2048 looks pretty good
  {w = 1920, h = 1080, s = 2},
  {w = 1920, h = 1080, s = 1}, -- this 1920 is for non-retina @ 60hz
  {w = 2048, h = 1152, s = 2},
  {w = 2304, h = 1296, s = 2},
  {w = 2560, h = 1440, s = 2}
}

-- initialize variable to ultimately store the correct set of resolutions
local resolutions = {}
local choices = {}
local dropdownOptions = {}

-- Must set hostname in System Prefs -> Sharing to "iMac" or "apw@me.com"

-- find out which set we need
if current_screen_name == display_desktop_main then
  resolutions = desktopResolutions
elseif hs.host.localizedName() == "apw@me.com" then
  resolutions = laptopResolutions
else
  print('no resolutions available for this computer/monitor')
end

-- configure the modal hotkeys
-- has some entered/exit options, mainly to show/hide available options on
-- entry/exit
function setupResModal()
  k = hs.hotkey.modal.new('cmd-alt-ctrl', 'l')
  k:bind('', 'escape', function() hs.alert.closeAll() k:exit() end)

  -- choices table is for storing the widths to display with hs.alert later
  -- this is necessary because possible resolutions vary based on display
  for i = 1, #resolutions do
    -- inserts resolutions width in to choices table so we can iterate through them easily later
    table.insert(choices, resolutions[i].w)
    -- also creates a table to pass to init our dropdown menu with menuitem title and callback (this is fucking ugly)
    table.insert(dropdownOptions, {title = tostring(i) .. ": " .. tostring(choices[i]), fn = function() return processKey(i) end, checked = false })
    k:bind({}, tostring(i), function () processKey(i) end)
  end

  -- function to display the choices as an alert
  -- called on hotkey modal entry
  function displayChoices()
    for i = 1, #choices do
      hs.alert(tostring(i) .. ": " .. choices[i], 99)
    end
  end

  -- on modal entry, display choices
  function k:entered() displayChoices() end
  -- on model exit, clear all alerts
  function k:exited() hs.alert.closeAll() end

end

-- processes the key from modal binding
-- resolution array is also passed so we can grab the corresponding resolution
-- then calls changeRes function with hte values we want to change to
function processKey(i)
  -- would be cool to check the menu bar option that is currently selected,
  -- but it seems like a bit of a pain in the ass, because I think I'd have to reinitialize
  -- all the menubar items, since I'd have to change check to false for current,
  -- and true for new selection
  local res = resolutions[tonumber(i)]

  hs.alert("Setting resolution to: " .. res.w .. " x " .. res.h, 5)
  changeRes(res.w, res.h, res.s)

  setResolutionDisplay(res.w)

  k:exit()
end

-- desktop resolutions in form {w, h, scale} to be passed to setMode
function changeRes(w, h, s)
  hs.screen.primaryScreen():setMode(w, h, s)
end

setupResModal()

-- Initializes a menubar item that displays the current resolution of display
-- And when clicked, toggles between two most commonly used resolutions
local resolutionMenu = hs.menubar.new()

-- sets title to be displayed in menubar (really doesn't have to be own func?)
function setResolutionDisplay(w)
  resolutionMenu:setTitle(tostring(w))
  resolutionMenu:setMenu(dropdownOptions)
end

-- When clicked, toggles through two most common resolutions by passing
-- key manually to process key function

-- this is kind of flawed because logic only works on desktop
-- where it toggles between gaming mode and non-gaming mode
-- maybe just make it a dropdown?
function resolutionClicked()
  local screen = hs.screen.primaryScreen()
  if screen:currentMode().w == 1920 then
    processKey("3")
  else
    processKey("1")
  end
end

-- sets callback and calls settitle function
if resolutionMenu then
  -- resolutionMenu:setClickCallback(resolutionClicked)
  local currentRes = hs.screen.primaryScreen():currentMode().w
  setResolutionDisplay(currentRes)
end

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
-- Location based functions to change system settings (not finished)
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
  -- andrewwilliams ALL=(root) NOPASSWD: pmset -b displaysleep *
  print("home arrived!")
  os.execute("sudo pmset -b displaysleep 5 sleep 10")
  os.execute("sudo pmset -c displaysleep 5 sleep 10")
  hs.audiodevice.defaultOutputDevice():setMuted(false)
  notify("OnLocation:", "Home settings enabled")
  hs.alert("Home settings enabled!")
  -- TODO: set audiodevice to speakers
end

-- sets displaysleep to lowervalue
-- eventually should unmount disks and perform other functions?
function home_departed()
  -- set volume to 0?
  print("home departed!")
  hs.audiodevice.defaultOutputDevice():setMuted(true)
  os.execute("sudo pmset -a displaysleep 1 sleep 15")
  notify("OnLocation: ", "Away settings enabled")
  hs.alert("Away settings enabled!")
end

wifiWatcher = hs.wifi.watcher.new(ssidChangedCallback)
wifiWatcher:start()

if hs.wifi.currentNetwork() == "BROMEGA-5G" or hs.wifi.currentNetwork() == "BROMEGA" or hostName == "iMac" then
  home_arrived()
else
  home_departed()
end

-- Fancier config reloading (from hammerspoon tutorial)
-- function reloadConfig(files)
--   doReload = false
--   for _,file in pairs(files) do
--     if file:sub(-4) == ".lua" then
--       doReload = true
--     end
--   end
--   if doReload then
--     hs.reload()
--     hs.alert.show("Config loaded")
--   end
-- end
--
-- hs.pathwatcher.new(os.getenv("HOME") .. "/Dropbox/Sync/.hammerspoon", reloadConfig):start()
-- hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
