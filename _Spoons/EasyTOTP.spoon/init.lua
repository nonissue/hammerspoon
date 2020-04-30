--- === EasyTOTP ===
---
--- Menubar app that provides quick access to TOTP tokens
--- Currently copies token to clipboard, and types it
--- Most logic lifted from: 
--- https://github.com/Hammerspoon/Spoons/tree/master/Source/Token.spoon
  
local obj = {}
obj.__index = obj

obj.name = "EasyTOTP"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue/hammerspoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.logger = hs.logger.new("EasyTOTP")
obj.hotkeyShow = nil

obj.menubar = nil
obj.menu = {}

obj.secret = hs.settings.get("totp_secret") or nil

local lockIcon = [[ASCII:
...........
.....l.....
...........
...........
.l.......l.
A.........B
...........
...........
.....l.....
...........
...........
...........
D.........C
]]

-- -- Utility for getting current paths
local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

obj.spoonPath = script_path()

obj.menubarIcon = hs.image.imageFromPath(obj.spoonPath .. '/lock.pdf'):setSize({w=16,h=16})

-- Import basexx utilities
local totp_generator = dofile(obj.spoonPath.."/totp_generator.lua")

function obj:get_token()
  obj.logger.i("getting token...\n" .. "secret: " .. obj.secret .. "\nostime: " .. os.time())
  local hash = totp_generator:generate_token(self.secret, math.floor(os.time() / 30))

  return ("%06d"):format(hash)
end

function obj:set_clipboard()
  local token = obj:get_token()
  hs.pasteboard.setContents(token)
end

function obj:type_token()
  local token = obj:get_token()
  hs.eventtap.keyStrokes(token)
end

function obj.menu_callback() 
  hs.alert("Token -> Pasteboard: " .. obj:get_token(), 3)
  obj:set_clipboard()
  obj:type_token()
end

function obj:init()
  if self.menubar then
    self.menubar:delete()
  end

  if self.secret == nil or self.secret == "" then
    -- or we could prompt the user to enter a key using a chooser or something
    -- NVM, done
    local _, secret = hs.dialog.textPrompt("EasyTOTP", "Enter your TOTP secret", "", "Save", "Cancel")
    if secret ~= nil or secret ~= "" then
      hs.settings.set("totp_secret", secret)
    else
      hs.alert("Set a secret key before retreiving a TOTP token")
      obj.logger.e("You must configure a secret to use EasyTOTP")
      return false472043
    end
  end

  obj.menubar = hs.menubar.new()
  
  -- obj.menubar:setIcon(hs.image.imageFromASCII(lockIcon, {
  --   { shouldClose = true, fillColor = { alpha = 0.9 }, strokeColor = { alpha = 1, red = 0 }, antialias = false, strokeWidth = 4},{ shouldClose = false, fillColor = { alpha = 0 }, strokeColor = { alpha = 1 }, strokeWidth = 3}
  -- }))
  obj.menubar:setIcon(obj.menubarIcon)
  obj.menubar:setClickCallback(obj.menu_callback)
  obj.menubar:setTooltip('EasyTOTP')

  return self
end

return obj