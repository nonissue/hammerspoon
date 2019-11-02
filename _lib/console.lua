
local toolbar     = require"hs.webview.toolbar"
local console     = require"hs.console"
local image       = require"hs.image"
local fnutils     = require"hs.fnutils"
local application = require"hs.application"
local styledtext  = require"hs.styledtext"
local doc         = require"hs.doc"
local watchable   = require"hs.watchable"
local canvas      = require"hs.canvas"
-- local imageBasePath = hs.configdir .. "/_localAssets/images/"

-- local autoHideImage = function()
--     return imageBasePath .. (module.watchConsoleAutoClose:value() and "unpinned.png" or "pinned.png")
-- end

local consoleToolbar = {
    { id = "NSToolbarFlexibleSpaceItem" },
    {
        id = "cust",
        label = "customize",
        tooltip = "Modify Toolbar",
        fn = function(t, w, i)
            t:customizePanel()
        end,
        image = image.imageFromName("NSToolbarCustomizeToolbarItemImage")
    }
}

table.insert(consoleToolbar, {
    id = "hammerspoonDocumentation",
    label = "HS Documentation",
    tooltip = "Show HS Documentation Browser",
    image = image.imageFromName("NXHelpIndex"),
    fn = function(bar, attachedTo, item)
        local base = require"hs.doc.hsdocs"
        if not base._browser then
            base.help()
        else
            base._browser:show()
        end
    end,
    default = false,
})

table.insert(consoleToolbar, {
    id = "editConfig",
    label = "Edit HS Config",
    tooltip = "Opens HS config in VSCode",
    image = image.imageFromAppBundle('org.hammerspoon.Hammerspoon'),
    fn = function(bar, attachedTo, item)
        hs.execute("/usr/local/bin/code ~/.hammerspoon")
    end,
    default = false}
)

local makeModuleListForMenu = function()
    local searchList = {}
    for i,v in ipairs(doc._jsonForModules) do
        table.insert(searchList, v.name)
    end
    for i,v in ipairs(doc._jsonForSpoons) do
        table.insert(searchList, "spoon." .. v.name)
    end
    table.sort(searchList, function(a, b) return a:lower() < b:lower() end)
    return searchList
end

table.insert(consoleToolbar, {
    id = "searchID",
    label = "HS Doc Search",
    tooltip = "Search for a HS function or method",
    fn = function(t, w, i, text)
        if text ~= "" then require"hs.doc.hsdocs".help(text) end
    end,
    default = false,

    searchfield               = true,
    searchPredefinedMenuTitle = false,
    searchPredefinedSearches  = makeModuleListForMenu(),
    searchWidth               = 250,
})

local moduleListChanges = watchable.watch("hs.doc", "changeCount", function(w, p, k, o, n)
    if module.toolbar then
        module.toolbar:modifyItem{
            id = "searchID",
            searchPredefinedSearches = makeModuleListForMenu(),
        }
    end
end)

fnutils.each({
    { "Code",             "com.microsoft.VSCode", },
    { "Console",          "com.apple.Console", },
    -- { "Terminal",         "com.apple.Terminal" },
    { "Safari",           "com.apple.Safari" },
    { "iTerm",            "com.googlecode.iTerm2" },
    { "Activity",         "com.apple.ActivityMonitor" },
}, function(entry)
    local app, bundleID = table.unpack(entry)
    table.insert(consoleToolbar, {
        id = bundleID,
        label = app,
        tooltip = app,
        image = image.imageFromAppBundle(bundleID),
        fn = function(bar, attachedTo, item)
            application.launchOrFocusByBundleID(bundleID)
        end,
        default = true,
    })
end)

local myConsoleToolbar = toolbar.new("_asmConsole_001")
      :addItems(consoleToolbar)
      :canCustomize(true)
      :autosaves(true)
      :separator(true)
      :setCallback(function(...)
                        print("+++ Oops! You better assign me something to do!")
                   end)

hs.console.inputBackgroundColor({white = 1, alpha = 1})
hs.console.consoleCommandColor({blue = 1, alpha = 1})
hs.console.consolePrintColor({black = 1, alpha = 1})
hs.console.toolbar(myConsoleToolbar)

-- set hotkey for hiding and showing the console
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "y", function() hs.toggleConsole() hs.window.frontmostWindow():focus() end)