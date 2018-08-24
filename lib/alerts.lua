local obj = {}
obj.__index = obj

-- Metadata
obj.name = "Alerts"
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
    local newStyle = table.merge({obj.std_layout, obj.std_color, obj.std_font})
    return newStyle
end

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
    textSize = 36,
    textStyle = {
        underlineStyle = hs.styledtext.lineStyles["single"] or hs.styledtext.linePatterns["dot"] or hs.styledtext.lineAppliesTo["line"],
        underlineColor = {blue = 1, alpha = 0.5},
    }
}

obj.std_color = {
    fillColor = {white = 1, alpha = 1},
    strokeColor = {blue = 1, alpha = 0.05},
    textColor = {blue = 1, alpha = 1},
}

obj.std_layout = {
    radius = 15,
    strokeWidth = 5,
    fadeInDuration = 0.5,
    fadeoOutDuration = 0.5,
}

obj.std = obj.createStyle(obj.std_layout, obj.std_font, obj.std_color)

obj.warn_color = {
    fillColor = {white = 1, alpha = 1},
    strokeColor = {red = 1, alpha = 0.5},
    textColor = {red = 1, alpha = 1},
}

-- Concats a list of unordered tables containing key = value pairs
-- the value of a pair can also be another table, and it is preserved.

-- The following seems to have become my favourite but it's naming is ridiculous as it has a bg
-- wtf.

local testStyle = obj.createStyle(obj.std_layout[1], obj.std_font, obj.std_color)
print("\n\nTestStyle" .. hs.inspect(testStyle))

function obj.test()
    hs.alert("Important Alert!", alerts_large_alt, 5)
    hs.alert("Test Alert!", testStyle, 10)
end

return obj
