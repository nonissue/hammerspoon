-- ------------------------------------------------------------------
--        MENUBAR START
-- ------------------------------------------------------------------
local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

obj.spoonPath = script_path()

obj.menuIcon =
    hs.image.imageFromPath(obj.spoonPath .. "/hammer.circle.fill.test.pdf"):setSize(
    {
        w = 20,
        h = 20
    }
)

function obj:setMenuItems()
    local menuItems = {
        {
            title = hs.styledtext.new("cmd_held_down_alone: " .. tostring(obj.cmd_held_down_alone)),
            fn = function()
                hs.alert("Test")
            end,
            checked = false
        }
    }
    obj.menu:setMenu(menuItems)
end

obj.menuItems = {
    {
        title = hs.styledtext.new("cmd_held_down_alone: " .. tostring(obj.cmd_held_down_alone)),
        fn = function()
            hs.alert("Test")
        end,
        checked = false
    }
}

function obj:createMenu()
    obj.logger.i("CMDESC.spoon Creating menu")
    obj.menu = hs.menubar.new()
    obj.menu:setIcon(obj.menuIcon)
    obj:setMenuItems()
end

-- ------------------------------------------------------------------
--        MENUBAR END
-- ------------------------------------------------------------------
