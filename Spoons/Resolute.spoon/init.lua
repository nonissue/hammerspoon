
local obj = {}
obj.__index = obj

-- Metadata
obj.name = "Resolute"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.acerChooser = nil
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

function obj:acerCallback(choice)
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
  hs.screen.find("acer"):setMode(w, h, s)

  -- hs.screen.primaryScreen():setMode(w, h, s)
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

function obj:init()

  self.acerChooser = hs.chooser.new(
    function(choice)
      if not (choice) then
        print(self.acerChooser:query())
        self.acerChooser:hide()
      else
        self:acerCallback(choice)
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

return obj