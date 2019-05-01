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
    {["id"] = 1, ["icon"] = "☳", ["subText"] = "1280x800", ["text"] = "Largest", ["res"] = {w = 1280, h = 800, s = 2}},
    {["id"] = 2, ["icon"] = "☱", ["subText"] = "1440x900", ["text"] = "Larger", ["res"] = {w = 1440, h = 900, s = 2}},
    {["id"] = 3, ["icon"] = "☲", ["subText"] = "1680x1050", ["text"] = "Default", ["res"] = {w = 1680, h = 1050, s = 2}},
    {["id"] = 4, ["icon"] = "☴", ["subText"] = "1920x1200", ["text"] = "More Space", ["res"] = {w = 1920, h = 1200, s = 2}}
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
    -- set current resmenu
    obj.menubar:setTitle(obj.menuIcon)
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
                checked = false,
            }
        )
        -- make menubar item menu indicate current res
        if hs.screen.mainScreen():currentMode().w == res[i]["res"].w then
            obj.menuIcon = res[i]["icon"]
            obj.resMenu[i]["checked"] = true
        end
    end
end

function obj:createMenubar(display)
    -- create menubar menu for current display
    self:menubarItems(display)
    -- local test = "1⃣2⃣3⃣ 4 ⃝: 44⃞ 4⃝ 4⃫ 44⃤  4⃩ ❏❒❑"
    local title =  "☲"-- ☲⧉∆ↁⳭ" -- "⃣" -- ☲ = def, ☱ = one larger, ☴ = one smaller, ☶ ☳ = two smaller?
    -- local styled = hs.styledtext.new(title, {font = {name = "Helvetica"}})
    -- create menubar, set title, set submenu we just created
    self.menubar = hs.menubar.new():setTitle(obj.menuIcon):setMenu(self.resMenu)
end

function obj:show()
    -- self.current = hs.window.frontmostWindow()
    self.resChooser:show()
    return self
end



local function focusLastFocused()
    local wf = hs.window.filter
    local lastFocused = hs.window.filter.defaultCurrentSpace:getWindows(hs.window.filter.sortByFocusedLast)
    if #lastFocused > 0 then
        lastFocused[1]:raise():focus()
    end
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

    if self.resChooser then
        self.resChooser:delete()
    end

    self:createMenubar(targetDisplay)

    self.resChooser =
        hs.chooser.new(
        function(choice)
            if not (choice) then
                self.resChooser:hide()
                -- focusLastFocused()
                -- local current = hs.application.frontmostApplication()
                -- self.current:becomeMain()
                -- focusLastFocused()
                -- print(hs.inspect(hs.window.frontmostWindow()))
                -- currentWin:focus():raise()
                return
                -- self.resChooser:cancel()
                -- print_r(hs.window.filter.defaultCurrentSpace:getWindows(hs.window.filter.sortByFocusedLast))
            else
                self:chooserCallback(choice)
                -- focusLastFocused()
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
