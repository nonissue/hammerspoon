local obj = {}
obj.__index = obj
obj.__name = "zzz_menu_items"

local minMins = 0
local minSecs = minMins / 60

local maxMins = 300
local maxSecs = maxMins * 60

-- Interval between preset choices
local sleepInterval = 15
-- Amount to adjust timer by (when running)
local updateInterval = 5
-- Number of presets to show in menubar / chooser
local presetCount = 3
-- How often the menubar is updated when countdown running (in seconds)
local updateFreq = 1

obj.createTimerChoices = {}
obj.startMenuChoices = {}
obj.startMenuCustomChoices = {}
obj.modifyTimerChoices = {}
obj.modifyMenuChoices = {}

for i = 1, presetCount do
    table.insert(obj.createTimerChoices, {
        ["id"] = i,
        ["action"] = "create",
        ["m"] = i * sleepInterval,
        ["text"] = i * sleepInterval .. " minutes"
    })
    table.insert(obj.startMenuChoices, {
        title = hs.styledtext.new(tostring(i * sleepInterval .. "m")),
        fn = function() obj:processChoice(obj.createTimerChoices[i]) end,
        ["id"] = i,
        ["action"] = "create",
        ["m"] = i * sleepInterval,
        ["text"] = i * sleepInterval .. "m"
    })
end

local startMenuStaticOpts = {
    {title = "-"},
    {title = hs.styledtext.new("XXm"), fn = function() obj.chooser:show() end},
    {
        title = hs.styledtext.new("Debug"),
        fn = function() obj:startTimer(0.05) end
    }
}

-- Table of actions for our chooser that modify a running countdown
obj.modifyTimerChoices = {
    {
        ["id"] = 1,
        ["action"] = "stop",
        ["m"] = 0,
        ["text"] = "Stop current timer!"
    }, {["id"] = 2, ["action"] = "adjust", ["m"] = 5, ["text"] = "+5 minutes!"},
    {["id"] = 3, ["action"] = "adjust", ["m"] = -5, ["text"] = "-5 minutes"}
}

-- Table of actions that modify a running countdown from our menubar
obj.modifyMenuChoices = {
    {
        ["id"] = 1,
        ["action"] = "stop",
        ["m"] = 0,
        ["text"] = "Stop Timer",
        title = hs.styledtext.new("Stop"),
        fn = function()
            -- Reuse the action our chooser uses as it is the shape
            -- processChoice expects
            obj:processChoice(obj.modifyTimerChoices[1])
        end
    }, {
        ["id"] = 2,
        ["action"] = "adjust",
        ["m"] = 5,
        ["text"] = "+5m",
        title = hs.styledtext.new("+5m"),
        fn = function()
            -- Reuse the action our chooser uses as it is the shape
            -- processChoice expects
            obj:processChoice(obj.modifyTimerChoices[2])
        end
    }, {
        ["id"] = 3,
        ["action"] = "adjust",
        ["m"] = -5,
        ["text"] = "-5m",
        title = hs.styledtext.new("-5m"),
        fn = function()
            -- Reuse the action our chooser uses as it is the shape
            -- processChoice expects
            obj:processChoice(obj.modifyTimerChoices[3])
        end
    }
}

function obj:generateZzzMenu()
    local startMenuChoices = hs.fnutils.concat(obj.startMenuChoices,
                                               startMenuStaticOpts)

    print_r(obj.startMenuChoices)
    return startMenuChoices
end

return obj
