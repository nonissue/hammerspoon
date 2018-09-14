
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

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

obj.spoonPath = script_path()

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
  {["id"] = 1, ["text"] = "1280x800", ["res"] = {w = 1280, h = 800, s = 2}},
  {["id"] = 2, ["text"] = "1440x900", ["res"] = {w = 1440, h = 900, s = 2}},
  {["id"] = 3, ["text"] = "1680x1050", ["res"] = {w = 1680, h = 1050, s = 2}},
  {["id"] = 4, ["text"] = "1920x1200", ["res"] = {w = 1920, h = 1200, s = 2}},
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

function obj:resCallback(choice)
  -- if choice['id'] == 1 then
    -- hs.alert("too easy")
    self.changeRes(choice)
    -- print_r(choice["res"])
  -- elseif choice['id'] == 2 then
  --   obj:bust(choice['baseURL'])
  -- elseif choice['id'] == 3 then
  --   obj:bust(choice['baseURL'])
  -- elseif choice['id'] == 4 then
  --   obj:bust(choice['baseURL'])
  -- elseif choice['id'] == 5 then
  --   obj:bust(choice['baseURL'])
  -- else
  --   local URL = self.chooser:query()
  --   obj:createCustom(URL)
  -- end
end

function obj.changeRes(choice)
  w = choice['res']['w']
  h = choice['res']['h']
  s = choice['res']['s']
  -- print_r(choice["res"])
  hs.screen.find("Color LCD"):setMode(w, h, s)

  -- hs.screen.primaryScreen():setMode(w, h, s)
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

  self.resChooser = hs.chooser.new(
    function(choice)
      if not (choice) then
        print(self.resChooser:query())
        self.resChooser:hide()
      else
        self:resCallback(choice)
      end
  end)

  self.resChooser:choices(mbpr15)
  self.resChooser:rows(#mbpr15)

  self.resChooser:queryChangedCallback(function(query)
    if query == '' then
      self.resChooser:choices(mbpr15)
    else
      local choices = {
        {["id"] = 0, ["text"] = "Custom", subText="Enter a custom resolution that almost certainly won't work"},
      }
      self.resChooser:choices(choices)
    end
  end)

  self.resChooser:width(20)
  self.resChooser:bgDark(false)

  return self
end

return obj