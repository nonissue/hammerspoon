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
-- [ ] Not a true modal... fix that
------------------------------------------------------------------------------
local mod = {}

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
  {w = 1920, h = 1080, s = 1}, -- this 1920 is for non-retina @ 30hz
  {w = 2048, h = 1152, s = 2},
  {w = 2304, h = 1296, s = 2},
  {w = 2560, h = 1440, s = 2}
}

-- initialize variable to ultimately store the correct set of resolutions
local resolutions = {}
local choices = {}
local dropdownOptions = {}

local res_color = {red=1,blue=1,green=1,alpha=1} -- Default?
local res_color2 = {red=255/255,blue=120/255,green=120/255,alpha=1} -- light red?


-- Must set hostname in System Prefs -> Sharing to "iMac" or "apw@me.com"
-- find out which set we need
if hostname == "iMac" then
  resolutions = desktopResolutions
elseif hostname == "apw@me.com" then
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
    local titlestr = tostring(choices[i])
    local styledtitle = hs.styledtext.new(titlestr,{font={size=14},color=res_color,paragraphStyle={alignment="left"}})
    table.insert(dropdownOptions, {title = styledtitle, fn = function() return processKey(i) end, checked = false })
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

------------------------------------------------------------------------------
-- Declaration of menubar:
------------------------------------------------------------------------------

-- Initializes a menubar item that displays the current resolution of display
-- And when clicked, toggles between two most commonly used resolutions
local resolutionMenu = hs.menubar.new()

-- sets title to be displayed in menubar (really doesn't have to be own func?)
function setResolutionDisplay(w)
  resolutionMenu:setTitle(tostring(w))
  resolutionMenu:setMenu(dropdownOptions)
end

-- sets callback and calls settitle function
if resolutionMenu then
  local currentRes = hs.screen.primaryScreen():currentMode().w
  setResolutionDisplay(currentRes)
end

return mod
