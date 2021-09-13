--- === Zzz ===
---
--- Sleep timer for mac
---
--- Options:
---     - Specify hotkey to toggle chooser menu that allows you to control spoon
---         - Call (after loading spoon):
---             `spoon.Zzz:bindHotkeys(spoon.Zzz.defaultHotkeys)`
---           to use default (cmd + ctrl + opt + S)
---         - To customize hotkey, use:
---             `spoon.Zzz:bindHotkeys({ toggleChooser = {{yourModifiers}, yourKey}})`
---         - See `obj.defaultHotkeys` below for more info
---
--- Future additions:
---     - Customizable variables `updateFreq`, `sleepInterval`, `presetCount` when loading the spoon
---     - Customizable menuBar icon (included options: moon.circle.fill, moon.circle, moon.stars from SF Symbol)
---

local obj = {}
obj.__index = obj

obj.name = "Zzz"
obj.version = "0.5"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue/hammerspoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.logger = hs.logger.new("Zzz")

obj.chooser = nil
obj.timerEvent = nil

obj.defaultHotkeys = {
    toggleChooser = {{"ctrl", "alt", "cmd"}, "S"}
}

obj.timers = {}

local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

obj.spoonPath = script_path()

obj.menubarIcon = hs.image.imageFromPath(obj.spoonPath .. "/moon.circle.fill.pdf"):setSize({w = 20, h = 20})

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
    table.insert(
        obj.createTimerChoices,
        {
            ["id"] = i,
            ["action"] = "create",
            ["m"] = i * sleepInterval,
            ["text"] = i * sleepInterval .. " minutes"
        }
    )
    table.insert(
        obj.startMenuChoices,
        {
            title = hs.styledtext.new(tostring(i * sleepInterval .. "m")),
            fn = function()
                obj:processChoice(obj.createTimerChoices[i])
            end,
            ["id"] = i,
            ["action"] = "create",
            ["m"] = i * sleepInterval,
            ["text"] = i * sleepInterval .. "m"
        }
    )
end

local startMenuStaticOpts = {
    {
        title = "-"
    },
    {
        title = hs.styledtext.new("XXm"),
        fn = function()
            obj.chooser:show()
        end
    }
}

-- Table of actions for our chooser that modify a running countdown
obj.modifyTimerChoices = {
    {
        ["id"] = 1,
        ["action"] = "stop",
        ["m"] = 0,
        ["text"] = "Stop current timer!"
    },
    {
        ["id"] = 2,
        ["action"] = "adjust",
        ["m"] = 5,
        ["text"] = "+5 minutes!"
    },
    {
        ["id"] = 3,
        ["action"] = "adjust",
        ["m"] = -5,
        ["text"] = "-5 minutes"
    }
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
    },
    {
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
    },
    {
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

--- Zzz:bindHotkeys(keys)
--- Method
--- Binds hotkey to invoke sleep menu chooser
---
--- Parameters:
---  * keys - An optional table containing the key binding to use
---
--- Returns:
---  * void - nothing return
function obj:bindHotkeys(keys)
    local hotkeys = keys or obj.defaultHotkeys

    hs.hotkey.bindSpec(
        hotkeys["toggleChooser"],
        function()
            obj.chooser:show()
        end
    )
end

--- Zzz:formatSeconds(s)
--- Method
--- Converts raw seconds to formatted string for countdown
---
--- Parameters:
---  * s - A number of seconds
---
--- Returns:
---  * string of the format: HH:MM:SS
function obj:formatSeconds(s)
    local seconds = tonumber(s)
    if seconds then
        local hours = string.format("%02.f", math.floor(seconds / 3600))
        local mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)))
        local secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60))
        return " " .. hours .. ":" .. mins .. ":" .. secs
    else
        return false
    end
end

--- Zzz:startTimer(timerInMins)
--- Method
--- Starts a timer for the specified duration in minutes
---
--- Parameters:
---  * timerInMins - A number of minutes specifying new timer duration (note: real nums accepted)
---
--- Returns:
--- * boolean - true indicates timer started, false indicates failure starting timer
function obj:startTimer(timerInMins)
    self.sleepTimerMenu:returnToMenuBar()
    if self.timerEvent then
        self.logger.e("Timer already running!")

        return false
    else
        self.logger.df("Timer started!")
        self:updateMenu()
        self.sleepTimerMenu:setMenu(self.modifyMenuChoices)
        self.timerEvent =
            hs.timer.doAfter(
            tonumber(timerInMins) * 60,
            function()
                self.logger.df("Timer finished, sleeping!")
                self:deleteTimer()
                hs.caffeinate.systemSleep()
            end
        )
    end
    return true
end

--- Zzz:processChoice(choice)
--- Method
--- Processes choice sent from menubar callback or chooser callback
---
--- Parameters:
---  * choice - a table with the following required keys:
---     * action - one of the following strings: "create", "adjust", "stop", indicating the intention of the action
---     * m - number representing the impact of the choice
---
--- Returns:
---  * boolean - true indicates command processed successfully, false indicates failure
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

--- Zzz:updateMenu()
--- Method
--- Updates the menubar every X seconds when a countdown has been started
--- updateFreq defaults to every second, but cant be changed
---
--- Parameters:
---  * None
---
--- Returns:
---  * Nothing
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
                obj.menuFont = almostDone
            end

            self.sleepTimerMenu:setTitle(obj:formatSeconds(timeLeft))
        end,
        updateFreq
    )
end

--- Zzz:adjustTimer(choice)
--- Method
--- Adjusts a running timer by specified minutes (up/down)
---
--- Parameters:
---  * m - number indicating amount to modify timer (can be -/+)
---
--- Returns:
---  * boolean - true indicates timer adjusted successfully, false indicates failure
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

--- Zzz:deleteTimer(choice)
--- Method
--- Deletes a running countdown
---
--- Parameters:
---  * None
---
--- Returns:
---  * Nothing
function obj:deleteTimer()
    self.timerEvent:stop()
    self.timerEvent = nil
    self.menuFont = defaultFont
    self.sleepTimerMenu:setTitle("")
    self.sleepTimerMenu:setMenu(self.startMenuChoices)
end

--- Zzz:getCurrentChoices()
--- Method
--- Gets current choices for chooser (if no countdown is running, show start options)
--- If countdown is running, show options to modify countdown (adjust(+/-),stop)
---
--- Parameters:
---  * m - number indicating amount to modify timer (can be -/+)
---
--- Returns:
---  * A table containing the list of choices the chooser should show
function obj:getCurrentChoices()
    if self.timerEvent then
        return self.modifyTimerChoices
    else
        return self.createTimerChoices
    end
end

--- Zzz:initChooser()
--- Method
--- Initialize our chooser which can be invoked using the custom duration menubar entry
--- or by binding a hotkey to hide/show chooser. Default is {{"ctrl", "alt", "cmd"}, "S"}}
--- Our chooser can both start, stop, adjust and remove a countdown, and is also used for
--- capturing user input for custom countdown durations.
---
--- Parameters:
---  * None
---
--- Returns:
---  * The initialized chooser object
function obj:initChooser()
    self.chooser =
        hs.chooser.new(
        function(choice)
            if not (choice) then
                print(self.chooser:query())
            else
                self:processChoice(choice)
            end
        end
    )

    self.chooser:choices(self:getCurrentChoices())
    self.chooser:rows(#self:getCurrentChoices())

    -- QueryChangedCallback
    -- User hasn't entered any input, we show default options
    -- if they start entering input, we immediately replace the
    -- preset options with a new option to set a custom timer
    -- the premise is that: the user will only enter text
    -- if they dont want a default option, otherwise they will
    -- user arrow keys/hotkeys to select option
    self.chooser:queryChangedCallback(
        function(query)
            local queryNum = tonumber(query)
            if query == "" then
                self.chooser:choices(self:getCurrentChoices())
            elseif queryNum then
                -- elseif queryNum > minSecs and queryNum < maxMins then
                local choices = {
                    {["id"] = 0, ["text"] = "Custom", subText = "Enter a custom time"}
                }
                self.chooser:choices(choices)
            else
                self.chooser:choices(self:getCurrentChoices())
            end
        end
    )

    self.chooser:width(20)
    self.chooser:bgDark(true)

    return self
end

--- Zzz:start()
--- Method
--- Starts our spoon by calling Zzz:init()
---
---
--- Parameters:
---  * None
---
--- Returns:
---  * Zzz.spoon
function obj:start()
    obj.logger.i("Starting Zzz")
    self:init()

    return self
end

--- Zzz:stop()
--- Method
--- Stops any running countdowns, hides any displayed choosers, deletes menubar entry
---
--- Parameters:
---  * None
---
--- Returns:
---  * Zzz
function obj:stop()
    obj.logger.i("Stopping Zzz")

    if self.chooser then
        self.chooser:cancel()
        self.chooser = nil
    end

    if self.timerEvent then
        self:deleteTimer()
    end

    self.sleepTimerMenu:delete()
    return self
end

--- Zzz:init()
--- Method
--- Init function checks for existing menubar item and removes it if it exists,
--- setups Zzz.startMenuChoices table, creates new menubar item, and initialize our
--- chooser
---
--- Parameters:
---  * None
---
--- Returns:
---  * Zzz
function obj:init()
    -- if statement to prevent dupes especially during dev
    -- We check to see if our menu already exists, and if so
    -- we delete it. Then we create a new one from scratch
    obj.logger.i("Initializing Zzz")

    if self.sleepTimerMenu then
        self.sleepTimerMenu:delete()
    end

    obj.startMenuChoices = hs.fnutils.concat(obj.startMenuChoices, startMenuStaticOpts)

    self.sleepTimerMenu = hs.menubar.new():setMenu(obj.startMenuChoices)
    self.sleepTimerMenu:setIcon(self.menubarIcon)

    self:initChooser()

    return self
end

return obj
