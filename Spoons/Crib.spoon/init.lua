--- === Crib ===
---
-- Crib
-- https://github.com/dharmapoudel/hammerspoon-config
-- https://github.com/scottcs/dot_hammerspoon/tree/master/cheatsheets

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
obj.logger = hs.logger.new("Crib", "verbose")

obj.chooser = nil

local chooserTable = {
    {["id"] = 1, ["text"] = "tmux", subText = "subtext"},
    {["id"] = 1, ["text"] = "vim", subText = "subtext"},
}

local cribsheet = {
    tmux = "tmux shortcuts",
    nvim = "nvim shortcuts",
}

obj.defaultHotkeys = {
    showChooser =              {{"ctrl", "alt", "cmd"},                     "O"},
}

function obj:bindHotkeys(keys)
    assert(keys['showChooser'], "Hotkey variable is 'showChooser'")

    hs.hotkey.bindSpec(
        keys["showChooser"],
        function()
            self.chooser:show()
        end
    )
end

function obj:chooserCallback(choice)
    -- if not choicez then focusLastFocused(); return end
    -- why not just index a table?
    -- if cribsheet[choice.text] then
    local crib = cribsheet[choice.text]
    if not crib then
        hs.alert("cribsheet error")
        return
        -- return choice["id"]
    else
        hs.alert(crib)
        return
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
function obj:init()
    self.chooser =
        hs.chooser.new(
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

    self.chooser:queryChangedCallback(
        function(query)
            if query == "" then
                self.chooser:choices(chooserTable)
            else
                local choices = {
                    {["id"] = 0, ["text"] = "Custom", subText = "Custom search method title"}
                }
                self.chooser:choices(choices)
            end
        end
    )
    self.chooser:width(20)
    self.chooser:bgDark(true)

    return self
end

-- function obj:init()

--     return obj
-- end

function obj:show()
    self.chooser:show()
    return
end

function obj:start()
    return obj
end

function obj:stop()
    return obj
end

return obj
