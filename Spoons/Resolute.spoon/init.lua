local obj = {}
obj.__index = obj

-- Metadata
obj.name = "Resolute"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.logger = hs.logger.new('Resolute')
obj.resChooser = nil
obj.hotkeyShow = nil
obj.menubar = nil
obj.resMenu = {}

obj.defaultHotkeys = {
    showResoluteChooser = {{"cmd", "alt", "ctrl"}, "L"}
}

-- TODO:
-- this should be automated somehow?
local mbpr15raw = {
    -- first 1920 is for retina resolution @ 30hz
    -- might not be neede as 2048 looks pretty good
    {w = 1280, h = 800, s = 2},
    {w = 1440, h = 900, s = 2},
    {w = 1680, h = 1050, s = 2},
    {w = 1920, h = 1200, s = 2}
}

local mbpr15 = {
    -- first 1920 is for retina resolution @ 30hz
    -- might not be neede as 2048 looks pretty good
    {["id"] = 1, ["subText"] = "1280x800", ["text"] = "Largest", ["res"] = {w = 1280, h = 800, s = 2}},
    {["id"] = 2, ["subText"] = "1440x900", ["text"] = "Larger", ["res"] = {w = 1440, h = 900, s = 2}},
    {["id"] = 3, ["subText"] = "1680x1050", ["text"] = "Default", ["res"] = {w = 1680, h = 1050, s = 2}},
    {["id"] = 4, ["subText"] = "1920x1200", ["text"] = "More Space", ["res"] = {w = 1920, h = 1200, s = 2}}
}

-- local acer4kresRaw = {
--     -- first 1920 is for retina resolution @ 30hz
--     -- might not be neede as 2048 looks pretty good
--     { w = 1920, h = 1080, s = 2 },
--     { w = 2048, h = 1152, s = 2 },
--     { w = 2304, h = 1296, s = 2 },
--     { w = 2560, h = 1440, s = 2 }
-- }

local acer4kres = {
    -- first 1920 is for retina resolution @ 30hz
    -- might not be neede as 2048 looks pretty good
    {["id"] = 1, ["text"] = "1920x1080", ["res"] = {w = 1920, h = 1080, s = 2}},
    {["id"] = 2, ["text"] = "2048x1152", ["res"] = {w = 2048, h = 1152, s = 2}},
    {["id"] = 3, ["text"] = "2304x1296", ["res"] = {w = 2304, h = 1296, s = 2}},
    {["id"] = 4, ["text"] = "2560x1440", ["res"] = {w = 2560, h = 1440, s = 2}}
}

function obj:bindHotkeys(keys)
    assert(keys["showResoluteChooser"], "Hotkey variable is 'showResoluteChooser'")

    hs.hotkey.bindSpec(
        keys["showResoluteChooser"],
        function()
            self.resChooser:show()
        end
    )
end

function obj:chooserCallback(choice)
    self.changeRes(choice["res"])
end

function obj.changeRes(choice)
    local w = choice["w"]
    local h = choice["h"]
    local s = choice["s"]

    -- hs.screen.find("Color LCD"):setMode(w, h, s)
    hs.screen.mainScreen():setMode(w, h, s)
    obj.resMenu = {}
    obj:menubarItems(mbpr15)
    obj.menubar:setMenu(obj.resMenu)
end

function obj:menubarItems(res)
    for i = 1, #res do
        table.insert(
            self.resMenu,
            {
                title = hs.styledtext.new(" " .. res[i]["text"], {font = hs.styledtext.defaultFonts.userFixedPitch}),
                fn = function()
                    self.changeRes(res[i]["res"])
                end,
                checked = false,
            }
        )
        if hs.screen.mainScreen():currentMode().w == res[i]["res"].w then
            obj.resMenu[i]["checked"] = true
        end
    end

    --local widthTest = {
    --    { title = "other item", fn = function() print('test') end },
    --    { title = "disabled item", disabled = true },
    --    { title = "checked item", checked = true },
    --}
    -- table.insert(resMenu, { title = "-" })
    -- table.insert(resMenu, { title = "disabled item", disabled = true  })

    -- return resMenu
end

-- local widthTest =  {
--     { title = "my menu item", fn = function() print("you clicked my menu item!") en  },
--     { title = "-" },
--     { title = "other item", fn = some_function },
--     { title = "disabled item", disabled = true  },
--     { title = "checked item", checked = true },
-- }

-- for i = 1, #widthTest do
--     table.insert(widthTest, {["res"] = {w = 1920, h = 1080, s = 2}})
-- end

function obj:createMenubar(display)
    self:menubarItems(display)
    self.menubar = hs.menubar.new():setTitle("⚯"):setMenu(self.resMenu)
end

function obj:show()
    self.resChooser:show()

    return self
end

function obj:start()
    print("-- Starting resChooser")
    self:init()

    return self
end

function obj:stop()
    print("-- Stopping resChooser?")
    self.resChooser:hide()
    if self.hotkeyShow then
        self.hotkeyShow:disable()
    end

    self.menubar:delete()

    return self
end

function obj:init()
    -- TODO: add logic to detect current display
    local targetDisplay = mbpr15

    if self.menubar then
        self.menubar:delete()
    end

    if self.resMenu then
        self.resMenu = {}
    end

    self:createMenubar(targetDisplay)

    self.resChooser =
        hs.chooser.new(
        function(choice)
            if not (choice) then
                self.resChooser:hide()
            else
                self:chooserCallback(choice)
            end
        end
    )

    self.resChooser:choices(targetDisplay)
    self.resChooser:rows(#targetDisplay)

    self.resChooser:width(20)
    self.resChooser:bgDark(true)
    self.resChooser:fgColor({hex = "#ccc"})
    self.resChooser:subTextColor({hex = "#888"})

    return self
end

return obj
