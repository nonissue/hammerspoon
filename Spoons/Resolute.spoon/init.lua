
local obj = {}
obj.__index = obj

-- Metadata
obj.name = "Resolute"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.resChooser = nil
obj.hotkeyShow = nil
obj.menubar = nil
obj.resMenu = {}

-- local function script_path()
--   local str = debug.getinfo(2, "S").source:sub(2)
--   return str:match("(.*/)")
-- end

-- obj.spoonPath = script_path()

-- hotkey binding not working
function obj:bindHotkeys(mapping)
  local def = {
    showPaywallBuster = hs.fnutils.partial(self:show(), self),
   }

   hs.spoons.bindHotkeysToSpec(def, mapping)
end

local mbpr15raw = {
  -- first 1920 is for retina resolution @ 30hz
  -- might not be neede as 2048 looks pretty good
  {w = 1280, h = 800, s = 2},
  {w = 1440, h = 900, s = 2},
  {w = 1680, h = 1050, s = 2},
  {w = 1920, h = 1200, s = 2},
}

local mbpr15 = {
  -- first 1920 is for retina resolution @ 30hz
  -- might not be neede as 2048 looks pretty good
  {["id"] = 1, ["subText"] = "1280x800",  ["text"] = "Largest", ["res"] = {w = 1280, h = 800, s = 2}},
  {["id"] = 2, ["subText"] = "1440x900",  ["text"] = "Larger", ["res"] = {w = 1440, h = 900, s = 2}},
  {["id"] = 3, ["subText"] = "1680x1050", ["text"] = "Default", ["res"] = {w = 1680, h = 1050, s = 2}},
  {["id"] = 4, ["subText"] = "1920x1200", ["text"] = "More Space", ["res"] = {w = 1920, h = 1200, s = 2}},
}

local acer4kresRaw = {
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
  {["id"] = 1, ["text"] = "1920x1080", ["res"] = {w = 1920, h = 1080, s = 2}},
  {["id"] = 2, ["text"] = "2048x1152", ["res"] = {w = 2048, h = 1152, s = 2}},
  {["id"] = 3, ["text"] = "2304x1296", ["res"] = {w = 2304, h = 1296, s = 2}},
  {["id"] = 4, ["text"] = "2560x1440", ["res"] = {w = 2560, h = 1440, s = 2}},
}

function obj:chooserCallback(choice)
    self.changeRes(choice['res'])
end

function obj.changeRes(choice)
  w = choice['w']
  h = choice['h']
  s = choice['s']
  -- print_r(choice["res"])
  hs.screen.find("Color LCD"):setMode(w, h, s)

  -- hs.screen.primaryScreen():setMode(w, h, s)
end

function obj:createMenu(res)
  local resMenu = {}
  for i = 1, #res do
    table.insert(
      resMenu, 
      {
        title = res[i]['res'].w,
        fn = function() self.changeRes(res[i]['res']) end,
      }
    )
  end

  return resMenu
end

function obj:createMenubar(display)
  self.menubar = hs.menubar.new():setTitle("⚯")
  

  self.menubar:setMenu(
    self:createMenu(display)
  )
end

function obj:show()
  self.resChooser:show()
  return self
end

function obj:start()
  print("-- Starting resChooser")
  return self
end
  
function obj:stop()
  print("-- Stopping resChooser?")
  self.resChooser:hide()
  if self.hotkeyShow then
      self.hotkeyShow:disable()
  end

  return self
end

function obj:init()
  local targetDisplay = mbpr15 

  if self.menubar then
    self.menubar:delete()
  end

  if self.resMenu then 
    self.resMenu = {}
  end

  self:createMenubar(targetDisplay)

  self.resChooser = hs.chooser.new(
    function(choice)
      if not (choice) then
        print(self.resChooser:query())
        self.resChooser:hide()
      else
        self:chooserCallback(choice)
      end
  end)

  self.resChooser:choices(targetDisplay)
  self.resChooser:rows(#targetDisplay)

  self.resChooser:queryChangedCallback(function(query)
    if query == '' then
      self.resChooser:choices(targetDisplay)
    else
      local choices = {
        {["id"] = 0, ["text"] = "Custom", subText="Enter a custom resolution (BROKEN)"},
      }
      self.resChooser:choices(choices)
    end
  end)

  self.resChooser:width(30)
  self.resChooser:bgDark(true)
  self.resChooser:fgColor({hex = "#ccc"})
  self.resChooser:subTextColor({hex = "#888"})

  return self
end

return obj