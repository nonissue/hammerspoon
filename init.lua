------------------------------------------------------------------------------
-- VERY VERY early hammerspoon init.lua
------------------------------------------------------------------------------
-- By: Andrew Williams / andy@nonissue.org
------------------------------------------------------------------------------
-- Haven't done much of anything, most of it is just experimenting
-- If you have concerns (about my sanity or anything else) feel free to
-- email me at the above address
------------------------------------------------------------------------------


-- General Utilities


hs.hotkey.bind({"cmd", "alt", "ctrl"}, "H", function()
  hs.notify.new({title="Hammerspoon", informativeText="Hello World!"}):send()
end)


function print_table(t)
   for k, v in pairs(t) do
      print(k, v)
   end
end


-- can be used to print out tables and subtables
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

-- screen watcher, since this is used on multiple computers

---------
-- Vars
---------

-- var for hyper key and mash
-- SWITCHING THESE ON SEPT 16 2015. Previously MASH was HYPER.
-- Doesn't make any sense though both in terms of naming and use.
local mash = {"cmd", "alt", "ctrl"}
local hyper = {"cmd", "alt"}
local alt = {"alt"}

------------------------------------------------------------------------------
-- NOTE
------------------------------------------------------------------------------
-- Not currently implemented, need to write coniditonal for different
-- computers since, I use two with different display set ups
------------------------------------------------------------------------------
-- var representing display name (this is name of MBP internal display)
local display_laptop = "Color LCD"
-- default window layouts for notebook
local notebook = {   
   {"Safari",            nil,          display_laptop, hs.layout.maximized, nil, nil},
   {"OmniFocus",         nil,          display_laptop, hs.layout.maximized, nil, nil},
   {"Mail",              nil,          display_laptop, hs.layout.maximized, nil, nil},
   {"Slack",             nil,          display_laptop, hs.layout.maximized, nil, nil},
   {"1Password",         nil,          display_laptop, hs.layout.maximized, nil, nil},
   {"Calendar",          nil,          display_laptop, hs.layout.maximized, nil, nil},
   {"Messages",          nil,          display_laptop, hs.layout.maximized, nil, nil},
   {"Evernote",          nil,          display_laptop, hs.layout.maximized, nil, nil},
   {"Emacs",             nil,          display_laptop, hs.layout.maximized, nil, nil},
   {"iTunes",            "iTunes",     display_laptop, hs.layout.maximized, nil, nil},
}
-- default windows layouts for desktop (dual monitor)
-- layouts go here
local display_desktop_main  = "DELL P2815Q"
local display_desktop_aux   = "DELL U2312HM"
local desktop = {   
   {"Safari",            nil,          display_desktop_main, hs.layout.maximized, nil, nil},
   {"OmniFocus",         nil,          display_desktop_aux,  hs.layout.maximized, nil, nil},
   {"Slack",             nil,          display_desktop_aux,  hs.layout.maximized, nil, nil},
   {"Calendar",          nil,          display_desktop_aux,  hs.layout.maximized, nil, nil},
   {"Evernote",          nil,          display_desktop_aux,  hs.layout.maximized, nil, nil},
   {"Emacs",             nil,          display_desktop_main, hs.layout.maximized, nil, nil},
   {"iTunes",            "iTunes",     display_desktop_aux,  hs.layout.maximized, nil, nil},
   {"Fantastical",       nil,          display_desktop_aux,  hs.layout.maximized, nil, nil},
   {"Postbox",           nil,          display_desktop_aux,  hs.layout.maximized, nil, nil},
   {"Messages",          nil,          display_desktop_aux,  hs.layout.maximized, nil, nil}
}

-- /not done
------------------------------------------------------------------------------
-- sets default? This is controlled by function much lower down?
hs.layout.apply(desktop)

-- layouts invoked by hotkey
hs.hotkey.bind(alt, 'space', hs.grid.maximizeWindow)
hs.hotkey.bind(hyper, "H", function()
      hs.hints.windowHints()
end)


-- snaps current window to grid
-- Not really using grid-based layout currently so disabled
-- hs.hotkey.bind(hyper, 'M', function() hs.grid.snap(hs.window.focusedWindow()) end)

-- taken from
-- http://larryhynes.net/2015/02/switching-from-slate-to-hammerspoon.html
-- a little too verbose for my liking, but simple enough to understand
-- moves window to left half of screen
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
-- moves window/sets width to right half of screen
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
-- These two I modified for my own use
-- moves window to right, sets to 1/4 width
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

-- moves window to left, sets to 3/4 width
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
-- There is redunancy in the code above which I intend to eliminate, but
-- below is a vastly more complicated way of managing windows/positioning
-- that I never finished
--
-- It is largely taken from mgee (github.com/mgee) though it uses OOP,
-- which though it is more flexible and polymorphic, is vastly more
-- complicated and not necessary for most use cases and for what I want
-- I may return to this in future.
------------------------------------------------------------------------------
local resizeCurrentWindow = function (w, h)
   local win = hs.window.focusedWindow()
   local f = win:frame()
   local screen = win:screen()
   local max = screen:frame()
   f.w = max.w * w
   f.h = max.h * h
   return function()
      win:setFrame(f)
   end
end

function adjustWindow(win)
   return function ()
      local win = hs.window.focusedWindow()
      moveRight(win)
   end
end

function moveRight(win)
   local q = win:frame()
   local screen = win:screen()
   local screenFrame = win:screen():frame()
   if screen:frame().x < 0 then
      currentW = 0 - q.w
   elseif screen.frame().x > 0 then
      currentW = screen:frame().w - q.w
   end
   local newFrame = {
      y = screen:frame().y,
      x = currentW,
      w = screen:fullFrame().w * 0.25,
      h = screen:fullFrame().h
   }
   win:setFrame(newFrame)
end

local desktopResolutions = {
   {w = 1920, h = 1080, s = 1},
   {w = 2048, h = 1152, s = 2},
   {w = 2304, h = 1296, s = 2},
   {w = 2560, h = 1440, s = 2}
}

local charsTest = {"1","2","3","4","5", "6"}

function setupModal()
   k = hs.hotkey.modal.new('cmd-alt', 'r')
   k:bind('', 'escape', function() hs.alert.closeAll() k:exit() end)
   function k:entered()
      hs.alert('1: 1980 / 2: 2048 / 3: 2304 / 4: 2560 / ESC: exit', 30)
   end
   function k:exited()
      hs.alert('no longer setting resolution!', 5)
      hs.alert.closeAll()
   end
   for _, c in ipairs(charsTest) do
      k:bind({}, c, function () processKey(c) end)
   end
   
   -- for i = 1, #desktopResolutions do
      -- print (i)
      -- k:bind({}, i, function() processKey(i) end)
   -- end
   -- need to iterate through key binding here, and call processkey, which
   -- should change res
   -- changeResolution()
end

-- desktop resolutions in form {w, h, scale} to be passed to setMode

-- print_r(desktopResolutions[1])
-- print(desktopResolutions[1]['w'])

function processKey(i)
   res = desktopResolutions[tonumber(i)]
   hs.alert("Setting resolution to: " .. res.w .. " x " .. res.h, 5)
   changeRes(res.w, res.h, res.s)
   k:exit()
   print(desktopResolutions[tonumber(i)])
   print_r(desktopResolutions[tonumber(i)])
end

setupModal()

-- function displayResolutions(currentWidth, resolutions)
--    -- print("display res called!")
--    local c = 1
--    for i = 1, #resolutions do
--       print("reg for loop from display")
--       print("i: ", i)
--       local res = resolutions[i]
--       if res['w'] ~= currentWidth then
--          hs.alert(tostring(c) .. ": " .. tostring(res.w))
--          -- hs.alert(res.w, res.h, res.s)
--          print(res.w, res.h, res.s)
--          -- print(i)
--          -- print(type(c))
--          k:bind({}, c, function() changeResProcessKey(res.w, res.h, res.s) end)
--          c = c + 1
--          print(c)
--       else
--          print("-------")
--          print("omitting current resolution from list: ")
--          print(res.w, res.h, res.s)
--          print("-------")
--       end
--    end
-- end



-- function changeResolution()

--    local screen = hs.screen.primaryScreen()
--    if screen:name(screen) == "DELL P2815Q" then
--       -- print(screen:currentMode().w)
--       displayResolutions(screen:currentMode().w, desktopResolutions)
--    end
-- end


function changeRes(w, h, s)
   print("SETTING THIS SHIT!")
   hs.screen.primaryScreen():setMode(w, h, s)
end


-- setupModal()
-- function resolution.setupModal()


--   for _, c in ipairs(hints.hintChars) do
--     k:bind({}, c, function() hints.processChar(c) end)
--   end
--   return k
-- end


-- function k:entered() changeResolution() end
-- function k:exited() hs.alert'Exited mode' end
-- k:bind('', 'escape', function()
--           hs.alert.closeAll()
--           k:exit() end)
-- k:bind('', 'J', 'Pressed J',function() print'let the record show that J was pressed' end)
      

-- Gets current url from active safari tab
function mailToSelf()
    script = [[
    tell application "Safari"
        set currentURL to URL of document 1
    end tell
    return currentURL
    ]]
    ok, result = hs.applescript(script)
    if (ok) then
       -- hs.eventtap.keyStrokes(result)
       hs.applescript.applescript([[
        tell application "Safari"
            set result to URL of document 1
        end tell
        tell application "Mail"
             set theMessage to make new outgoing message with properties {subject:result, content:result, visible:true}
             tell theMessage
                  make new to recipient with properties {name:"Andrew Williams", address:"hammerspoon@nonissue.org"}
                  send
             end tell
        end tell
        ]])
        -- hs.eventtap.keyStrokes(result)
    end
end


-- mails current url to myself using mailtoself function
hs.hotkey.bind(mash, 'U', mailToSelf)

-- makes new window from current tab in safari
function tab_to_new_window()
   hs.application.launchOrFocus("Safari")
   local safari = hs.appfinder.appFromName("Safari")
   
   local target_item_in_menu = {"Window", "Move Tab to New Window"}
   safari:selectMenuItem(target_item_in_menu)
   
   hs.alert.show("making new window from tab")
end

hs.hotkey.bind(mash, 'T', tab_to_new_window)



-- functions for different locations
-- configure things like drive mounts, display sleep (for security), etc.

-- sets displaysleep to 90 minutes if at home
-- should be called based on ssid
-- not the most secure since someone could fake ssid I guess
-- might want some other level of verification

function home_arrived()
         -- requires modified sudoers file
         -- andrewwilliams ALL=(root) NOPASSWD: pmset -b displaysleep *
   os.execute("sudo pmset -b displaysleep 90")
   -- set audiodevice to speakers
end

-- sets displaysleep to lowervalue
-- eventually should unmount disks and perform other functions?
function home_departed()
         -- set volume to 0?
   os.execute("sudo pmset -a displaysleep 1 sleep 15")
end


-- currently unnecessary
-- function getGrid(win)
--    local winFrame = win:frame()
--    local screenFrame = win:screen():frame()
--    return {
--       x = screenFrame.x,
--       y = screenFrame.y,
--       w = screenFrame.w,
--       h = screenFrame.h
--    }
-- end
-- end of necessary

-- this is cool
numberOfScreens = #hs.screen.allScreens()
if numberOfScreens == 1 then
   hs.layout.apply(notebook)
   print("notebook layout applied")
elseif numberOfScreens == 2 then
   hs.layout.apply(desktop)
   print("desktop layout applied")
end
    
function reload_config(files)
   hs.reload()
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/init.lua", reload_config):start()
hs.alert.show("Config loaded")
