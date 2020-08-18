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
package.path = package.path .. ";_lib/?.lua"
local styles = require("styles")
local utils = require("utilities")

-- TODO: Let user enable/display spoons as desired.
-- i feel like these two should be spoons
-- because they rely on watchers
-- TODO: Move the below to spoons
local hs_reload = require("hammerspoon_config_reload")
hs_reload.init()

-- console customization and UI is located elsewhere, so we import it
require("console")

-- Add WIP Spoons to path
package.path = hs.configdir .. "/WIP/?.spoon/init.lua;" .. package.path

-- Add my Spoons to path
package.path = hs.configdir .. "/_Spoons/?.spoon/init.lua;" .. package.path

-- Add WIP files to path
package.path = package.path .. ";WIP/?.lua"

-- load scratch stuff
package.path = package.path .. ";_scratch/?.lua"

-- bind our alert style to default alert style
for k, v in pairs(styles.alert_default) do
    hs.alert.defaultStyle[k] = v
end

-- check for cli, and if missing, install
-- can't remember if/what depends on this
if not hs.ipc.cliStatus() then
    local cliInstallResult = hs.ipc.cliInstall()
    if cliInstallResult then
        require("hs.ipc")
    else
        hs.alert("hs.ipc error!")
    end
else
    hs.ipc.cliSaveHistory(true)
    require("hs.ipc")
end

-- set logger level
hs.logger.defaultLogLevel = "debug"

-- This is great, disables all the superfluous hotkey logging
require("hs.hotkey").setLogLevel("warning")

-- a MUST / disables window movement jank
hs.window.animationDuration = 0

-- aliases/globals
i = hs.inspect
fw = hs.window.focusedWindow
bind = hs.hotkey.bind
clear = hs.console.clearConsole
reload = hs.reload
pbcopy = hs.pasteboard.setContents
print_t = utils.print_r
print_r = utils.print_r
hostname = hs.host.localizedName()

-- hotkey groups
local mash = {"cmd", "alt", "ctrl"}

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
hs.loadSpoon("CTRLESC"):start()

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
-- [Optional] Accepts a boolean which dictates whether the menubar item is shownd
-- Defaults to false if nothing is passed
------------------------------------------------------------------------------
-- todo: move this all elsewhere so it's private
hs.settings.set("homeSSIDs", {"BROMEGA", "ComfortInn VIP", "BROMEGA-5", "1614 Apple II", "RamadaGuest"})
local drives = {"ExternalSSD", "Win-Stuff", "Photos"}
-- display ids apparently change? could be flux changing profile...
local display_ids = {mbp = 2077750265, cinema = 69489832, sidecar = 4128829}

hs.settings.set("context.drives", drives)
hs.settings.set("context.display_ids", display_ids)

hs.loadSpoon("Context"):start({showMenu = true, display_ids = display_ids, drives = drives})
-- end todo
------------------------------------------------------------------------------
-- SafariKeys.spoon / by me
------------------------------------------------------------------------------
hs.loadSpoon("SafariKeys")
spoon.SafariKeys:bindHotkeys(spoon.SafariKeys.defaultHotkeys)

------------------------------------------------------------------------------
-- PaywallBuster.spoon / by me
------------------------------------------------------------------------------
-- Ultimately this probably isn't necessary, but I do occasionally use it
------------------------------------------------------------------------------
hs.loadSpoon("PaywallBuster")
-- TODO: bind default hotkey in spoon
hs.hotkey.bind(
    mash,
    "B",
    function()
        spoon.PaywallBuster:show()
    end
)

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
hs.hotkey.bind(
    mash,
    "S",
    function()
        spoon.Zzz.chooser:show()
    end
)

------------------------------------------------------------------------------
-- Resolute.spoon / by me
------------------------------------------------------------------------------
-- Menubar item + modal for quickly changing display resolution
-- Currently, you have to specify the choices manually
-- May change that in future
------------------------------------------------------------------------------
-- TODO: use default hotkeys
hs.loadSpoon("Resolute")
spoon.Resolute:bindHotkeys(spoon.Resolute.defaultHotkeys)

------------------------------------------------------------------------------
-- Fenestra.spoon / by me
------------------------------------------------------------------------------
-- My window management stuff
-- Resize active windows, move stuff between monitors, etc
------------------------------------------------------------------------------
hs.loadSpoon("Fenestra")
spoon.Fenestra:bindHotkeys(spoon.Fenestra.defaultHotkeys)

------------------------------------------------------------------------------
-- AfterDark.spoon / by me
------------------------------------------------------------------------------
-- Dark mode toggle in menubar
-- PARAMS:
-- [Optional] Accepts a boolean which dictates whether the menubar item is shown
-- Defaults to false if nothing is passed
--
-- NOTE: 19-11-01 Interesting proof of concept, but I don't really use it
-- So disabled for now
------------------------------------------------------------------------------
hs.loadSpoon("AfterDark"):start({showMenu = true, animate = true})

-- hs.loadSpoon("ToggleDarkMode"):start({showMenu = true})
hs.loadSpoon("EasyTOTP")

------------------------------------------------------------------------------
-- Clippy.spoon / by me
------------------------------------------------------------------------------
-- Copy screenshot to clipboard and save to disk
------------------------------------------------------------------------------
hs.loadSpoon("Clippy"):start()

------------------------------------------------------------------------------
-- Crib.spoon / by me
------------------------------------------------------------------------------
-- WIP, not finished at all
------------------------------------------------------------------------------
-- hs.loadSpoon("Crib")
-- spoon.Crib:bindHotkeys(spoon.Crib.def aultHotkeys)
------------------------------------------------------------------------------

-- WIP Stuff
-- hs.loadSpoon("PlexMini")
-- require("sql3-test")
-- hs.loadSpoon("QuickAdd")
-- require("callbacks")
-- hs.loadSpoon("SysInfo")
-- spoon.SysInfo:startFor(0.1)
hs.loadSpoon("Alarm")

-- ht = hs.loadSpoon("HammerText")
-- ht.keywords = {
--     jjem = "andy@nonissue.org",
--     jjsr = "site:reddit.com ",
--     jjname = "Max Rydahl Andersen",
--     jjdate = function()
--         return os.date("%B %d, %Y")
--     end
-- }
-- ht:start()

------------------------------------------------------------------------------
--                                END OF SPOONS                             --
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--                                NONSENSE                                  --
------------------------------------------------------------------------------

-- random
local emojis = {
    {
        ["text"] = "¯\\_(ツ)_/¯",
        ["subText"] = "Kirby",
        ["uuid"] = "0001"
    },
    {
        ["text"] = "ᕙ(⇀‸↼‶)ᕗ",
        ["subText"] = "yay",
        ["uuid"] = "0002"
    },
    {
        ["text"] = "ლ(ಠ益ಠლ)",
        ["subText"] = "boo",
        ["uuid"] = "0003"
    }
}

local function emojiChooserCallback(choice)
    hs.alert(choice["text"])
    hs.pasteboard.setContents(choice["text"])
    hs.eventtap.keyStrokes(choice["text"])
end

local emojiChooser =
    hs.chooser.new(
    function(choice)
        if not (choice) then
            return
        else
            emojiChooserCallback(choice)
        end
    end
):rows(3):width(20):choices(emojis):searchSubText(true)

hs.hotkey.bind(
    mash,
    "K",
    function()
        emojiChooser:show()
    end
)

local inflates = {
    {
        ["text"] = "site:reddit.com ",
        ["subText"] = "sr site reddit search",
        ["uuid"] = "0001"
    },
    {
        ["text"] = "123 Fake Street",
        ["subText"] = "address",
        ["uuid"] = "0002"
    },
    {
        ["text"] = "John Queue Smith",
        ["subText"] = "name",
        ["uuid"] = "0003"
    }
}

local function textInflaterCallback(choice)
    hs.alert(choice["text"])
    hs.pasteboard.setContents(choice["text"])
    hs.eventtap.keyStrokes(choice["text"])
end

local function textInflater(choice)
    hs.alert(choice["text"])
    hs.pasteboard.setContents(choice["text"])
    hs.eventtap.keyStrokes(choice["text"])
end

local textInflaterChooser =
    hs.chooser.new(
    function(choice)
        if not (choice) then
            return
        else
            textInflaterCallback(choice)
        end
    end
):rows(3):width(20):choices(inflates):searchSubText(true)

hs.hotkey.bind(
    mash,
    "J",
    function()
        textInflaterChooser:show()
    end
)

local FRemap = require("foundation_remapping")
local remapper = FRemap.new()

-- hidutil property -m 'keyboard' -g 'Product'
-- hidutil property -m '{"ProductID":632}' --get "Product"

remapper:remap("[", "]") -- when press a, type b
remapper:unregister()
-- https://github.com/cfenollosa/aekii
-- https://github.com/RehabMan/OS-X-Voodoo-PS2-Controller/issues/103#issuecomment-320736223
-- figure out locking caps lock keycode, then try and rebind it?
-- https://github.com/pqrs-org/Karabiner-Elements/issues/2035

-- Thanks to qaisjp, giving up caps lock entirely do the trick for me. I only used caps lock for IME switching, which can be worked around by a shortcut preference at macOS preference ➤ keyboard ➤ shortcuts ➤ 'Select the previous input source'.

-- If your favorite shortcut is not ordinary, e.g. Left⇧ + Right⇧, do it with an extra step.

-- In Karabiner map your favorite combination to F19
-- Bind 'Select the previous input source' to F19

-- https://apple.stackexchange.com/questions/283252/how-do-i-remap-a-key-in-macos-sierra-e-g-right-alt-to-right-control

touchbar = require("hs._asm.undocumented.touchbar")

-- quick and dirty example -- I'll put up a better one shortly
-- note that not all of the methods used here have an effect since we only support modal touch bars atm

-- myTouchbar = require("touchbar")
-- quick and dirty example -- I'll put up a better one shortly
-- note that not all of the methods used here have an effect since we only support modal touch bars atm

tb = require("hs._asm.undocumented.touchbar")

bar = tb.bar.new()

items, allowed, required, default = {}, {}, {}, {}
for i = 1, 10, 1 do
    local label = "item" .. tostring(i)
    table.insert(
        items,
        tb.item.newButton(label, hs.image.imageFromName(hs.image.systemImageNames.Bonjour), label):callback(
            function(item)
                print("Button " .. tostring(i) .. " was pressed")
                if i == 1 then
                    bar:minimizeModalBar()
                end -- will return icon to system tray
                if i == 2 then
                    bar:dismissModalBar()
                end -- will *NOT* return icon to system tray
            end
        )
    )
    if i < 3 then
        table.insert(required, label)
    end
    if i < 5 then
        table.insert(default, label)
    end
    table.insert(allowed, label)
end

for k, v in pairs(tb.bar.builtInIdentifiers) do
    table.insert(allowed, v)
end

bar:templateItems(items):customizableIdentifiers(allowed):requiredIdentifiers(required):defaultIdentifiers(default):customizationLabel(
    "sample"
):escapeKeyReplacement("item3")
--    :principleItem("item3")

closeBox = true

sampleCallback = function(self)
    self:presentModalBar(bar, closeBox)
end

sysTrayIcon =
    tb.item.newButton(hs.image.imageFromName(hs.image.systemImageNames.ApplicationIcon), "HSSystemButton"):callback(
    sampleCallback
):addToSystemTray(true)
