--- === HammerMenu ===
---
--- A menubar item that combines other existing menubar items
--- Combines:
--- - EasyTOTP
--- - Resolute
--- - Context
--- - Zzz
---
local obj = {}
obj.__index = obj

obj.name = "HammerMenu"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue/hammerspoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.logger = hs.logger.new("HammerMenu")
obj.logger.i('Initializing HammerMenu.spoon logger...')

local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

obj.spoonPath = script_path()

-- local zzzMenu = require(obj.spoonPath .. "/test")
obj.zzz = dofile(obj.spoonPath .. "zzz.lua")

obj.menuItems = {
    {
        title = hs.styledtext.new("test"),
        fn = function() hs.alert("Test") end,
        checked = false
    }, {title = "-"}, {
        title = "Zzz",
        fn = function() hs.alert("Clicked") end,
        menu = obj.zzz.menuItems
    }
}

-- right so i like this one the best visually, but maybe it should change if unknown state is encoutered
-- or if there is a warning (eg. dgpu enabled?)
obj.menuIcon = hs.image.imageFromPath(obj.spoonPath ..
                                          "/hammer.circle.fill.test.pdf"):setSize(
                   {w = 20, h = 20})

function obj:formatSeconds(s)
    local seconds = tonumber(s)
    if seconds then
        local hours = string.format("%02.f", math.floor(seconds / 3600))
        local mins = string.format("%02.f",
                                   math.floor(seconds / 60 - (hours * 60)))
        local secs = string.format("%02.f", math.floor(
                                       seconds - hours * 3600 - mins * 60))
        return " " .. hours .. ":" .. mins .. ":" .. secs
    else
        return false
    end
end

function obj:createMenu()
    obj.logger.i("HammerMenu.spoon Creating menu")
    obj.menu = hs.menubar.new()
    obj.menu:setIcon(obj.menuIcon)
    obj.menu:setMenu(obj.menuItems)
end

function obj:init() obj.logger.i("HammerMenu.spoon Initializing") end

function obj:start()
    obj.logger.i("HammerMenu.spoon Starting")
    obj.createMenu()

    -- obj.menubar = hs.menubar.new()
    -- obj.menubar:setTitle("CMDTAB: IDLE")
end

function obj:stop() obj.logger.i("HammerMenu.spoon Stopping") end

return obj
