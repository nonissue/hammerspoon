local obj = {}
obj.__index = obj

-- Metadata
obj.name = "utilities"
c = require("hs.canvas")
a =
    c.new {x = 700, y = 1, h = 250, w = 250}:appendElements(
    {
        -- first we start with a rectangle that covers the full canvas
        action = "skip",
        padding = 0,
        type = "rectangle"
    },
    {
        -- then we append a circle, but reverse its path, so that the default windingRule of `evenOdd` sees this as a negative region
        action = "build",
        padding = 0,
        radius = ".3",
        reversePath = true,
        type = "circle"
    },
    {
        -- and we end it it with a smaller circle, which should show content
        action = "skip",
        padding = 0,
        radius = ".2",
        type = "circle",
        fillColor = {alpha = 0.5, blue = 1.0}
        -- frame = { x = "0", y = "0", h = ".75", w = ".75", },
    },
    {
        action = "clip",
        padding = 0,
        radius = ".28",
        type = "circle"
        -- antialias = false
        -- fillColor = { alpha = 1, blue = 1.0  },
    },
    {
        -- now, draw a rectangle in the upper left
        action = "skip",
        fillColor = {alpha = 0, green = 1.0},
        frame = {x = "0", y = "0", h = ".75", w = ".75"},
        type = "rectangle"
        -- withShadow = true,
    },
    {
        -- and a circle in the lower right
        action = "fill",
        center = {x = "0.5", y = "0.5"},
        fillColor = {alpha = 0.9, white = 1},
        radius = ".375",
        type = "circle",
        antialias = false
        -- withShadow = true,
    },
    {
        action = "fill",
        center = {x = "0.5", y = "0.5"},
        fillColor = {alpha = 1, black = 1},
        radius = "0.3",
        startAngle = 0,
        endAngle = 45,
        type = "arc",
        withShadow = true
    },
    {
        -- reset our clipping changes added with elements 1, 2, and 3
        type = "resetClip"
    },
    {
        -- and cover the whole thing with a semi-transparent rectangle
        action = "skip",
        fillColor = {alpha = 0, blue = 0.5, green = 0.5},
        frame = {h = 250.0, w = 250.0, x = 0.0, y = 0.0},
        type = "rectangle"
    }
):show()

print_r(a[7])

local y = false
local x = 0
hs.timer.doWhile(
    function()
        return y ~= true
    end,
    function()
        -- the following 2 lines could also be replaced with
        a:rotateElement(7, x, {x = 125, y = 125})
        -- {x = 50, y = 50})

        -- local sz = a:size()
        -- a[2].transformation = c.matrix.translate(sz.w / 2, sz.h / 2)
        --   :rotate(z)
        --   :translate(sz.w / -2, sz.h / -2)
        x = x + 1
    end,
    .2
)

-- print_r()

-- print_r()

-- y = false
-- z = 0
-- hs.timer.doWhile(
--     function() return y ~= true end,
--     function()
--         -- the following 2 lines could also be replaced with a:rotateElement(2, z)
--         -- a:rotateElement(2, z)
--         local sz = a:size()
--         a[2].transformation = c.matrix.translate(sz.w / 2, sz.h / 2)
--                                       :rotate(z)
--                                       :translate(sz.w / -2, sz.h / -2)
--         z = z + 10
--     end,
-- .1)

--   a:delete()
