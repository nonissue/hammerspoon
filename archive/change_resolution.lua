------------------------------------------------------------------------------
-- ChangeResolution
------------------------------------------------------------------------------
-- Modal hotkey to change a monitors resolution
-- Also includes basic menu bar item, which is dynamically generated
-- You do have to set the resolutions you want manually, and if
-- you have multiple computers, you'll have to apply the layouts
-- appropriately
--
-- [x] should make this it's own extension/file
-- [ ] insure val in menu == actual val (on startup they differ sometimes)
-- [ ] Fix redundant logic and simplify code.
-- [ ] Delineate code between dropdown menu and actual modal and actual logic
-- [ ] Doesn't work on both monitors if using two
-- [ ] Not a true modal... fix that
------------------------------------------------------------------------------
local mod = {}

local obj = {} -- obj
obj.__index = obj

-- acerChooser.chooser = nil
obj.acerChooser = nil

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
  {w = 2048, h = 1152, s = 2},
  {w = 2304, h = 1296, s = 2},
  {w = 2560, h = 1440, s = 2}
}

local acer4kres = {
  -- first 1920 is for retina resolution @ 30hz
  -- might not be neede as 2048 looks pretty good
  {w = 1920, h = 1080, s = 2},
  {w = 2048, h = 1152, s = 2},
  {w = 2304, h = 1296, s = 2},
  {w = 2560, h = 1440, s = 2}
}

local cinemaDisplay = {
  -- first 1920 is for retina resolution @ 30hz
  -- might not be neede as 2048 looks pretty good
  {w = 1920, h = 1080, s = 2},
  {w = 2048, h = 1152, s = 2},
  {w = 2304, h = 1296, s = 2},
  {w = 2560, h = 1440, s = 2}
}


-- initialize variable to ultimately store the correct set of resolutions
local resolutions = {}
local choices = {}
local dropdownOptions = {}

-- probably should set up a watcher to update this?
-- just create a watcher that makes sure that acer gets set to 1920x1080?



--[1] Cinema HD - ID 69489838
--[2] Acer B286HK - ID 478199161

local displayCount = #hs.screen.allScreens()

---------------------------------------------------------------------------
-- some dumb late night refactoring below
---------------------------------------------------------------------------

function obj:acerCallback(choice)
  if choice['id'] == 1 then
    -- seems to have fixed the binding problem [FIXED?]
    local frontmostURL = obj:getURL()
    hs.osascript.applescript(privateBrowsing)
    obj:setURL(frontmostURL)
  elseif choice['id'] == 2 then
    obj:bust(choice['baseURL'])
  elseif choice['id'] == 3 then
    obj:bust(choice['baseURL'])
  elseif choice['id'] == 4 then
    obj:bust(choice['baseURL'])
  elseif choice['id'] == 5 then
    obj:bust(choice['baseURL'])
  else
    local URL = self.chooser:query()
    obj:createCustom(URL)
  end
end

function obj:init()

  self.acerChooser = hs.chooser.new(
    function(choice)
      if not (choice) then
        print(self.acerChooser:query())
        self.acerChooser:hide()
      else
        self.acerChooser:acerCallback(choice)
      end
  end)

  self.acerChooser:choices(acer4kres)
  self.acerChooser:rows(#acer4kres)

  self.acerChooser:queryChangedCallback(function(query)
    if query == '' then
      self.acerChooser:choices(acer4kres)
    else
      local choices = {
        {["id"] = 0, ["text"] = "Custom", subText="Enter a custom resolution that basically won't work"},
      }
      self.acerChooser:choices(choices)
    end
  end)

  self.acerChooser:width(20)
  self.acerChooser:bgDark(false)

  return self
end

function obj:show()
  self.acerChooser:show()
  return self
end

function obj:start()
  print("-- Starting acerChooser")
  return self
end

function obj:stop()
  print("-- Stopping PaywallBuster")
  self.acerChooser:hide()
  if self.hotkeyShow then
      self.hotkeyShow:disable()
  end
  return self
end

-- hs.hotkey.bind(mash, "i", function()
--   obj:start()
--   obj:show()
--   print("Show?")
-- end)


---------------------------------------------------------------------------
-- some dumb late night refactoring above
---------------------------------------------------------------------------

function screenWarden()
  if hs.screen.find("acer") then
    -- hs.screen.find("acer"):setMode(1920, 1080, 2)

    -- hs.alert("Acer Res Set", alerts_medium, 5)
  elseif hs.screen.find(69489838) then
    hs.screen.find(69489838):setMode(2560, 1600, 1)
    hs.alert("Cinema Res Set", alerts_medium, 5)
  end
end

local screens = hs.screen.allScreens()
local screenwatcher = hs.screen.watcher.new(screenWarden)
screenwatcher:start()

-- if displayCount == 1 then
--   if hs.screen.primaryScreen() == "Color LCD" then
--     resolutions = laptopResolutions

local resIcons = {
  "-⃞", -- 1440 / should be: - ⃞ (- in a square)"
   "⃞", -- DEFAULT / just the square 
  "+⃞", -- 1920 / square with plus sign in it
}

local res_color = {red=1,blue=1,green=1,alpha=1} -- Default?
-- local res_color2 = {red=255/255,blue=50/255,green=0/255,alpha=1}
local real_color = {hex = "#ff0000", alpha = 1} -- light red?

-- SYSTEM CONTEXTS LOGIC
-- Must set hostname in System Prefs -> Sharing to "iMac" or "apw@me.com"
-- find out which set we need
if hs.screen'acer' then
  resolutions = desktopResolutions
else
  resolutions = laptopResolutions
end



-- configure the modal hotkeys
-- has some entered/exit options, mainly to show/hide available options on
-- entry/exit
function setupResModal()
  k = hs.hotkey.modal.new('cmd-alt-ctrl', 'l')
  k:bind('', 'escape', function() hs.alert.closeAll() k:exit() end)
  -- Hide / Show Resolution menu

  -- if config is reloaded, it doesn't delete previously hidden instance properly.
  -- k:bind('', 'm', function() menuBarToggle() k:exit() end)
  
  -- choices table is for storing the widths to display with hs.alert later
  -- this is necessary because possible resolutions vary based on display
  for i = 1, #resolutions do
    -- inserts resolutions width in to choicesXZLhd table so we can iterate through them easily later
    table.insert(choices, resolutions[i].w)
    -- also creates a table to pass to init our dropdown menu with menuitem title and callback (this is fucking ugly)
    local titlestr = tostring(choices[i])
    -- currently not styling text, since it's easier to just manipulate the string in other places
    -- like toggle checked
    local styledtitle = hs.styledtext.new(
      titlestr,
      {
        font={size=14},
        color=res_color,
        paragraphStyle={alignment="right"},
        -- backgroundColor = res_color,
      }
    )
    -- table.insert(dropdownOptions, {title = styledtitle, fn = function() return processKey(i) end, checked = false })
    k:bind({}, tostring(i), function () processKey(i) end)
  end

  -- function to display the choices as an alert
  -- called on hotkey modal entry
  function displayChoices()
    hs.alert("1: Smaller / 2: Normal / 3: Bigger / ESC: cancel", alerts_medium, 5)
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
  -- would be cool to check the menu bar option that is currently seleted,
  -- but it seems like a bit of a pain in the ass, because I think I'dc have to reinitialize
  -- all the menubar items, since I'd have to change check to false for current,
  -- and true for new selection
  local res = resolutions[tonumber(i)]
  -- local icon = resIcons[tonumber(i)]
  -- local menuTitle = hs.styledtext.new(
  --   -- resIcons[tonumber(i)],
  --   resIcons[1],
  --   {
  --     -- font = { size = 18 },-- + ((i - 1) * 2) }, -- resize icon based on screenres
  --   }
  -- )
  setResolutionDisplay(resIcons[tonumber(i)])
  changeRes(res.w, res.h, res.s)
  hs.alert.closeAll()

  k:exit()
end

-- desktop resolutions in form {w, h, scale} to be passed to setMode
function changeRes(w, h, s)
  hs.screen.primaryScreen():setMode(w, h, s)
end

setupResModal()

------------------------------------------------------------------------------
-- Declaration of menubar:
------------------------------------------------------------------------------

-- Menubar items sometimes hang around after config reload creating dupes
-- So this makes sure they are removed

-- Initializes a menubar item that displays the current resolution of display
-- And when clicked, toggles between two most commonly used resolutions
local resolutionMenu = hs.menubar.new()

-- superfluous
function toggleChecked(items, target)
  for k, v in pairs(items) do -- for every element in the table
    if v['title']:getString() == tostring(target) then
      v['checked'] = true
    else
      v['checked'] = false
    end
    print_r(v)
  end
end

-- superflous
function getIcon(items, w)
  for i = 1, #items do
    if items[i]['title']:getString() == w then
      return resIcons[i]
    end
  end
end

-- sets title to be displayed in menubar (really doesn't have to be own func?)
function setResolutionDisplay(w)
    local menuTitle = hs.styledtext.new(
    w,
    {
      font = { size = 18 },-- + ((i - 1) * 2) }, -- resize icon based on screenres
    }
  )
  resolutionMenu:setTitle(menuTitle)
end

-- superfluous
function menuBarToggle()
  if resolutionMenu:isInMenubar() then
    resolutionMenu:removeFromMenuBar()
  elseif not resolutionMenu:isInMenubar() then
    resolutionMenu:returnToMenuBar()
  else
    hs.alert("Res Menu Error!")
  end
end

-- superfluous
function showResolutionMenu()
  resolutionMenu:returnToMenuBarw()
end

function mod.init()
  local currentRes = hs.screen.primaryScreen():currentMode().w

  -- local menuTitle = hs.styledtext.new(
  --   resIcons[2],
  --   {
  --     font={ size = 18 },
  --   }
  -- )
    setResolutionDisplay(resIcons[2])
end

return mod, obj