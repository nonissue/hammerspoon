local obj = {}
obj.__index = obj

-- Metadata
obj.name = "Resolute"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.logger = hs.logger.new("Resolute")
obj.resChooser = nil
obj.hotkeyShow = nil
obj.menubar = nil
obj.menuIcon = "☲"
obj.resMenu = {}
obj.current = nil

function obj:bindHotkeys(mapping)
    local def = {
        showResoluteChooser = hs.fnutils.partial(self:show(), self)
    }

    hs.spoons.bindHotkeysToSpec(def, mapping)
end

-- TODO:
-- this should be automated somehow?


-- We can get available modes with hs.screen:availableModes()
-- But the list is too long, and we only care about a few options
-- Might be nice to automatically choose some based on screen,
-- but it's tough to know what will look good
local mbpr15 = {
    {["id"] = 1, ["icon"] = "☳", ["subText"] = "1280x800", ["text"] = "Largest", ["res"] = {w = 1280, h = 800, s = 2}},
    {["id"] = 2, ["icon"] = "☱", ["subText"] = "1440x900", ["text"] = "Larger", ["res"] = {w = 1440, h = 900, s = 2}},
    {["id"] = 3, ["icon"] = "☲", ["subText"] = "1680x1050", ["text"] = "Default", ["res"] = {w = 1680, h = 1050, s = 2}},
    {["id"] = 4, ["icon"] = "☴", ["subText"] = "1920x1200", ["text"] = "Smaller", ["res"] = {w = 1920, h = 1200, s = 2}}
}

local acer4k = {
    -- {["id"] = 1, ["icon"] = "☳", ["subText"] = "1280x800", ["text"] = "Largest", ["res"] = {w = 1280, h = 800, s = 2}},
    {["id"] = 2, ["icon"] = "☱", ["subText"] = "1440x900", ["text"] = "Larger", ["res"] = {w = 1440, h = 900, s = 2}},
    -- {["id"] = 3, ["icon"] = "☲", ["subText"] = "1680x1050", ["text"] = "Default", ["res"] = {w = 1680, h = 1050, s = 2}},
    -- {["id"] = 4, ["icon"] = "☴", ["subText"] = "1920x1200", ["text"] = "Smaller", ["res"] = {w = 1920, h = 1200, s = 2}}
}

function obj:bindHotkeys(keys)
    assert(keys["showResoluteChooser"], "Hotkey variable is 'showResoluteChooser'")

    hs.hotkey.bindSpec(
        keys["showResoluteChooser"],
        function()
            self:show()
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

    -- change res
    hs.screen.mainScreen():setMode(w, h, s)

    -- The code below updates the menubar menu to indicate new resolution
    -- The menubar menu doesn't refresh automatically, so we generate
    -- a new table of options, and then replace the existing one
    -- Not efficient, but there doesn't seem to be a delay and
    -- I can't think of a better way to do this

    -- clear current resmenu
    obj.resMenu = {}

    -- recreate current resmenu
    obj:menubarItems(mbpr15)

    -- set current title based on res
    obj.menubar:setTitle(obj.menuIcon)
    -- set current resmenu
    obj.menubar:setMenu(obj.resMenu)
end

function obj:menubarItems(res)
    for i = 1, #res do
        table.insert(
            self.resMenu,
            {
                title = hs.styledtext.new(" " .. res[i]["text"], {font = hs.styledtext.defaultFonts.menu}),
                fn = function()
                    self.changeRes(res[i]["res"])
                end,
                checked = false
            }
        )
        -- make menubar item menu indicate current res
        if hs.screen.mainScreen():currentMode().w == res[i]["res"].w then
            -- set new menu title reflecting current res
            obj.menuIcon = res[i]["icon"]
            -- indicate which submenu item is selected
            obj.resMenu[i]["checked"] = true
        end
    end
end

function obj.createMenubar(display)
    -- create menubar menu for current display
    obj:menubarItems(display)

    -- initially set title to reflect current res
    obj.menubar = hs.menubar.new():setTitle(obj.menuIcon):setMenu(obj.resMenu)
end

function obj:show()
    -- added logic to show different resolution choices on different screens
    -- works on whichever screen is currently focused
    if hs.screen.mainScreen():name() == "Color LCD" then
        self.resChooser:choices(mbpr15)
    else 
        self.resChooser:choices(acer4k)
    end
    self.resChooser:show()
    return self
end

function obj:init()
    -- TODO: add logic to detect current display
    -- if screens 
    local targetDisplay = mbpr15

    if self.menubar then
        self.menubar:delete()
    end

    if self.resMenu then
        self.resMenu = {}
    end

    if self.resChooser then
        self.resChooser:delete()
    end

    self.createMenubar(targetDisplay)

    self.resChooser =
        hs.chooser.new(
        function(choice)
            if not (choice) then
                obj.logger.i("Hiding chooser")
                self.resChooser:hide()
                return
            else
                obj.logger.i("Choice selected")
                self:chooserCallback(choice)
            end
        end
    )

    self.resChooser:choices(targetDisplay)
    self.resChooser:rows(#targetDisplay)

    self.resChooser:placeholderText("Select a resolution")
    self.resChooser:searchSubText(true)
    self.resChooser:width(30)
    self.resChooser:bgDark(true)
    self.resChooser:fgColor({hex = "#ccc"})
    self.resChooser:subTextColor({hex = "#888"})

    return self
end

function obj:start()
    obj.logger.df("-- Starting resChooser")
    self:init()
    return self
end

function obj:stop()
    obj.logger.df("-- Stopping resChooser?")
    self.resChooser:hide()
    if self.hotkeyShow then
        self.hotkeyShow:disable()
    end

    self.menubar:delete()

    return self
end

return obj
