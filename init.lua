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
package.path = package.path .. ";lib/?.lua"
local styles = require("styles")
local utils = require("utilities")
require("hs.image")

-- bind our alert style to default alert style
for k, v in pairs(styles.alert_default) do
    hs.alert.defaultStyle[k] = v
end

if not hs.ipc.cliStatus() then
    local cliInstallResult = hs.ipc.cliInstall()
    if cliInstallResult then
        require('hs.ipc')
    else
        hs.alert('hs.ipc error!')
    end
else
    require('hs.ipc')
end

-- set logger level
hs.logger.defaultLogLevel = "debug"

-- This is great, disables all the superfluous hotkey logging
require("hs.hotkey").setLogLevel("warning")

-- Add WIP Spoons to path
package.path = hs.configdir .. "/WIP/?.spoon/init.lua;" .. package.path

-- Add WIP files to path
package.path = package.path .. ";WIP/?.lua"
-- require("sql3-test")
hs.loadSpoon("QuickAdd")

-- chooserToolbar = require("chooserToolbar")

hostname = hs.host.localizedName()
hs_config_dir = os.getenv("HOME") .. "/.hammerspoon/"

-- a MUST / disables window movement jank
hs.window.animationDuration = 0

-- aliases
i = hs.inspect
fw = hs.window.focusedWindow
bind = hs.hotkey.bind
clear = hs.console.clearConsole
reload = hs.reload
pbcopy = hs.pasteboard.setContents
print_t = utils.print_r
print_r = utils.print_r

-- hotkey groups
local mash = {"cmd", "alt", "ctrl"}
local hyper = {"cmd", "alt"}

-- console window hotkey
hs.hotkey.bind(mash, "y", function() hs.toggleConsole() hs.window.frontmostWindow():focus() end)

-- load scratch stuff
-- package.path = package.path .. ";scratch/?.lua"

-- package.path = package.path .. ";WIP/?.spoon"
-- hs.loadSpoon("MenuTest.spoon")

-- TODO: Let user enable/display spoons as desired.
-- i feel like these two should be spoons
-- because they rely on watchers
-- TODO: Move the below to spoons
local hs_reload = require("hammerspoon_config_reload")
hs_reload.init()



------------------------------------------------------------------------------
--                              START OF SPOONS                             --
------------------------------------------------------------------------------
-- ControlEscape.spoon / https://github.com/jasonrudolph/ControlEscape.spoon
------------------------------------------------------------------------------
-- I wanted this to resolve my issues with my locking capslock key on my
-- AEKII m3501, but I don't think it does
-- It does replace Karabiner Elements for me though, which is nice!
-- EDIT: maybe check this
-- https://gist.github.com/zcmarine/f65182fe26b029900792fa0b59f09d7f
------------------------------------------------------------------------------
-- hs.loadSpoon('CTRLESC')
hs.loadSpoon('CTRLESC'):start()

------------------------------------------------------------------------------
-- Context.spoon / by me
------------------------------------------------------------------------------
-- Watches for wifi ssid changes + screen resolution changes
-- If changes are detected and match a series of rules
-- Systemwide settings are configured
-- For example:
--  * On wifi ssid change, if isn't one of our home networks
--    system is muted and screenlock is set to a short time
--
-- PARAMS:
-- [Optional] Accepts a boolean which dictates whether the menubar item is shown
-- Defaults to false if nothing is passed
------------------------------------------------------------------------------
hs.settings.set("homeSSIDs", {"BROMEGA", "ComfortInn VIP"})
hs.loadSpoon("Context"):start(false)

------------------------------------------------------------------------------
-- SafariKeys.spoon / by me
------------------------------------------------------------------------------
hs.loadSpoon("SafariKeys")

local safariHotkeys = {
    tabToNewWin = {mash, "T"},
    mailToSelf = {mash, "U"},
    mergeAllWindows = {mash, "M"},
    pinOrUnpinTab = {hyper, "P"},
    cycleUserAgent = {mash, "7"},
    addToReadingList = {mash, "R"}
}

 -- TODO: use default hotkeys
spoon.SafariKeys:bindHotkeys(safariHotkeys)

------------------------------------------------------------------------------
-- PaywallBuster.spoon / by me
------------------------------------------------------------------------------
-- Ultimately this probably isn't necessary, but I do occasionally use it
------------------------------------------------------------------------------
hs.loadSpoon("PaywallBuster")
hs.hotkey.bind(mash, "B", function() spoon.PaywallBuster:show() end)

------------------------------------------------------------------------------
-- Zzz.spoon / by me
------------------------------------------------------------------------------
-- Sleep timer, puts computer to sleep after an interval
-- Shows a countdown in the menubar
-- Can be triggered from menubar
-- Menubar also provides snooze/shorten functions
-- There is also a modal to let users enter custom times
------------------------------------------------------------------------------
hs.loadSpoon("Zzz")
-- TODO: use default hotkeys
hs.hotkey.bind(mash, "S", function() spoon.Zzz.chooser:show() end)

-- hs.loadSpoon("Timers")


------------------------------------------------------------------------------
-- Resolute.spoon / by me
------------------------------------------------------------------------------
-- Menubar item + modal for quickly changing display resolution
-- Currently, you have to specify the choices manually
-- May change that in future
------------------------------------------------------------------------------
-- TODO: use default hotkeys
hs.loadSpoon("Resolute")
-- hs.hotkey.bind(mash, "L", function() spoon.Resolute:show() end)
-- spoon.Resolute:bindHotkeys(spoon.Resolute.defaultHotkeys)
hs.hotkey.bind(mash, "L", function() spoon.Resolute:show() end)

------------------------------------------------------------------------------
-- Fenestra.spoon / by me
------------------------------------------------------------------------------
-- My window management stuff
-- Resize active windows, move stuff between monitors, etc
------------------------------------------------------------------------------
hs.loadSpoon("Fenestra")
spoon.Fenestra:bindHotkeys(spoon.Fenestra.defaultHotkeys)

------------------------------------------------------------------------------
-- [WIP] AfterDark.spoon / by me
------------------------------------------------------------------------------
-- Dark mode toggle in menubar
-- PARAMS:
-- [Optional] Accepts a boolean which dictates whether the menubar item is shown
-- Defaults to false if nothing is passed
------------------------------------------------------------------------------
hs.loadSpoon("AfterDark"):start({showMenu = true})


------------------------------------------------------------------------------
-- Crib.spoon / by me
------------------------------------------------------------------------------
-- WIP, not finished at all
------------------------------------------------------------------------------
-- hs.loadSpoon("Crib")
-- spoon.Crib:bindHotkeys(spoon.Crib.defaultHotkeys)
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--                                END OF SPOONS                             --
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--                                NONSENSE                                  --
------------------------------------------------------------------------------


-- God this was painful to get working
-- and i should have just passed the code directly to hammerspoon using `hs -c`
-- anyway, this sends an alert when simon notices a server down
-- hs -m simon -c test
local function simonMsgHandler(_, msgID, msg)
    if msgID == 900 then
        -- the message sent will be a mathematical equation; the original ipc will evaluate it because it ignored
        -- the msgid.  We send back a version string instead
        return "version:2.0a"
    end
    -- print(msgID)
    local instanceID, arguments = msg:match("^([%w-]+)\0(.*)$")

    if msgID == 100 then
        -- hs.alert('msg is 100?')
        -- hs.alert('arguements are: ' .. arguments)
    elseif arguments then
        -- hs.alert(msg)
        hs.alert(arguments)

        -- hs.alert('arguments if something else' .. arguments)
        -- hs.alert('msgID' .. msgID)
        -- hs.alert(arguments)
        -- print(msg)
    end
    if arguments then
        print("arguments: " .. arguments)
    else
        print("messages: " .. msg)
    end
    -- hs.alert('local')
    -- _:delete()
    -- print(msg)
    -- print(msgID)
    -- print(i(arguments))
    -- hs.alert(msg)
    -- hs.alert(msgID)
    -- hs.alert(arguments)
    -- print(msgID)
    -- return "msg: " .. msg
    -- return false
    return
end

simonLocal = hs.ipc.localPort('simon', simonMsgHandler)
simonRemote = hs.ipc.remotePort('simon')





-- random stuff
-- local yay = "ᕙ(⇀‸↼‶)ᕗ"
-- local boo = "ლ(ಠ益ಠლ)"
local kirby = "¯\\_(ツ)_/¯"

local function showKirby()
    hs.alert(kirby, styles.alert_loader, 5)
    hs.pasteboard.setContents("¯\\_(ツ)_/¯")
end

hs.hotkey.bind(mash, "K", showKirby)
hs.hotkey.showHotkeys(mash, "space")


-- COPIED FROM: https://github.com/af/dotfiles/blob/63370411e709e006b26f07781376da1e6d7ae2c8/hammerspoon/utils.lua#L51
-- Close all open notifications
local function dismissAllNotifications()
    local success, result = hs.applescript([[
        tell application "System Events"
        tell process "Notification Center"
            set theWindows to every window
            repeat with i from 1 to number of items in theWindows
                set this_item to item i of theWindows
                try
                    click button 1 of this_item
                end try
            end repeat
        end tell
    end tell
    ]])
    if not success then
        hs.logger.e("Error dismissing notifcations")
        hs.logger.e(result)
    end
end

hs.hotkey.bind(mash, "N", dismissAllNotifications)

-- clipboard stcuff

-- https://github.com/CommandPost/CommandPost/blob/45f1cbfb6f97f7a47de9a5db05fd89c49a85ea6a/src/plugins/finalcutpro/text2speech/init.lua
-- https://github.com/heptal/dotfiles/blob/9f1277e162a9416b5f8b4094e87e7cd1fc374b18/roles/hammerspoon/files/pasteboard.lua
-- https://github.com/search?q=hs.pasteboard+extension%3Alua&type=Code
-- https://github.com/ahonn/dotfiles/blob/c5e2f2845924daf970dce48aecbae48e325069a9/hammerspoon/modules/clipboard.lua
hs.loadSpoon("Clippy")
spoon.Clippy:start()


hs.console.titleVisibility("hidden")
hs.console.consolePrintColor({blue = 1})
hs.console.consoleCommandColor({red = 1})
hs.console.inputBackgroundColor({white = 1, alpha = 1})
hs.console.windowBackgroundColor({white = 1})
hs.console.toolbar(nil)

-- hs.textDroppedToDockIconCallback()
-- hs.dockIconClickCallback()
-- hs.dockIcon(true)
-- initial testing with using the 'send to' contextual menu functionality
hs.textDroppedToDockIconCallback = function(value)
    hs.alert(string.format("Text dropped to dock icon: %s", value))
end


-- hs.loadSpoon("PlexMini")
-- require("new_console")