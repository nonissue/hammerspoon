local obj = {}
obj.__index = obj

-- Metadata
obj.name = "Alerts"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- best way to do this:
-- Have different styles
-- and then default sizes
-- this module should provide an api for dynamically creating alerts easily
-- for example, alerts(standard, small) would return the style for a standard alert
-- alerts(nobg, large), etc.

-- properties that are size related:
-- radius
-- strokeWidth
-- textsize

-- properties of alerts:
-- strokeColor
-- fillColor

-- properties of styled text:
-- underlineColor
-- color

-- alerts contain two components:
-- the layout (ratio between strokeWidth, radius, and textSize)
-- color (strokeColor, fillColor, textColor)

-- alerts are three things
-- layout (radius, strokeWidth, textSize, fadeInDuration)
-- font_styles 
-- colors (fillColor, strokeColor, textColor)

-- standard large font:

obj.std_font = {
    -- textFont = "National 2",
    textSize = 36,
    textStyle = {
        underlineStyle = hs.styledtext.lineStyles["single"] or hs.styledtext.linePatterns["dot"] or hs.styledtext.lineAppliesTo["line"],
        underlineColor = {blue = 1, alpha = 0.5},
        shadow = {
            offset = {w = 1, h = -1},
            blurRadius = 7,
            color = {blue = 1, alpha = 0},
        }
    }
}

obj.std_color = {
    fillColor = {white = 1, alpha = 1},
    strokeColor = {blue = 1, alpha = 0.05},
    textColor = {blue = 1, alpha = 1},
}

-- alert styles
obj.std_layout = {
    -- layout
    radius = 15,
    strokeWidth = 5,
    fadeInDuration = 0.5,
    fadeoOutDuration = 0.5,
}

function table.merge(tablelist)
    local newTable = {}

    for t = 1, #tablelist do
        for k, v in pairs(tablelist[t]) do
            newTable[k] = v
        end 
    end

    return newTable
end

-- local testMerge = table.merge({obj.std_layout, obj.std_color, obj.std_font})

function obj.createStyle(layout, font, color)
    local newStyle = table.merge({obj.std_layout, obj.std_color, obj.std_font})
    return newStyle
end

obj.default = {


}

-- The following seems to have become my favourite but it's naming is ridiculous as it has a bg
-- wtf.
obj.nobg = {
    fillColor = {white = 0, alpha = 1},
    radius = 20,
    strokeColor = {white = 1, alpha = 0.1},
    strokeWidth = 10,
    textSize = 40,
    textColor = {white = 1, alpha = 1}
}

alert_font_med = {
    font = {name = "National 2", size = 20},
    underlineColor = {blue = 1, alpha = 0.5},
    strokeColor = {black = 1, alpha = 0.2},
    lineAppliesTo = word,
    color = {blue = 1, alpha = 1}
}

alertFont = {
    font = {name = "New Grotesk Square seven", size = 50},
    underlineColor = {blue = 1, alpha = 0.5},
    strokeColor = {black = 1, alpha = 0.2},
    paragraphStyle = {},
    underlineStyle = 1,
    lineAppliesTo = word,
    color = {blue = 1, alpha = 1}
}

alerts_large = {
    fillColor = {white = 0, alpha = 0.2},
    radius = 100,
    strokeColor = {white = 1, alpha = 1},
    strokeWidth = 50,
    textSize = 100,
    textColor = {black = 1, alpha = 0.8}
}

alerts_large_alt = {
    atScreenEdge = 0,
    fillColor = {white = 1, alpha = 0.8},
    radius = 10,
    strokeColor = {blue = 1, alpha = 0.2},
    strokeWidth = 5,
    -- textSize = 125, textColor = { blue = 1, alpha = 1},
    textStyle = alert_font_lrg
}

alerts_medium = {
    atScreenEdge = 0,
    fillColor = {white = 1, alpha = 0.8},
    radius = 3,
    strokeColor = {blue = 1, alpha = 0.2},
    strokeWidth = 2,
    textStyle = alert_font_med
}

test_style = {
    fillColor = {white = 0, alpha = 0.2},
    radius = 60,
    strokeColor = {white = 0, alpha = 0.2},
    strokeWidth = 10,
    textSize = 55,
    textColor = {white = 0, alpha = 1},
    textStyle = {}
}

local testStyle = obj.createStyle(obj.std_layout[1], obj.std_font, obj.std_color)
print("\n\nTestStyle" .. hs.inspect(testStyle))

function obj.test()
    hs.alert("Important Alert!", alerts_large_alt, 5)
    -- hs.alert("Important Alert!", alerts_medium, 5)
    hs.alert("Test Alert!", testStyle, 10)
end

return obj
