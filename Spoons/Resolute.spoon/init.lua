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
obj.current = nil

function obj:bindHotkeys(mapping)
    local def = {
        showResoluteChooser = hs.fnutils.partial(self:show(), self)
    }

    hs.spoons.bindHotkeysToSpec(def, mapping)
end

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

-- We can get available modes with hs.screen:availableModes()
-- But the list is too long, and we only care about a few options
-- Might be nice to automatically choose some based on screen,
-- but it's tough to know what will look good
local mbpr15 = {
    {["id"] = 1, ["subText"] = "1280x800", ["text"] = "Largest", ["res"] = {w = 1280, h = 800, s = 2}},
    {["id"] = 2, ["subText"] = "1440x900", ["text"] = "Larger", ["res"] = {w = 1440, h = 900, s = 2}},
    {["id"] = 3, ["subText"] = "1680x1050", ["text"] = "Default", ["res"] = {w = 1680, h = 1050, s = 2}},
    {["id"] = 4, ["subText"] = "1920x1200", ["text"] = "More Space", ["res"] = {w = 1920, h = 1200, s = 2}}
}

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
            self:show()
        end
    )
end

function obj:chooserCallback(choice)
    print("Chooser callback called...")
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
        -- make menubar item menu indicate current res
        if hs.screen.mainScreen():currentMode().w == res[i]["res"].w then
            obj.resMenu[i]["checked"] = true
        end
    end
end

function obj:createMenubar(display)
    -- create menubar menu for current display
    self:menubarItems(display)

    -- create menubar, set title, set submenu we just created
    self.menubar = hs.menubar.new():setTitle("⚯"):setMenu(self.resMenu)
end

function obj:show()
    -- self.current = hs.window.frontmostWindow()
    self.resChooser:show()
    return self
end

function obj:start()
    print("-- Starting resChooser")
    self:init()
end

function obj:stop()
    print("-- Stopping resChooser?")
    self.resChooser:delete()
    if self.hotkeyShow then
        self.hotkeyShow:disable()
    end

    self.menubar:delete()

    return self
end

-- trying to fix chooser toggling console?
-- I think it's a bug
local function focusLastFocused()
    local wf = hs.window.filter
    local lastFocused = hs.window.filter.defaultCurrentSpace:getWindows(hs.window.filter.sortByFocusedLast)
    print_r(lastFocused[1])
    if #lastFocused > 0 then
        print("setting last focused!")
        hs.window.orderedWindows()[1]:focus()
    end
end

function obj:init()
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

    self:createMenubar(targetDisplay)

    self.resChooser =
        hs.chooser.new(
        function(choice)
            if not (choice) then
                self.resChooser:hide()
                return
            end
            self:chooserCallback(choice)
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
