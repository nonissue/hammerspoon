
local obj = {}
obj.__index = obj

obj.name = "Reminders"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue/hammerspoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.logger = hs.logger.new("Reminders")

obj.chooser = nil
obj.timerEvent = nil
obj.hotkeyShow = nil

obj.timers = {}
obj.menuBarIcon = "⌚︎"

obj.createTimerChoices = {}
obj.startMenuChoices = {}
obj.startMenuCustomChoices = {}
obj.modifyTimerChoices = {}
obj.modifyMenuChoices = {}

local timerInterval = 15
local updateInterval = 5
local presetCount = 3

for i = 1, presetCount do
    table.insert(obj.createTimerChoices, {
        ["id"] = i,
        ["action"] = "create",
        ["m"] = i * timerInterval,
        ["text"] = i * timerInterval .. " minutes",
    })
    table.insert(obj.startMenuChoices, {
        title = tostring(i * timerInterval .. "m"),
        fn = function() obj:handleAction(obj.createTimerChoices[i]) end,
        ["id"] = i,
        ["action"] = "create",
        ["m"] = i * timerInterval,
        ["text"] = i * timerInterval .. "m",
    })
end

table.insert(obj.startMenuChoices,
    {
        title = "0.1m",
        fn = function() obj:handleAction(obj.startMenuChoices[4]) end,
        ["id"] = 4,
        ["action"] = "create",
        ["m"] = 0.1,
        ["text"] = "0.1 minutes",
    }
)

obj.modifyTimerChoices = {
    {
        ["id"] = 1,
        ["action"] = "stop",
        ["m"] = 0,
        ["text"] = "Stop current timer"
    },
    {
        ["id"] = 2,
        ["action"] = "adjust",
        ["m"] = 5,
        ["text"] = "+5 minutes"
    },
    {
        ["id"] = 3,
        ["action"] = "adjust",
        ["m"] = -5,
        ["text"] = "-5 minutes"
    },
}

obj.modifyMenuChoices = {
    {
        ["id"] = 1,
        ["action"] = "stop",
        ["m"] = 0,
        ["text"] = "Stop Timer",
        title = "Stop",
        fn = function() obj:handleAction(obj.modifyTimerChoices[1]) end,
    },
    {
        ["id"] = 2,
        ["action"] = "adjust",
        ["m"] = 5,
        ["text"] = "+5m",
        title = "+5m",
        fn = function() obj:handleAction(obj.modifyTimerChoices[2]) end,
    },
    {
        ["id"] = 3,
        ["action"] = "adjust",
        ["m"] = -5,
        ["text"] = "-5m",
        title = "-5m",
        fn = function() obj:handleAction(obj.modifyTimerChoices[3]) end,
    },
}

-- why not just deal with minutes?
function obj:formatSeconds(s)
    -- from https://gist.github.com/jesseadams/791673
    local seconds = tonumber(s)
    if seconds then
        local hours = string.format("%02.f", math.floor(seconds / 3600));
        local mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)));
        local secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60));
        return "⌚︎ " .. hours ..":".. mins..":"..secs
    else
        return false
    end
end

function obj:setTitleStyled(text)
    self.reminderMenu:setTitle(
        hs.styledtext.new(
            text
        )
    )
end

function obj:handleAction(choice)
    -- switch on action
    if choice['action'] == 'stop' and self.timerEvent then
        -- handle stop timer
        self.logger.d("Timer stopped")
        self:deleteTimer()
    elseif choice['action'] == 'adjust' and self.timerEvent then
        -- handle inc/dec timer
        self:adjustTimer(choice['m'])
    elseif choice['m'] == nil then
        -- handle custom timer
        self.logger.d("Custom timer started")
        self:startTimer(tonumber(self.chooser:query()))
        self.chooser:query(nil)
    else
        -- handle normal choice
        self.logger.d("Default timer started")
        self:startTimer(tonumber(choice['m']))
    end
end

function obj:adjustTimer(minutes)
    local currentDuration = self.timerEvent:nextTrigger() / 60
    if currentDuration + minutes < 0 then
        self.logger.e("Desired timer adjustment invalid")
        hs.alert("nah that doesn't make sense")
        return
    else
        local newTimerTime = self.timerEvent:nextTrigger() + (minutes * 60)
        self.timerEvent:setNextTrigger(newTimerTime)
        self.logger.d("Timer adjusted successfully")
    end
end

-- hs.timer interval is in seconds
function obj:startTimer(timerInMins)
    self.reminderMenu:returnToMenuBar()
    if self.timerEvent then
        self.logger.e("Timer already running?")
        hs.alert("Timer alreadfy started")
    else
        self.logger.df("Timer started!")
        self:updateMenu()
        self.reminderMenu:setMenu(self.modifyMenuChoices)
        self.timerEvent = hs.timer.doAfter(
            tonumber(timerInMins) * 60,
            function()
                self.logger.df("Timer finished, sleeping!")
                hs.alert("Timer event finished!", 99)
                self:deleteTimer()
            end
        )
    end
end

function obj:deleteTimer()
    self.timerEvent:stop()
    self.timerEvent = nil
    self:setTitleStyled(self.menuBarIcon)
    self.reminderMenu:setMenu(self.startMenuChoices)
end

function obj:updateMenu()
    hs.timer.doWhile(
        function()
            return self.timerEvent
        end,
        function()
            local timeLeft = self.timerEvent:nextTrigger()
            if math.floor(timeLeft) == 10 then
                self.logger.d("Sleeping in 10 seconds")
                hs.alert("Sleeping in 10 seconds...")
                -- obj.menuFont = almostDone
            end

            self:setTitleStyled(obj:formatSeconds(timeLeft))
        end,
        1
    )
end

function obj:init()
    -- if statement to prevent dupes especially during dev
    -- We check to see if our menu already exists, and if so
    -- we delete it. Then we create a new one from scratch
    obj.logger.i('Initiializing Zzz')
    if self.reminderMenu then
        self.reminderMenu:delete()
    end

    self.reminderMenu = hs.menubar.new():setMenu(obj.startMenuChoices)
    self:setTitleStyled(self.menuBarIcon)

    -- adds a menubar click callback to invoke show/hide chooser
    -- so sleep timer can be set with mouse only

    return self
end

return obj