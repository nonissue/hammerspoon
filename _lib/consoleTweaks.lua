-- largely lifted from
-- https://github.com/asmagill/hammerspoon-config-take2/blob/master/utils/_actions/consoleTweaks.lua
-- colors from:
-- https://rosepinetheme.com/palette
-- icons from SF Symbols, processed in affinity designer, filled with color: #626671
local console = require("hs.console")
local canvas = require("hs.canvas")
local image = require("hs.image")

-- for search functionality

local _c = canvas.new { x = 0, y = 0, h = 200, w = 200 }
_c[1] = {
    type = "image",
    image = image.imageFromName("NSShareTemplate"):template(false),
    transformation = canvas.matrix.translate(100, 100):rotate(180):translate(
        -100, -100)
}
local _i_reseatConsole = _c:imageFromCanvas()
_c:delete()

local imageBasePath = hs.configdir .. "/_lib/_assets/"

local _i_help = hs.image.imageFromPath(imageBasePath ..
    "questionmark.circle.pdf"):setSize({
    w = 20,
    h = 20
})
local _i_darkModeToggle = hs.image.imageFromPath(imageBasePath ..
    "moon.circle.pdf"):setSize(
    { w = 20, h = 20 })
local _i_clearConsole = hs.image.imageFromPath(imageBasePath ..
    "xmark.circle.pdf"):setSize({
    w = 20,
    h = 20
})
local _i_hsSettings =
    hs.image.imageFromPath(imageBasePath .. "gear.circle.pdf"):setSize({
        w = 20,
        h = 20
    })
local _i_reload = hs.image.imageFromPath(imageBasePath ..
    "arrow.counterclockwise.circle.pdf"):setSize(
    { w = 20, h = 20 })
local _i_editConfig = hs.image.imageFromPath(imageBasePath ..
    "hammer.circle.pdf"):setSize({
    w = 20,
    h = 20
})

local colorizeConsolePerDarkMode = function ()
    if console.darkMode() then
        hs.console.alpha(.98)
        hs.console.consoleCommandColor({ hex = "#f6c177" })
        hs.console.consolePrintColor({ hex = "#AEABC1" })
        hs.console.consoleResultColor({ hex = "#c4a7e7" })
        hs.console.inputBackgroundColor({ hex = "#222222" })
        hs.console.outputBackgroundColor({ hex = "#111111" })
        hs.console.windowBackgroundColor {
            list = "System",
            name = "windowBackgroundColor"
        }
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
        hs.console.consoleCommandColor({ hex = "#7D1131" })
        hs.console.consolePrintColor({ hex = "#575279" })
        hs.console.consoleResultColor({ hex = "#286983" })
        hs.console.inputBackgroundColor({ hex = "#faf4ed" })
    end
end

console.behaviorAsLabels({ "moveToActiveSpace" })
-- console.behaviorAsLabels({"canJoinAllSpaces"})
-- console.titleVisibility("hidden")

-- 26-01-11
-- This adds our custom features to the list of available toolbar controls
-- However, I think it happens after hammerspoon loads, so they dont appear visually
-- on HS fresh start or after our autoreload function runs. See note from asmagills below
console.toolbar():addItems {
    {
        id = "clear",
        image = _i_clearConsole,
        fn = function (...) console.clearConsole() end,
        label = "Clear",
        tooltip = "Clear Console",
        default = true
    }, {
    id = "reload2",
    image = _i_reload,
    fn = function (...) hs.reload() end,
    label = "Reload",
    tooltip = "Reload config",
    default = true
}, {
    -- edit config in editor of choice, added by me
    id = "editConfig",
    label = "Edit HS Config",
    tooltip = "Opens HS config in VSCode",
    image = _i_editConfig,
    fn = function (bar, attachedTo, item)
        hs.execute("/usr/local/bin/code ~/.hammerspoon")
    end,
    default = true
}, {
    id = "darkMode",
    image = _i_darkModeToggle,
    fn = function ()
        console.darkMode(not console.darkMode())
        colorizeConsolePerDarkMode()
    end,
    label = "Dark Mode",
    tooltip = "Toggle Dark Mode"
}, {
    id = "hsDocsWeb",
    label = "HS Docs Web",
    tooltip = "Opens HS documentation website",
    image = _i_help,
    fn = function (bar, attachedTo, item)
        hs.urlevent.openURLWithBundle(
            "https://www.hammerspoon.org/docs/index.html",
            "com.apple.Safari")
    end,
    default = true
}
}

-- --------------------------------------------------------------------------
-- asmagill note from original file:
-- since they don't exist when the toolbar is first attached, we have to re-insert them here
--   consider adding something in _coresetup to check users config dir for toolbar additions?
-- --------------------------------------------------------------------------
-- [26-01-11] nonissue: so this breaks on 1.1.10 when our autoreload function fires
-- I'm not quite sure why. Without the snippet below, our buttons are available but
-- don't appear in the toolbar. If it is uncommented, they work on initial app load,
-- but on reload we get an error
--
-- 026-01-11 22:58:45: *** ERROR: NSInternalInconsistencyException: NSToolbar 0x9d3ba8e00 already contains an item with the identifier darkMode. Duplicate items of this type are not allowed.
-- not sure if it is related to a change in 1.1.10 or something i broke (though haven't changed much / anything here in a while)
-- i tried playing around with different ways of fixing the hs.console.toolbar directly as it is a hs.webview.toolbar object
-- but it's not a TRUE hs.webview.toolbar, so it's kind of janky
--
-- the bug also could be caused by my reload function, which is super old and janky anyway
-- i think i added it before hs.reload() or the reload spoon existed. My config dir is a quite unusual
-- so im not sure if we can drop in something better

-- console.toolbar():insertItem("darkMode", #console.toolbar():visibleItems() + 1)
--     :insertItem("clear", #console.toolbar():visibleItems() + 1):insertItem(
--     "editConfig", #console.toolbar():visibleItems() + 1):insertItem(
--     "hsDocsWeb", #console.toolbar():visibleItems() + 1):insertItem(
--     "reload2", #console.toolbar():visibleItems() + 1)

console.smartInsertDeleteEnabled(false)
colorizeConsolePerDarkMode()

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "y", function ()
    hs.toggleConsole()
    hs.window.frontmostWindow():focus()
end)

return true -- so require has something to save
