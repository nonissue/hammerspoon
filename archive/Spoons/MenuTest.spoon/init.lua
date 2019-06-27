--[[
    Todo:
    - [ ] combine alerts when multiple callbacks are fired
    - [ ] move SSIDs in hs key value store
    - [ ] make sure all wake events are handle (screen, system)
    - [ ] make sure everything is cleaned up if spoon is destroyed/unloaded
    - [ ] move displays to hs key value store
    - [ ] move list of drives to eject to hs key value store
]]


local obj = {}
obj.__index = obj

obj.name = "MenuTest"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.logger = hs.logger.new("MenuTest")
obj.hotkeyShow = nil

obj.menubar = nil
obj.menuIcon = "Test"
obj.menu = {}

local function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function obj:init()
    if self.menubar then
        self.menubar:delete()
    end

    obj.menubar = hs.menubar.new():setTitle(obj.menuIcon)

    obj.menu = {
        {
            title = hs.styledtext.new("test 1"),
            fn = function()
                hs.alert("location clicked")
            end
        },
        {
            title = hs.styledtext.new("test 2"),
            fn = function()
                hs.alert("docked clicked")
            end
        }
    }

    obj.menubar:setMenu(obj.menu)

    return self
end

-- start watchers
function obj:start()
    obj.logger.i("-- Starting Contexts")
    if self.hotkeyShow then
        self.hotkeyShow:enable()
    end

    obj:init()

    return self
end

-- stop watchers
function obj:stop()
    obj.logger.df("-- Stopping Contexts")
    if self.hotkeyShow then
        self.hotkeyShow:disable()
    end

    obj.menubar:delete()

    return self
end

return obj
