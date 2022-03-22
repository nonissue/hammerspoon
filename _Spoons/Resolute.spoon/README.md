# Raw display info

```lua
-- local LGUltrafine24 = {
--     {
--         -- larger
--         depth = 8.0,
--         desc = "1600x900@2x 60Hz 8bpp",
--         freq = 60.0,
--         h = 900,
--         scale = 2.0,
--         w = 1600
--     },
--     {
--         -- default
--         depth = 8.0,
--         desc = "1920x1080@2x 60Hz 8bpp",
--         freq = 60.0,
--         h = 1080,
--         scale = 2.0,
--         w = 1920
--     },
--     {
--         -- more space
--         depth = 8.0,
--         desc = "2304x1296@2x 60Hz 8bpp",
--         freq = 60.0,
--         h = 1296,
--         scale = 2.0,
--         w = 2304
--     }
-- }
```

## Old Display Info

```lua
local mbpr15 = {
    {
        ["id"] = 2,
        ["image"] = obj.menubarIcon,
        ["subText"] = "1440x900",
        ["text"] = "Larger",
        ["res"] = {w = 1440, h = 900, s = 2}
    },
    {
        ["id"] = 3,
        ["image"] = obj.menubarIcon,
        ["subText"] = "1680x1050",
        ["text"] = "Default",
        ["res"] = {w = 1680, h = 1050, s = 2}
    },
    {
        ["id"] = 4,
        ["image"] = obj.menubarIcon,
        ["subText"] = "1920x1200",
        ["text"] = "Smaller",
        ["res"] = {w = 1920, h = 1200, s = 2}
    }
}

local acer4k = {
    -- {["id"] = 1, ["icon"] = "☳", ["subText"] = "1280x800", ["text"] = "Largest", ["res"] = {w = 1280, h = 800, s = 2}},
    {["id"] = 2, ["icon"] = "☱", ["subText"] = "1440x900", ["text"] = "Larger", ["res"] = {w = 1440, h = 900, s = 2}}
    -- {["id"] = 3, ["icon"] = "☲", ["subText"] = "1680x1050", ["text"] = "Default", ["res"] = {w = 1680, h = 1050, s = 2}},
    -- {["id"] = 4, ["icon"] = "☴", ["subText"] = "1920x1200", ["text"] = "Smaller", ["res"] = {w = 1920, h = 1200, s = 2}}
}

local cinema30 = {
    {
        ["id"] = 1,
        ["image"] = obj.menubarIcon,
        ["subText"] = "1920x1200",
        ["text"] = "1920x1200",
        ["res"] = {w = 1920, h = 1200, s = 1}
    },
    {
        ["id"] = 2,
        ["image"] = obj.menubarIcon,
        ["subText"] = "2560x1600",
        ["text"] = "Default",
        ["res"] = {w = 2560, h = 1600, s = 1}
    },
    {
        ["id"] = 3,
        ["image"] = obj.menubarIcon,
        ["subText"] = "2560x1440",
        ["text"] = "2560x1440",
        ["res"] = {w = 2560, h = 1440, s = 1}
    }
}
```
