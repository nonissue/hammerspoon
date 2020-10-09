tb = require("hs._asm.undocumented.touchbar")

local obj = {}
obj.__index = obj

obj.timestamp = function(date)
    date = date or hs.timer.secondsSinceEpoch()
    return os.date("%F %T" .. string.format("%-5s", ((tostring(date):match("(%.%d+)$")) or "")), math.floor(date))
end

obj.finspect = function(...)
    return (hs.inspect(...):gsub("%s+", " "))
end

local finspect = obj.finspect
local timestamp = obj.timestamp

obj.updateFrequency = 1
obj.cpuTimer = nil

c =
    hs.canvas.new {x = 0, y = 0, h = 90, w = 90}:canvasMouseEvents(true, true, true, true):mouseCallback(
    function(o, m, i, x, y)
        print(timestamp(), m, i, x, y)
        -- print("test")
    end
)
c[#c + 1] = {
    type = "circle",
    radius = tostring(1 / 3),
    center = {x = tostring(1 / 2), y = tostring(2 / 3 - math.sin(math.rad(60)) * 1 / 3)},
    fillColor = {red = 1, alpha = .5}
}
c[#c + 1] = {
    type = "circle",
    radius = tostring(1 / 3),
    center = {x = tostring(1 / 3), y = tostring(2 / 3)},
    fillColor = {green = 1, alpha = .5}
}
c[#c + 1] = {
    type = "circle",
    radius = tostring(1 / 3),
    center = {x = tostring(2 / 3), y = tostring(2 / 3)},
    fillColor = {blue = 1, alpha = .5}
}

idle = hs.canvas.new {h = 100, w = 150}
idle[#idle + 1] = {
    type = "rectangle",
    action = "fill",
    fillColor = {green = 1, alpha = 1},
    frame = {x = "11%", y = "0%", h = "100%", w = "11%"},
    id = "idle"
}
idle[#idle + 1] = {
    type = "rectangle",
    action = "fill",
    fillColor = {red = 1},
    frame = {x = "44%", y = "0%", h = "100%", w = "33%"},
    id = "user"
}
idle[#idle + 1] = {
    type = "rectangle",
    action = "fill",
    fillColor = {green = 1, red = 1},
    frame = {x = "66%", y = "0%", h = "100%", w = "33%"},
    id = "system"
}
idle[#idle + 1] = {
    type = "rectangle",
    action = "stroke",
    strokeColor = {white = 1, alpha = 0.2}
}

local state = true
idleCallback = function(o)
    state = not state
    if state then
        idle:transformation(nil)
    else
        local w = o:canvasWidth() / 2
        -- currently we've only seen the height be 30, so we could hardcode this at 15, but in case it changes in future models
        local h = tb.size().h / 2
        idle:transformation(hs.canvas.matrix.translate(w, h):rotate(90):translate(-w, -h))
    end
end

function obj.createTimer()
    if obj.cpuTimer then
        obj.cpuTimer:stop()
    -- obj.cpuTimer = nil
    end

    print("Creating new cpuTimer with update freq of " .. obj.updateFrequency)

    obj.cpuTimer =
        hs.timer.doEvery(
        obj.updateFrequency,
        function()
            local cpu = hs.host.cpuUsage().overall
            idle["idle"].frame.y, idle["idle"].frame.h = tostring(100 - cpu.idle) .. "%", tostring(cpu.idle) .. "%"
            idle["user"].frame.y, idle["user"].frame.h = tostring(100 - cpu.user) .. "%", tostring(cpu.user) .. "%"
            idle["system"].frame.y, idle["system"].frame.h =
                tostring(100 - cpu.system) .. "%",
                tostring(cpu.system) .. "%"
        end
    )
    return obj.cpuTimer
end

obj.cpuTimer = obj.createTimer()

callbackFN = function(o, ...)
    print(timestamp(), o:identifier(), finspect(table.pack(...)))
end
sliderFN = function(o, v)
    print(v)
    obj.updateFrequency = v
    obj.createTimer()
    callbackFN(o, v)
    if v == "minimum" then
        o:sliderValue(0.2)
        v = o:sliderValue()
    end
    if v == "maximum" then
        o:sliderValue(5)
        v = o:sliderValue()
    end
end

b = tb.bar.new()
local i = {
    tb.item.newButton("text", "textButtonItem"):callback(callbackFN),
    -- tb.item.newCanvas(c, "canvasItem"):callback(callbackFN),
    tb.item.newGroup("groupItem"):groupItems {
        tb.item.newButton(hs.image.imageFromName("NSStatusAvailable"), "available"):callback(callbackFN),
        tb.item.newButton(hs.image.imageFromName("NSStatusPartiallyAvailable"), "partiallyAvailable"):callback(
            callbackFN
        ),
        tb.item.newButton(hs.image.imageFromName("NSStatusUnavailable"), "unavailable"):callback(callbackFN)
    },
    tb.item.newCanvas(idle, "idle"):callback(idleCallback):canvasClickColor {alpha = 0},
    tb.item.newSlider("sliderItem"):callback(sliderFN):sliderMin(0.2):sliderMax(5):sliderValue(1):sliderMinImage(
        hs.image.imageFromName("NSExitFullScreenTemplate")
    ):sliderMaxImage(hs.image.imageFromName("NSEnterFullScreenTemplate"))
}
b:templateItems(i):defaultIdentifiers(
    hs.fnutils.imap(
        i,
        function(o)
            return o:identifier()
        end
    )
)

b:presentModalBar()

-- for poking around at the objective-c objects more directly, not needed for the module or demonstrations
if package.searchpath("hs._asm.objc", package.path) then
    o = require("hs._asm.objc")
    j =
        hs.fnutils.imap(
        i,
        function(x)
            return o.object.fromLuaObject(x)
        end
    )
end

return obj
