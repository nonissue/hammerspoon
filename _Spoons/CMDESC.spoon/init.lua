--- === CMDESC ===
---
--- Rebind caps lock to escape when pressed alone,
--- control modifier when pressed with other keys
---
--
-- Almost none of this is original work, just combined some existing solutions
-- See Readme for more info
--
--
-- TODO
-- Tests
-- Docs
-- Remove any utilities/functions speciifc to my config
-- Pull on a new hammerspoon config and see if it works
-- GLOBE keycode (mbp) = 63
local obj = {}
obj.__index = obj

-- obj.logger.i('Initializing CMD-ESC.spoon logger...')
obj.name = "CMDESC"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue/hammerspoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.logger = hs.logger.new("CMDESC")

obj.cmd_held_down_alone = false
obj.prev_mods = {}

-- get length of table so we can check how many keys
-- method borrowed from
-- https://gist.github.com/zcmarine/f65182fe26b029900792fa0b59f09d7f
local function len(t)
    local length = 0
    -- changed this to stateless iterators
    -- and i think it's working?
    for _, _ in pairs(t) do
        length = length + 1
    end
    return length
end

local function logVariables()
    obj.logger.i("\n\ncmd_held_down_alone: " .. tostring(self.cmd_held_down_alone) .. "\nlen(cur_mods): " ..
                         len(cur_mods) .. "\nlen(self.prev_mods): " .. len(self.prev_mods) .. "\n\n")
end

-- logic largely copied from
-- https://gist.github.com/zcmarine/f65182fe26b029900792fa0b59f09d7f
function obj:mod_event_handler(event)
    local cur_mods = event:getFlags()

    obj.logger.i(i(event:getFlags()))

    if cur_mods["cmd"] and len(cur_mods) == 1 then
        -- cmd is down alone! start watching for next key pressed
        -- we set cmd_held_down == true
        self.cmd_held_down_alone = true
        -- obj:setMenuItems()

        -- logging
        obj.logger.i("\n\ncmd_held_down_alone: " .. tostring(self.cmd_held_down_alone) .. "\nlen(cur_mods): " ..
                         len(cur_mods) .. "\nlen(self.prev_mods): " .. len(self.prev_mods) .. "\n\n")

    elseif len(cur_mods) == 0 and len(self.prev_mods) == 1 and self.cmd_held_down_alone then
        -- cmd was down alone, but has been released without escape being pressed.
        self.cmd_held_down_alone = false
        -- obj:setMenuItems()


        -- logging
        obj.logger.i("\n\ncmd_held_down_alone: " .. tostring(self.cmd_held_down_alone) .. "\nlen(cur_mods): " ..
                         len(cur_mods) .. "\nlen(self.prev_mods): " .. len(self.prev_mods) .. "\n\n")
        obj.logger.i("\n\ncmd up")
    else
        -- cases that fall through? 
        -- we could set self.cmd_held_down_alone = true
        obj.logger.i("\n\ncmd_held_down_alone: " .. tostring(self.cmd_held_down_alone) .. "\nlen(cur_mods): " ..
                         len(cur_mods) .. "\nlen(self.prev_mods): " .. len(self.prev_mods) .. "\n\n")
        obj.logger.i("\n\nUnhandled?")
    end



    self.prev_mods = cur_mods

    return false
end

--[[ ------------------------------------------------------------------ 

        MENUBAR

]] ------------------------------------------------------------------ 

local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

obj.spoonPath = script_path()

obj.menuIcon = hs.image.imageFromPath(obj.spoonPath .. "/hammer.circle.fill.test.pdf"):setSize({
    w = 20,
    h = 20
})

function obj:setMenuItems()
    local menuItems = {{
        title = hs.styledtext.new("cmd_held_down_alone: " .. tostring(obj.cmd_held_down_alone)),
        fn = function()
            hs.alert("Test")
        end,
        checked = false
    }}
    obj.menu:setMenu(menuItems)
end

obj.menuItems = {{
    title = hs.styledtext.new("cmd_held_down_alone: " .. tostring(obj.cmd_held_down_alone)),
    fn = function()
        hs.alert("Test")
    end,
    checked = false
}}

function obj:createMenu()
    obj.logger.i("CMDESC.spoon Creating menu")
    obj.menu = hs.menubar.new()
    obj.menu:setIcon(obj.menuIcon)
    obj:setMenuItems()
end

function obj:init()
    self.send_tilde = false
    self.cmd_held_down_alone = false

    self.cmd_tap = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(event)
        -- obj.logger.e("cmd_tap fired")
        -- obj.logger.e(i(event))
        -- obj.logger.e(event:getKeyCode())
        -- hs.alert("caps fired")
        obj:mod_event_handler(event)
    end)
    self.non_cmd_tap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
        -- obj.logger.e("non_cmd_tap fired")
        -- obj.logger.e(i(event))
        -- obj.logger.e(event:getKeyCode())
        self.send_tilde = false
        return false
    end)
end

function obj:start()
    self.logger.df("CMDESC.spoon started")

    hs.alert("CMDESC")

    self.cmd_tap:start()
    self.non_cmd_tap:start()

    obj:createMenu()
end

function obj:stop()
    obj.logger.df("CMDESC.spoon stopped")

    self.cmd_tap:stop()
    self.non_cmd_tap:stop()

    self.send_esc = false
    self.prev_mods = {}
end

return obj
