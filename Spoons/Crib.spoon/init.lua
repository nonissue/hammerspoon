--- === Crib ===
---
-- Crib

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "eGPU"
obj.version = "0.1"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepzage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"
-- end Metadata
 
-- init logger
obj.logger = hs.logger.new('Crib', 'verbose')

obj.chooser = nil

local chooserTable = {
    {["id"] = 1, ["text"] = "tmux", subText="subtext"},
    {["id"] = 1, ["text"] = "vim", subText="subtext"},
}

function obj:chooserCallback(choice)
    -- if not choicez then focusLastFocused(); return end
    if choice['id'] == 1 then
      -- seems to have fixed the binding problem [FIXED?]  z-
        return choice['id']
    elseif choice['id'] == 2 then
      obj:bust(choice['text'])
    elseif choice['id'] == 3 then
      obj:bust(choice['text'])
    elseif choice['id'] == 4 then
      obj:bust(choice['text'])
    elseif choice['id'] == 5 then
      obj:bust(choice['text'])
    else
      local URL = self.chooser:query()
    --   obj:createCustom(URL)
    end
end

--- PaywallBuster:chooser()
--- Method
--- 
---
--- Parameters:
---  * None
---
--- Returns:
---  * The - object
function obj:chooser()
    self.chooser = hs.chooser.new(
      function(choice)
        if not (choice) then
          print(self.chooser:query())
          self.chooser:hide()
        else
          self:chooserCallback(choice)
        end
      end
    )
      
    self.chooser:choices(chooserTable)
    self.chooser:rows(#chooserTable)
      
    self.chooser:queryChangedCallback(function(query)
      if query == '' then
        self.chooser:choices(chooserTable)
      else
        local choices = {
          {["id"] = 0, ["text"] = "Custom", subText="Custom search method title"},
        }
        self.chooser:choices(choices)
      end
    end)
    self.chooser:width(20)
    self.chooser:bgDark(false)
  
    return self
end

function obj:init()
    return obj
end

function obj:start()
    return obj
end

function obj:stop()
    return obj
end

return obj