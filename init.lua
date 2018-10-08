------------------------------------------------------------------------------
-- init.lua
------------------------------------------------------------------------------
-- By: Andy Williams / hammerspoon [ at ] nonissue dot org
------------------------------------------------------------------------------
-- A hammerspoon config
-- If you have concerns (about my sanity or anything else) feel free to
-- email me at the above address
------------------------------------------------------------------------------

-- load basic modules / utils first
-- that don't need to be spoons
package.path = package.path .. ";lib/?.lua"
styles = require("styles")
utils = require("utilities")

-- bind our alert style to default alert style
for k, v in pairs(styles.alert_default) do
    hs.alert.defaultStyle[k] = v
end

hs.logger.defaultLogLevel = "error"

hs.console.darkMode(false)
if hs.console.darkMode() then
    hs.console.outputBackgroundColor{ white = 0.1, alpha = 0.9}
    hs.console.consoleCommandColor{ white = 1 }
    hs.console.alpha(1)
else
    hs.console.outputBackgroundColor{ white = 1, alpha = 0.9}
    hs.console.consoleCommandColor{ white = 0.1 }
    hs.console.alpha(1)
end

-- yada yada
hostname = hs.host.localizedName()
hs_config_dir = os.getenv("HOME") .. "/.hammerspoon/"

-- recall hist
hs.shutdownCallback = function() hs.settings.set('history', hs.console.getHistory()) end
hs.console.setHistory(hs.settings.get('history'))

-- a MUST / disables window movement jank
hs.window.animationDuration = 0

-- aliases
i = hs.inspect
fw = hs.window.focusedWindow
bind = hs.hotkey.bind
clear = hs.console.clearConsole
reload = hs.reload
pbcopy = hs.pasteboard.setContents

-- hotkey groups
local mash = {"cmd", "alt", "ctrl"}
local hyper = {"cmd", "alt"}
local alt = {"alt"}

-- load scratch stuff
package.path = package.path .. ";scratch/?.lua"
-- egpu = require("egpu")

-- TODO: Let user enable/display spoons as desired.
-- i feel like these two should be spoons
-- because they rely on watchers
-- TODO: Move the below to spoons
hs_reload = require("hammerspoon_config_reload")
hs_reload.init()
-- burnrate = require("burnrate")
-- burnrate.init()

hs.loadSpoon("SystemContexts")

hs.loadSpoon("SafariKeys")
local safariHotkeys = {
    tabToNewWin = {mash, "T"},
    mailToSelf = {mash, "U"},
    mergeAllWindows = {mash, "M"},
    pinOrUnpinTab = {hyper, "P"},
    cycleUserAgent = {mash, "7"}
}
-- TODO: use default hotkeys
spoon.SafariKeys:bindHotkeys(safariHotkeys)

hs.loadSpoon("PaywallBuster")
-- TODO: use default hotkeys
hs.hotkey.bind(mash, "B", function() spoon.PaywallBuster:show() end)

hs.loadSpoon("Zzz")
spoon.Zzz:init()
-- TODO: use default hotkeys
hs.hotkey.bind(mash, "S", function() spoon.Zzz.chooser:show() end)

hs.loadSpoon("Resolute")
spoon.Resolute:init()
-- TODO: use default hotkeys
hs.hotkey.bind(mash, "L", function() spoon.Resolute:show() end)

hs.loadSpoon("Fenestra")
spoon.Fenestra:bindHotkeys(spoon.Fenestra.defaultHotkeys)


hs.loadSpoon("Crib")
spoon.Crib:bindHotkeys(spoon.Crib.defaultHotkeys)

-- hs.loadSpoon("eGPU")
-- spoon.eGPU:start()
--- end of spoons loading

-- random stuff
-- TODO: move these to chooser?
local yay = "ᕙ(⇀‸↼‶)ᕗ"
local boo = "ლ(ಠ益ಠლ)"
local kirby = "¯\\_(ツ)_/¯"

local function showKirby()
    hs.alert(kirby, styles.alert_loader, 5)
    hs.pasteboard.setContents("¯\\_(ツ)_/¯")
end

hs.hotkey.bind(mash, "K", showKirby)
hs.hotkey.showHotkeys(mash, "space")
hs.hotkey.bind(mash, "y", function() hs.toggleConsole() end)
