--- === Fenestra ===
--- A spoon for quickly changing the resolution on a Macbook Pro either through
--- a menubar menu, or using hs.chooser. I often switch between the native res (1680x1050)
--- and the 'larger' option (1440x900).
---
--- You can also use this to switch resolutions on other displays
---
--- Currently, the list of resolutions you can choose from has to be created manually.
--- As an example, the options I have selected are available below in the table 'mbpr15'

--- State:
--- mbpr15 table
--- I think that's it?

--- TODO:

--- NOTE: ONLY initialize if using mbpr2016. Don't care about ACD30 or Acer 4k really...
---
--- Anywhere 'targetDisplay' var is used, extract logic to check which display we care about
--- mainScreen -> Focused screen, so we good there
--- How do we handle multiple displays?
--- can menubar items be different on different screens?
---     • OOOH: https://github.com/Hammerspoon/hammerspoon/issues/2332
--- or add refresh option?
--- [x] update menubar icons
--- [ ] Remove logic that updates menubarIcon when resolution changes, since it is the same (menu still updates)
--- [ ] hotkey to invoke menu
---     • spoon.Resolute.menubar:popupMenu(hs.geometry.rect(1080.0,28.0,0.0,0.0), true)
---     • get coords with spoon.Resolute.menubar:frame(), then need to shift down ~28.0

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
obj.resMenu = {}
obj.current = nil

-- -- Utility for getting current paths
local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

obj.spoonPath = script_path()

-- change icon to match circle icons
-- UPDATE: Using TV icon across all resolutions as it's simpler
obj.menubarIcon = hs.image.imageFromPath(obj.spoonPath .. "/bold.tv.circle.fill.pdf"):setSize({w = 20, h = 20})

obj.defaultHotkeys = {
    showResolute = {{"ctrl", "cmd", "alt"}, "L"}
}

-- We can get available modes with hs.screen:availableModes()
-- But the list is too long, and we only care about a few options
-- Might be nice to automatically choose some based on screen,
-- but it's tough to know what will look good
-- NOTE: Is used for both chooserChoices and menubar menuitems

local mbp14 = {
    {
        ["id"] = 1,
        ["image"] = obj.menubarIcon,
        ["subText"] = "1352 x 878",
        ["text"] = "Less",
        ["res"] = {
            h = 878,
            s = 2,
            w = 1352
        }
    },
    {
        ["id"] = 2,
        ["image"] = obj.menubarIcon,
        ["subText"] = "1512 x 982",
        ["text"] = "Default",
        ["res"] = {
            h = 982,
            s = 2,
            w = 1512
        }
    },
    {
        ["id"] = 3,
        ["image"] = obj.menubarIcon,
        ["subText"] = "1800 x 1169",
        ["text"] = "More",
        ["res"] = {
            h = 1169,
            s = 2,
            w = 1800
        }
    }
}

local LGUltrafine24 = {
    {
        ["id"] = 1,
        ["image"] = obj.menubarIcon,
        ["text"] = "Less",
        ["subText"] = "1600 x 900",
        ["res"] = {
            h = 900,
            s = 2.0,
            w = 1600
        }
    },
    {
        ["id"] = 2,
        ["image"] = obj.menubarIcon,
        ["text"] = "Default",
        ["subText"] = "1920 x 1080",
        ["res"] = {
            h = 1080,
            s = 2.0,
            w = 1920
        }
    },
    {
        ["id"] = 3,
        ["image"] = obj.menubarIcon,
        ["subText"] = "2304 x 1296",
        ["text"] = "More Space",
        ["res"] = {
            h = 1296,
            s = 2.0,
            w = 2304
        }
    }
}

local unknownDisplay = {}

obj.displayArrangement = {
    current = {
        displays = {
            hs.screen.allScreens()
        },
        number = #hs.screen.allScreens()
    },
    previous = {
        displays = {{}},
        number = nil
    }
}

function obj:debugHelper()
    obj.logger.setLogLevel("debug")
    obj.logger.d("MainScreen: " .. hs.screen.mainScreen():name())
    obj.logger.d("PrimaryScreen: " .. hs.screen.primaryScreen():name())
    obj.logger.d("#hs.screen.allScreens(): " .. #hs.screen.allScreens())
end

function obj:bindHotkeys(keys)
    local hotkeys = keys or obj.defaultHotkeys

    hs.hotkey.bindSpec(
        hotkeys["showResolute"],
        function()
            self:show()
        end
    )
end

function obj:updateDisplayArrangement()
    obj.displayArrangement.previous = obj.displayArrangement.current

    obj.displayArrangement.current = {
        displays = {hs.screen.allScreens()},
        number = #hs.screen.allScreens()
    }
end

function obj:chooserCallback(choice)
    self.changeRes(choice["res"])
end

function obj.getDisplayOptions()
    local targetDisplay

    if (hs.screen.primaryScreen():name() == "Cinema HD") then
        targetDisplay = cinema30
    elseif (hs.screen.primaryScreen():name() == "Built-in Retina Display") then
        targetDisplay = mbp14
    elseif (hs.screen.primaryScreen():name() == "LG UltraFine") then
        targetDisplay = LGUltrafine24
    else
        targetDisplay = unknownDisplay
    end

    return targetDisplay
end

function obj.changeRes(choice)
    print(i(choice))

    local w = choice["w"]
    local h = choice["h"]
    local s = choice["s"]

    local freq = 120
    if (hs.screen.primaryScreen():name() == "LG UltraFine") then
        freq = 60
    end

    -- change screen resolution
    hs.screen.mainScreen():setMode(w, h, s, freq, 8)

    -- The code below updates the menubar menu to indicate new resolution
    -- The menubar menu doesn't refresh automatically, so we generate
    -- a new table of options, and then replace the existing one
    -- Not efficient, but there doesn't seem to be a delay and
    -- I can't think of a better way to do this

    -- clear current resmenu
    obj.resMenu = {}
    -- obj:generateMenubarItems(obj.getDisplayOptions())
    obj.menubar:setIcon(obj.menubarIcon)
    obj.menubar:setMenu(obj:generateMenubarItems(obj.getDisplayOptions()))
end

function obj:generateMenubarItems(displayOptions)
    local newMenubarItems = {{title = hs.screen.primaryScreen():name(), disabled = true}, {title = "-"}}

    for i = 1, #displayOptions do
        table.insert(
            newMenubarItems,
            {
                title = hs.styledtext.new("" .. displayOptions[i]["text"]),
                fn = function()
                    self.changeRes(displayOptions[i]["res"])
                end,
                checked = false
            }
        )
        -- make menubar item menu indicate current res
        if
            hs.screen.mainScreen():currentMode().w == displayOptions[i]["res"].w and
                hs.screen.mainScreen():currentMode().h == displayOptions[i]["res"].h
         then
            -- set new menu title reflecting current res
            obj.menubarIcon = displayOptions[i]["image"]
            -- indicate which submenu item is selected
            newMenubarItems[i + 2]["checked"] = true
        end
    end

    hs.fnutils.concat(
        newMenubarItems,
        {
            {title = "-"},
            {
                title = "Refresh",
                fn = function()
                    obj:init()
                end
            }
        }
    )

    return newMenubarItems
end

function obj.createMenubar(display)
    -- create menubar menu for current display
    obj.logger.d("generateDisplayOptions")

    -- obj.menubar = hs.menubar.new():setIcon(obj.menubarIcon):setMenu(hs.fnutils.concat(test, menuOptions))
    obj.menubar = hs.menubar.new():setIcon(obj.menubarIcon):setMenu(obj:generateMenubarItems(display))
end

function obj:show()
    -- added logic to show different resolution choices on different screens
    -- works on whichever screen is currently focused
    local targetDisplay
    if (hs.screen.primaryScreen():name() == "LG UltraFine") then
        targetDisplay = LGUltrafine24
    elseif (hs.screen.primaryScreen():name() == "Built-in Retina Display") then
        targetDisplay = mbp14
    else
        targetDisplay = unknownDisplay
    end

    self.resChooser:choices(targetDisplay)

    self.resChooser:show()
    return self
end

function obj:init()
    -- TODO: add logic to detect current display
    -- if using cinema display, don't show in menubar
    -- local targetDisplay
    obj.debugHelper()

    if (hs.screen.primaryScreen():name() == "Built-in Retina Display") and (#hs.screen.allScreens() == 1) then
        obj.logger.d("Single display detected")
        hs.alert("Resolute: MBPR Detected, loading...")
    elseif (hs.screen.primaryScreen():name() == "LG UltraFine") then
        obj.logger.d("\nMultiple Displays detected - " .. hs.screen.mainScreen():name())
        hs.alert("Resolute: LG UltraFine Detected, loading...")
    else
        obj.logger.e("pScreen: " .. hs.screen.primaryScreen():name())
        hs.alert("Resolute: Unknown display, not loading!", 1)
        return self
    end

    local targetDisplay = obj.getDisplayOptions()

    if self.menubar then
        self.menubar:delete()
    end

    if self.resMenu then
        self.resMenu = {}
    end

    if self.resChooser then
        self.resChooser:delete()
    end

    self.createMenubar(obj.getDisplayOptions())

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

    self.resChooser:choices(obj.getDisplayOptions())
    self.resChooser:rows(#obj.getDisplayOptions())

    self.resChooser:placeholderText("Select a resolution")
    self.resChooser:searchSubText(true)
    -- self.resChooser:width(40)
    -- self.resChooser:bgDark(false)

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
