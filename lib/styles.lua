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
local size_base = 13

-- dynamically generate sizes
function obj.createSizes(size_base, size_count)
    local sizes = {}
    local size_count = size_count or 3

    for x = 1, size_count do
        table.insert(sizes, 
        {
                textSize = size_base * 2,
                radius = size_base / 2,
                strokeWidth = size_base * 0.375,  
        })
        size_base = size_base * 1.3
    end

    return sizes
end


obj.alert.sizes = obj.createSizes(10, 5)

obj.alert.colors = {
    default = {
        fillColor = {white = 1, alpha = 1},
        strokeColor = {blue = 1, alpha = 0.05},
        textColor = {blue = 1, alpha = 1},
    },
    warning = {
        fillColor = {red = 1, alpha = 1},
        strokeColor = {white = 1, alpha = 0.5},
        textColor = {red = 1, alpha = 1},
        textStyle = {
            color = {white = 1, alpha = 1},
        }
    }
}

obj.alert.defaults = {
    textFont = ".AppleSystemUIFont",
    atScreenEdge = 0,
    fadeInDuration = 0.5,
    fadeoOutDuration = 0.5,
}

-- CREATE DEFAULT STYLE WITH ALL FIELDS
obj.alert_default = obj.createStyle(obj.alert.defaults, obj.alert.sizes[2], obj.alert.colors.default)

-- should only update fields i want to change rather than regenerating default style every time
obj.alert_lrg = obj.createStyle(obj.alert.sizes[5])
obj.alert_warning = obj.createStyle(obj.alert.sizes[3], obj.alert.colors.warning)

return obj
