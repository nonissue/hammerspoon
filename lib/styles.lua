local obj = {}
obj.__index = obj

-- Metadata
obj.name = "alerts"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Move this to utilites!
function table.merge(tablelist)
    local newTable = {}

    for t = 1, #tablelist do
        for k, v in pairs(tablelist[t]) do
            newTable[k] = v
        end 
    end

    return newTable
end

function obj.createStyle(layout, font, color)
    local newStyle = table.merge({layout, font, color})
    return newStyle
end


obj.alert = {}

-- calculate size_base based on resolution?

-- dynamically generate sizes
function obj.createSizes(size_base, size_count)
    local sizes = {}
    size_count = size_count or 3
    for x = 1, size_count do
        table.insert(sizes,
        {
            textSize = size_base * 2,
            radius = size_base * 1,
            strokeWidth = size_base * 0.375 * 1.5,
        })
        size_base = size_base * 1.3
    end

    return sizes
end

obj.alert.sizes = obj.createSizes(11, 7)

obj.alert.colors = {
    default = {
        fillColor = {white = 1, alpha = 0.95},
        strokeColor = {hex = "#084887", alpha = 0.3},
        -- strokeColor = {hex = "#F58A07", alpha = 0.1},
        textColor = {hex = "#084887"},
        textStyle = {shadow = {offset = {w = 1, h = -1}, blurRadius = 5, color = {black = 0.5, alpha= 0.15}}, kerning = -1}
    },
    darkmode = {
        fillColor = {hex = "#0B0B11", alpha = 0.9},
        strokeColor = {hex = "#084887", alpha = 0.3},
        textColor = {hex = "#F8FBE6"},
        textStyle = {shadow = {offset = {w = 2, h = -2}, blurRadius = 10, color = {hex = "#F8FBE6", alpha= 0.3}}, kerning = -1}
    },
    warning = {
        fillColor = {red = 1, alpha = 1},
        strokeColor = {white = 1, alpha = 0.25},
        textColor = {red = 1, alpha = 1},
        textStyle = {
            color = {white = 1, alpha = 1},
        }
    },
    loader = {
        fillColor = {white = 0.1, alpjjsvsha = 0.9},
        strokeColor = {white = 0.3, alpha = 0.8},
        textColor = {red = 1, alpha = 1},
        strokeWidth = 20,
        radius = 30,
        textStyle = {
            color = {white = 0.9, alpha = 1},
        }
    },
    success = {
        fillColor = {green = 0.5, alpha = 0.8},
        strokeColor = {white = 1, alpha = 0.25},
        textColor = {green = 1, alpha = 1},
        textStyle = {
            color = {white = 1, alpha = 1},
        }
    },
    tomfoolery = {
        fillColor = {white = 1, alpha = 0},
        strokeColor = {white = 1, alpha = 0},
        textColor = {red = 1, alpha = 1},
        radius = {5},
        textStyle = {
            color = {black = 1, alpha = 0},
            font = {name = ".AppleSystemUIFont", size = 100},
            -- textSize = 200,
            strokeColor = {red = 1, alpha = 1},
            strokeWidth = -15,
            shadow = {offset = {w = 2, h = -2}, blurRadius = 5, color = {black = 0.6, alpha= 0.3}}
        }
    }
}

obj.alert.defaults = {
    textFont = ".AppleSystemUIFont",
    kerning = -5,
    atScreenEdge = 0,
    fadeInDuration = 0.5,
    fadeOutDuration = 0.25,
}

obj.alert.slow = {
    fadeInDuration = 2,
    fadeOutDuration = 2,
}

-- CREATE DEFAULT STYLE WITH ALL FIELDS
obj.alert_default = obj.createStyle(obj.alert.defaults, obj.alert.sizes[2], obj.alert.colors.darkmode)

-- should only update fields i want to change rather than regenerating default style every time
obj.alert_lrg = obj.createStyle(obj.alert.sizes[5])
obj.alert_warning = obj.createStyle(obj.alert.sizes[3], obj.alert.colors.warning)
obj.alert_loader = obj.createStyle(obj.alert.sizes[3], obj.alert.colors.loader)
obj.alert_success = obj.createStyle(obj.alert.sizes[3], obj.alert.colors.success)
obj.alert_warning_lrg = obj.createStyle(obj.alert.sizes[5], obj.alert.colors.warning, obj.alert.slow)
obj.alert_tomfoolery = obj.createStyle(obj.alert.sizes[7], obj.alert.colors.tomfoolery, obj.alert.slow)

-- new in progress stuff:
local warningStyle = {textFont = ".AppleSystemUIFontBold", strokeWidth = 10, strokeColor = {hex = "#FF3D00", alpha = 0.9}, radius = 1, textColor = {hex = "#FFCCBC", alpha = 1}, fillColor = {hex = "#DD2C00", alpha = 0.95}}
local successStyle = {textFont = "AppleSystemUIFontBold", strokeWidth = 10, strokeColor = {hex = "#1B5E20", alpha = 0.9}, radius = 1, textColor = {hex = "#fff", alpha = 1}, fillColor = {hex = "#2E7D32", alpha = 0.9}}
local loadingStyle = {textFont = "AppleSystemUIFontBold", fadeInDuration = 0.5, fadeOutDuration = 0.5, strokeWidth = 10, strokeColor = {hex = "#263238", alpha = 0.9}, radius = 1, textColor = {hex = "#B0BEC5", alpha = 1}, fillColor = {hex = "#37474F", alpha = 0.9}}

-- kind of skunkyworks stuff, but basically way of showing more
-- complicated uis with alerts
local function newStuffDemo()
    local warning = hs.alert.show("CRITICAL: KEXT ERROR", warningStyle, 3)
    local loader

    hs.timer.doAfter(3,
        function()
            loader = 3
            hs.timer.doUntil(function() return loader == 0 end,
                function()
                    loader = loader - 1
                    hs.alert("RECOVERING...", loadingStyle, 0.5)
                end,
            1)
        end
    )
    hs.timer.doAfter(7,
        function()
            loader = 0
            hs.alert.closeAll(0.5)
            hs.alert("SUCCESS!", successStyle, 3)
        end
    ) 
end

-- newStuffDemo()

return obj
