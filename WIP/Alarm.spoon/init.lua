--- === Timer ===
---
-- Simple timer with alert

--[[
Todo:
- [ ] Simplify tables
- [ ] Allow custom function to be called at timer end
- [x] Interface to allow custom input for timer
- [ ] integrate with SysInfo timer display?
- [ ] Add better menubar display rathan than updating countdown every second
- [ ] Handle snoozing
- [ ] Handle enabling/disabling dnd if necessary
    - ie. if it is enabled, disable it to send notification.
    - if notification is acknowledged, return dnd to original state
    - if dnd is enabled and user chooses snooze, renable dnd, then disable
      after snoze interval is done


Call when timer ends?
timerDone = function(result) print("Callback Result: " .. result) end
hs.dialog.alert(500, 500, timerDone, "Message", "Informative Text", "Button One", "Button Two", "NSCriticalAlertStyle")
]]





local obj = {}
obj.__index = obj

obj.name = "Alarm"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue/hammerspoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.logger = hs.logger.new("Alarm")

obj.chooser = nil
obj.timerEvent = nil
obj.hotkeyShow = nil

obj.timers = {}
-- obj.menuBarIcon = "⌚︎"
obj.menuBarIcon = "↻"

obj.createAlarmChoices = {}
obj.startMenuChoices = {}
obj.startMenuCustomChoices = {}
obj.modifyAlarmChoices = {}
obj.modifyMenuChoices = {}

local sounds_dir = os.getenv("HOME") .. "/.hammerspoon/archive/media/sounds/"
obj.alert_sound = hs.sound.getByFile(sounds_dir .. "alert.caf")

local timerInterval = 15
local presetCount = 3

for i = 1, presetCount do
    table.insert(obj.createAlarmChoices, {
        ["id"] = i,
        ["action"] = "create",
        ["m"] = i * timerInterval,
        ["text"] = i * timerInterval .. " minutes",
    })
    table.insert(obj.startMenuChoices, {
        title = tostring(i * timerInterval .. "m"),
        fn = function() obj:handleAction(obj.createAlarmChoices[i]) end,
        ["id"] = i,
        ["action"] = "create",
        ["m"] = i * timerInterval,
        ["text"] = i * timerInterval .. "m",
    })
end

table.insert(obj.startMenuChoices,
    {
        title = "0.15m",
        fn = function() obj:handleAction(obj.startMenuChoices[4]) end,
        ["id"] = 4,
        ["action"] = "create",
        ["m"] = 0.15,
        ["text"] = "0.15 minutes",
    }
)

table.insert(obj.startMenuChoices,
    {
        title = "??m",
        fn = function() obj.customInput:show() end
    }
)

obj.modifyAlarmChoices = {
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
        ["text"] = "Stop Alarm",
        title = "Stop",
        fn = function() obj:handleAction(obj.modifyAlarmChoices[1]) end,
    },
    {
        ["id"] = 2,
        ["action"] = "adjust",
        ["m"] = 5,
        ["text"] = "+5m",
        title = "+5m",
        fn = function() obj:handleAction(obj.modifyAlarmChoices[2]) end,
    },
    {
        ["id"] = 3,
        ["action"] = "adjust",
        ["m"] = -5,
        ["text"] = "-5m",
        title = "-5m",
        fn = function() obj:handleAction(obj.modifyAlarmChoices[3]) end,
    },
}
-- Call when timer ends?
function obj:timerDoneAlert()
    hs.dialog.blockAlert("Message", "Informative Text", "Snooze", "Okay!", "NSCriticalAlertStyle")
end

function obj:updateProgressBar(elapsed, total)

end

-- why not just deal with minutes?
function obj:formatSeconds(s)
    -- from https://gist.github.com/jesseadams/791673
    local seconds = math.ceil(s) -- use math.ceil as secs left is too precise
    if seconds then
        local hours = string.format("%02.f", math.floor(seconds / 3600));
        local mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)));
        local secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60));

        -- return "⣿⣿⣿⣿⣦⣀⣀⣀⣀⣀"
        return self.menuBarIcon .. " " .. hours ..":".. mins..":"..secs
    else
        return false
    end
end

function obj:setTitleStyled(text)
    self.alarmMenu:setTitle(
        text
    )
end

function obj:handleAction(choice)
    -- switch on action
    if choice['action'] == 'stop' and self.timerEvent then
        -- handle stop timer
        self.logger.d("Alarm stopped")
        self:deleteAlarm()
    elseif choice['action'] == 'adjust' and self.timerEvent then
        -- handle inc/dec timer
        self:adjustAlarm(choice['m'])
    elseif choice['m'] == nil then
        -- handle custom timer
        local userInput = tonumber(self.customInput:query())
        if userInput == nil then
            hs.alert("Invalid custom timer value")
            return
        end
        self.logger.d("Custom timer started")
        self:startAlarm(userInput)
        self.customInput:query(nil)
    else
        -- handle normal choice
        self.logger.d("Default timer started")
        self:startAlarm(tonumber(choice['m']))
    end
end

function obj:adjustAlarm(minutes)
    local currentDuration = self.timerEvent:nextTrigger() / 60
    if currentDuration + minutes < 0 then
        self.logger.e("Desired timer adjustment invalid")
        hs.alert("nah that doesn't make sense")
        return
    else
        local newAlarmTime = self.timerEvent:nextTrigger() + (minutes * 60)
        self.timerDuration = self.timerDuration + (minutes * 60)
        self.progress = self.timerEvent:nextTrigger() / self.timerDuration
        -- local progress = self.timerEvent:nextTrigger() / self.timerDuration
        hs.alert("Original duration: " .. self.timerDuration)
        hs.alert("Time left: " .. self.timerEvent:nextTrigger())
        -- hs.alert("Progress" .. progress)

        self.timerEvent:setNextTrigger(newAlarmTime)
        self.logger.d("Alarm adjusted successfully")
    end
end

-- hs.timer interval is in seconds
function obj:startAlarm(timerInMins)
    self.alarmMenu:returnToMenuBar()
    if self.timerEvent then
        self.logger.e("Alarm already running?")
        hs.alert("Alarm alreadfy started")
    else
        self.logger.df("Alarm started!")
        self.timerDuration = timerInMins * 60
        -- hs.alert("Timer duration: " .. self.timerDuration)
        self:updateMenu()
        self.alarmMenu:setMenu(self.modifyMenuChoices)
        self.timerEvent = hs.timer.doAfter(
            tonumber(timerInMins) * 60,
            function()
                self.logger.df("Timer finished, sleeping!")
                os.execute("/usr/local/bin/dnd-cli off")
                spoon.Alarm.alert_sound:play() -- plays sound
                hs.notify.new({
                    title = "Timer Finished!",
                    subtitle = "You set a timer, now it's finished!",
                    hasActionButton = true,
                    actionButtonTitle = "Snooze",
                    withdrawAfter = 0,
                    alwaysPresent = true, autoWithdraw = false
                }):send()
                self:deleteAlarm()

                hs.timer.doAfter(5,
                    function()
                        os.execute("/usr/local/bin/dnd-cli on")
                    end
                )
            end
        )
        self.progress = self.timerEvent:nextTrigger() / self.timerDuration
        -- hs.alert("Timer duration: " .. self.timerDuration)
        -- hs.alert("Timer duration: " .. self.timerEvent:nextTrigger())
        hs.alert("Progress" .. self.progress)
    end
end

function obj:deleteAlarm()
    self.timerEvent:stop()
    self.timerEvent = nil
    self:setTitleStyled(self.menuBarIcon)
    self.alarmMenu:setMenu(self.startMenuChoices)
end

function obj:updateMenu()
    hs.timer.doWhile(
        function()
            return self.timerEvent
        end,
        function()
            local timeLeft = self.timerEvent:nextTrigger()
            if math.floor(timeLeft) == 10 then
                self.logger.d("Timer up in 10 seconds")
                hs.alert("Timer up in 10 seconds...")
            end
            self:setTitleStyled(obj:formatSeconds(timeLeft))
        end,
        2
    )
end

obj.customTimerMessages = {
    -- add colors?
    initial = {
        {["id"] = 0, ["text"] = "Start", subText="Enter a custom time"},
    },
    error = {
        {["id"] = 0, ["text"] = "Error", subText="Only enter numbers!"},
    },
    submit = {
        {["id"] = 0, ["text"] = "Start", subText="Press return to start timer!"},
    }
}

function obj:getChooserChoices(msg)
    if msg then
        return obj.customTimerMessages[msg]
    else
        return obj.customTimerMessages["initial"]
    end
end

function obj:customTimer()
    self.customInput = hs.chooser.new(
        function(choice)
            if not (choice) then
                print(self.customInput:query())
            else
                self:handleAction(choice)
            end
        end
    )

    self.customInput:choices(obj:getChooserChoices())
    self.customInput:rows(1)
    self.customInput:placeholderText("Duration (m): ")

    self.customInput:queryChangedCallback(
        function(query)
            local queryNum = tonumber(query)
            if query == ''  then
                print("hi!")
                self.customInput:choices(obj:getChooserChoices("initial"))
            elseif queryNum then
                self.customInput:choices(obj:getChooserChoices("submit"))
            else
                self.customInput:choices(obj:getChooserChoices("error"))
            end
        end
    )

    self.customInput:width(18)
    self.customInput:bgDark(true)
    return self
end

function obj:stop()
    obj.logger.i('Stopping Timer.spoon')
    if self.alarmMenu then
        self.alarmMenu:delete()
    end

    if self.customInput then
        self.customInput:delete()
        self.customInput = nil
    end

    if self.timerEvent then
        self:deleteAlarm()
    end
end

function obj:start()
    obj:init()
end

function obj:init()
    -- if statement to prevent dupes especially during dev
    -- We check to see if our menu already exists, and if so
    -- we delete it. Then we create a new one from scratch
    obj.logger.i('Initializing Timer.spoon')
    if self.alarmMenu then
        self.alarmMenu:delete()
    end

    if self.customInput then
        self.customInput:delete()
        self.customInput = nil
    end

    self:customTimer()

    self.alarmMenu = hs.menubar.new():setMenu(obj.startMenuChoices)
    self:setTitleStyled(self.menuBarIcon)

    -- adds a menubar click callback to invoke show/hide chooser
    -- so sleep timer can be set with mouse only
    return self
end

return obj