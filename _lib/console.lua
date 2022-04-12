-- largely lifted from
-- https://github.com/asmagill/hammerspoon-config-take2/blob/master/utils/_actions/consoleTweaks.lua

-- colors from:
-- https://rosepinetheme.com/palette

-- icons from SF Symbols, processed in affinity designer, filled with color: #626671

local console = require("hs.console")
local canvas = require("hs.canvas")
local image = require("hs.image")
local screen = require("hs.screen")
local application = require("hs.application")

-- for search functionality

local _c = canvas.new {x = 0, y = 0, h = 200, w = 200}
_c[1] = {
    type = "image",
    image = image.imageFromName("NSShareTemplate"):template(false),
    transformation = canvas.matrix.translate(100, 100):rotate(180):translate(-100, -100)
}
local _i_reseatConsole = _c:imageFromCanvas()
_c:delete()

local imageBasePath = hs.configdir .. "/_lib/_assets/"

print("\n\n\n" .. imageBasePath .. "/questionmark.circle.svg")
local _i_help = hs.image.imageFromPath(imageBasePath .. "questionmark.circle.pdf"):setSize({w = 20, h = 20})
local _i_darkModeToggle = hs.image.imageFromPath(imageBasePath .. "moon.circle.pdf"):setSize({w = 20, h = 20})
local _i_clearConsole = hs.image.imageFromPath(imageBasePath .. "xmark.circle.pdf"):setSize({w = 20, h = 20})
local _i_hsSettings = hs.image.imageFromPath(imageBasePath .. "gear.circle.pdf"):setSize({w = 20, h = 20})
local _i_reload = hs.image.imageFromPath(imageBasePath .. "arrow.counterclockwise.circle.pdf"):setSize({w = 20, h = 20})
local _i_editConfig = hs.image.imageFromPath(imageBasePath .. "hammer.circle.pdf"):setSize({w = 20, h = 20})
-- local _i_darkModeToggle =
--     image.imageFromASCII(
--     "2.........3\n" ..
--         "...........\n" ..
--             ".....g.....\n" ..
--                 "...........\n" ..
--                     "1...f.h...4\n" ..
--                         "6...b.c...9\n" .. "...........\n" .. "...a...d...\n" .. "...........\n" .. "7.........8",
--     {
--         {strokeColor = {white = .5}, fillColor = {alpha = 0.0}, shouldClose = false},
--         {strokeColor = {white = .75}, fillColor = {alpha = 0.5}, shouldClose = false},
--         {strokeColor = {white = .75}, fillColor = {alpha = 0.0}, shouldClose = false},
--         {strokeColor = {white = .5}, fillColor = {alpha = 0.0}, shouldClose = true},
--         {}
--     }
-- )

local colorizeConsolePerDarkMode = function()
    if console.darkMode() then
        hs.console.alpha(.98)
        hs.console.consoleCommandColor({hex = "#f6c177"})
        hs.console.consolePrintColor({hex = "#AEABC1"})
        hs.console.consoleResultColor({hex = "#c4a7e7"})
        hs.console.inputBackgroundColor({hex = "#222222"})
        hs.console.outputBackgroundColor({hex = "#111111"})
        hs.console.windowBackgroundColor {list = "System", name = "windowBackgroundColor"}
    else
        --
        -- FYI these are the defaults
        -- ?? dunno if true

        -- hs.console.outputBackgroundColor {list = "System", name = "textBackgroundColor"}
        -- hs.console.windowBackgroundColor {list = "System", name = "windowBackgroundColor"}
        -- hs.console.windowBackgroundColor({red=.6,blue=.7,green=.7})
        -- hs.console.outputBackgroundColor({red=.8,blue=.8,green=.8})

        -- Custom nonissue
        hs.console.alpha(.99)
        hs.console.consoleCommandColor({hex = "#7D1131"})
        hs.console.consolePrintColor({hex = "#575279"})
        hs.console.consoleResultColor({hex = "#286983"})
        hs.console.inputBackgroundColor({hex = "#faf4ed"})
    end
end

console.behaviorAsLabels({"moveToActiveSpace"})
-- console.behaviorAsLabels({"canJoinAllSpaces"})

--console.titleVisibility("hidden")
console.toolbar():addItems {
    {
        id = "clear",
        image = _i_clearConsole,
        fn = function(...)
            console.clearConsole()
        end,
        label = "Clear",
        tooltip = "Clear Console",
        default = true
    },
    {
        id = "reload2",
        image = _i_reload,
        fn = function(...)
            hs.reload()
        end,
        label = "Reload",
        tooltip = "Reload config",
        default = true
    },
    {
        -- edit config in editor of choice, added by me
        id = "editConfig",
        label = "Edit HS Config",
        tooltip = "Opens HS config in VSCode",
        image = _i_editConfig,
        fn = function(bar, attachedTo, item)
            hs.execute("/usr/local/bin/code ~/.hammerspoon")
        end,
        default = true
    },
    -- dunno what this does?
    -- {
    --     id = "reseat",
    --     image = _i_reseatConsole,
    --     fn = function(...)
    --         local hammerspoon = application.applicationsForBundleID(hs.processInfo.bundleID)[1]
    --         local consoleWindow = hammerspoon:mainWindow()
    --         if consoleWindow then
    --             local consoleFrame = consoleWindow:frame()
    --             local screenFrame = screen.mainScreen():frame()
    --             local newConsoleFrame = {
    --                 x = screenFrame.x + (screenFrame.w - consoleFrame.w) / 2,
    --                 y = screenFrame.y + (screenFrame.h - consoleFrame.h),
    --                 w = consoleFrame.w,
    --                 h = consoleFrame.h
    --             }
    --             consoleWindow:setFrame(newConsoleFrame)
    --         end
    --     end,
    --     label = "Reseat",
    --     tooltip = "Reseat Console"
    -- },
    {
        id = "darkMode",
        image = _i_darkModeToggle,
        fn = function()
            console.darkMode(not console.darkMode())
            colorizeConsolePerDarkMode()
        end,
        label = "Dark Mode",
        tooltip = "Toggle Dark Mode"
    },
    {
        id = "hsDocsWeb",
        label = "HS Docs Web",
        tooltip = "Opens HS documentation website",
        image = _i_help,
        -- image = image.imageFromAppBundle("com.apple.Safari"),
        fn = function(bar, attachedTo, item)
            hs.urlevent.openURLWithBundle("https://www.hammerspoon.org/docs/index.html", "com.apple.Safari")
        end,
        default = true
    }
}
-- since they don't exist when the toolbar is first attached, we have to re-insert them here
--   consider adding something in _coresetup to check users config dir for toolbar additions?
console.toolbar():insertItem("darkMode", #console.toolbar():visibleItems() + 1):insertItem(
    "clear",
    #console.toolbar():visibleItems() + 1
):insertItem("editConfig", #console.toolbar():visibleItems() + 1):insertItem(
    "hsDocsWeb",
    #console.toolbar():visibleItems() + 1
):insertItem("reload2", #console.toolbar():visibleItems() + 1)

console.smartInsertDeleteEnabled(false)
colorizeConsolePerDarkMode()

return true -- so require has something to save
