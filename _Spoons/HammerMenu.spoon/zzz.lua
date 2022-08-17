local obj = {}
obj.__index = obj
obj.__name = "zzz"

obj.logger = hs.logger.new("HammerMenu/Zzz")

obj.timerEvent = nil
obj.timers = {}
obj.menuTitle = "Zzz"
obj.menuItems = {}

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
        fn = function() self:startTimer(0.05) end
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

    return startMenuChoices
end

obj.menuItems = obj:generateZzzMenu();

function obj:formatSeconds(s)
    local seconds = tonumber(s)
    if seconds then
        local hours = string.format("%02.f", math.floor(seconds / 3600))
        local mins = string.format("%02.f",
                                   math.floor(seconds / 60 - (hours * 60)))
        local secs = string.format("%02.f", math.floor(
                                       seconds - hours * 3600 - mins * 60))
        return " " .. hours .. ":" .. mins .. ":" .. secs
    else
        return false
    end
end

function obj:processChoice(choice)
    if choice["action"] == "stop" and self.timerEvent then
        self.logger.d("Timer stopped")
        self:deleteTimer()
        return true
    elseif choice["action"] == "adjust" and self.timerEvent then
        self:adjustTimer(choice["m"])
        return true
    elseif choice["m"] == nil then
        self.logger.d("Custom timer started")
        self:startTimer(tonumber(self.chooser:query()))
        self.chooser:query(nil)
        return true
    else
        self.logger.d("Default timer started")
        self:startTimer(tonumber(choice["m"]))
        return true
    end

    return false
end

function obj:startTimer(timerInMins)
    -- self.sleepTimerMenu:returnToMenuBar()
    if self.timerEvent then
        self.logger.e("Timer already running!")

        return false
    else
        self.logger.df("Timer started!")
        self:updateMenu()
        self.menuItems = self.modifyMenuChoices
        self.timerEvent = hs.timer.doAfter(tonumber(timerInMins) * 60,
                                           function()
            self.logger.df("Timer finished, sleeping!")
            self:deleteTimer()
            hs.caffeinate.systemSleep()
        end)
    end
    return true
end

function obj:updateMenu()
    hs.timer.doWhile(function() return self.timerEvent end, function()
        local timeLeft = self.timerEvent:nextTrigger()
        if math.floor(timeLeft) == 10 then
            self.logger.d("Sleeping in 10 seconds")
            hs.alert("Sleeping in 10 seconds...")
            obj.menuFont = almostDone
        end

        self.menuTitle = obj:formatSeconds(timeLeft)
    end, updateFreq)
end

function obj:adjustTimer(m)
    local currentDuration = self.timerEvent:nextTrigger() / 60
    if currentDuration + m < 0 then
        self.logger.e("Desired timer adjustment invalid")
        hs.alert("Cannot adjust timer by " .. m .. " minutes")
        return false
    else
        local newTimerTime = self.timerEvent:nextTrigger() + (m * 60)
        self.timerEvent:setNextTrigger(newTimerTime)
        self.logger.d("Timer adjusted successfully")
        return true
    end
end

function obj:deleteTimer()
    self.timerEvent:stop()
    self.timerEvent = nil
    self.menuFont = defaultFont
    -- self.sleepTimerMenu:setTitle("")
    -- self.sleepTimerMenu:setMenu(self.startMenuChoices)
end

return obj
