--- === Zzz ===
---
-- Sleep timer for mac

--[[
    TODO:
    * [x] remove unused/functions vars
    * [ ] proper spoon docs
    * [ ] proper spoon-style key binding
    * [x] fix lag with timer inc/dec actions
        * timer has to be deleted then recreated which looks bad
    * [x] refactor so only one timer object needed
        * currently using two: 
            doAt for sysleep
            doEvery for menubar display
    * [ ] simplify timerChooserCallback() logic
    * [ ] remove chooser choices, only use chooser for custom timers
    * [ ] bind menubaritem to hotkey to invoke
    * [ ] clean up / optimize table creation
]]--

local obj = {}
obj.__index = obj

obj.name = "Zzz"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.chooser = nil
obj.timerEvent = nil
obj.hotkeyShow = nil

-- I should probably just normalize everything to seconds?
local minMins = 0
local minSecs = minMins / 60

local maxMins = 300
local maxSecs = maxMins * 60

-- Interval between sleep times
local sleepInterval = 15
local updateInterval = 5
local presetCount = 3

--[[ 
    init our empty chooser choice tables
    each item is a row in the table with the following structure:
    {
        ['id'] = <number>,
            id number for row, 
        ['action'] = <string>,
            "create" OR "stop" OR "adjust" to describe intent
        ['m'] = <number>,
            number of minutes for action (only matters if create/adjust),
            i think i might cast this as string by mistake sometimes,
            but should be num
        ['text'] = <string>,
            text to appear in chooser
    }

]]--

local defaultFont = {
    font = {name = "Input Mono", size = 14},
    color = {hex = "#EEEEEE"}
}

local almostDone = {
    font = {name = "Input Mono", size = 14},
    color = {hex = "#FF6F00"}
}

obj.menuFont = defaultFont

function obj:styleText(text)
    return hs.styledtext.new(
        text, 
        self.menuFont
    )
end

obj.createTimerChoices = {}
obj.startMenuChoices = {}
obj.startMenuCustomChoices = {}
obj.modifyTimerChoices = {}
obj.modifyMenuChoices = {}

-- generate presets dynamically based on sleepInterval/presentCount
for i = 1, presetCount do
    table.insert(obj.createTimerChoices, {
        ["id"] = i,
        ["action"] = "create",
        ["m"] = i * sleepInterval,
        ["text"] = i * sleepInterval .. " minutes",
    })
    table.insert(obj.startMenuChoices, {
        title = obj:styleText(tostring(i * sleepInterval .. "m")),
        fn = function() obj:timerChooserCallback(obj.createTimerChoices[i]) end,
        ["id"] = i,
        ["action"] = "create",
        ["m"] = i * sleepInterval,
        ["text"] = i * sleepInterval .. "m",
    })
end

table.insert(obj.startMenuChoices, 
    {
        title = obj:styleText("??m"), 
        fn = function() obj.chooser:show() end
    }
)

-- static chooser entries
-- increase timer by X minutes decrease timer by Y minutes / stop timer
-- In order to change the timer modifier, change ['m'] below
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
        title = obj:styleText("Stop"),
        fn = function() obj:timerChooserCallback(obj.modifyTimerChoices[1]) end,
    },
    {
        ["id"] = 2,
        ["action"] = "adjust",
        ["m"] = 5,
        ["text"] = "+5m",
        title = obj:styleText("+5m"),
        fn = function() obj:timerChooserCallback(obj.modifyTimerChoices[2]) end,
    },
    {
        ["id"] = 3,
        ["action"] = "adjust",
        ["m"] = -5,
        ["text"] = "-5m",
        title = obj:styleText("-5m"),
        fn = function() obj:timerChooserCallback(obj.modifyTimerChoices[3]) end,
    },
}

-- hotkey binding not working
function obj:bindHotkeys(mapping)
    local def = {
        showTimerMenu = hs.fnutils.partial(self:show(), self),
    }

    hs.spoons.bindHotkeysToSpec(def, mapping)
end

function obj:setTitleStyled(text)
    self.sleepTimerMenu:setTitle(
        hs.styledtext.new(
            text,
            self.menuFont
        )
    )
end

-- why not just deal with minutes?
function obj:formatSeconds(seconds)
    -- from https://gist.github.com/jesseadams/791673
    local seconds = tonumber(seconds)
    if seconds then
        hours = string.format("%02.f", math.floor(seconds / 3600));
        mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)));
        secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60));
        return "☾ " .. mins..":"..secs
    else 
        return false
    end
end

-- hs.timer interval is in seconds
function obj:newTimer(timerInMins)
    self.sleepTimerMenu:returnToMenuBar()
    if self.timerEvent then
        hs.alert("Timer already started")
    else
        self:updateMenu()
        self.sleepTimerMenu:setMenu(self.modifyMenuChoices)
        hs.brightness.set(20) -- this doesnt persist for different apps?
        self.timerEvent = hs.timer.doAfter(
            tonumber(timerInMins) * 60,
            function()
                self:deleteTimer()
                hs.caffeinate.systemSleep()
            end
        )
    end
end

function obj:timerChooserCallback(choice)
    -- switch on action
    if choice['action'] == 'stop' and self.timerEvent then
        -- handle stop timer
        self:deleteTimer()
    elseif choice['action'] == 'adjust' and self.timerEvent then
        -- handle inc/dec timer
        self:adjustTimer(choice['m'])
    elseif choice['m'] == nil then
        -- handle custom timer
        self:newTimer(tonumber(self.chooser:query()))
        self.chooser:query(nil)
    else
        -- handle normal choice
        self:newTimer(tonumber(choice['m']))
    end
end 

function obj:updateMenu()
    hs.timer.doWhile(
        function()
            return self.timerEvent
        end,
        function()
            if math.floor(self.timerEvent:nextTrigger()) == 10 then
                hs.alert("Sleeping in 10 seconds...")
                obj.menuFont = almostDone
            end
            
            self:setTitleStyled(obj:formatSeconds(self.timerEvent:nextTrigger()))
        end,
        1
    )
end

function obj:adjustTimer(minutes)
    local currentDuration = self.timerEvent:nextTrigger() / 60
    if currentDuration + minutes < 0 then
        hs.alert("nah that doesn't make sense")
        return
    else
        local newTimerTime = self.timerEvent:nextTrigger() + (minutes * 60)
        self.timerEvent:setNextTrigger(newTimerTime)
    end
end

function obj:getCurrentChoices()
    if self.timerEvent then
        return self.modifyTimerChoices
    else
        return self.createTimerChoices
    end
end

function obj:deleteTimer()
    self.timerEvent:stop()
    self.timerEvent = nil
    self.menuFont = defaultFont 
    self:setTitleStyled("☾")
    self.sleepTimerMenu:setMenu(self.startMenuChoices)
end

function obj:initChooser()
      
    -- the menubar isnt set by default by the menubar.new call
    -- with the parameter "false", but because we set the title 
    -- right after, it ends up being shown

    -- Initialize our chooser
    -- we use a work around here to capture to capture user input that 
    -- doesnt match any of our preset options by checking <if (choice)>
    -- If the user 'query' doesn't match an option, we provide them with
    -- a new option that appears to let them set a custom timer!
    -- See queryChangeCallback() call below for more info
    self.chooser = hs.chooser.new(
        function(choice)
            if not (choice) then
                print(self.chooser:query())
            else
                self:timerChooserCallback(choice)
            end
        end
    )

    -- Initialize chooser choices from sleepTable & rows
    self.chooser:choices(self:getCurrentChoices())
    -- self.chooser:choices({})
    self.chooser:rows(#self:getCurrentChoices())
    -- self.chooser:rows(0)

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
            if query == ''  then
                self.chooser:choices(self:getCurrentChoices())
            elseif queryNum then
            -- elseif queryNum > minSecs and queryNum < maxMins then
                local choices = {
                    {["id"] = 0, ["text"] = "Custom", subText="Enter a custom time"},
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

function obj:start()
    print("-- Starting Zzz")
    self:init()

    return self
end

function obj:stop()
    hs.alert("-- Stopping Zzz.spoon")
    
    if self.chooser then
        self.chooser:cancel()
        self.chooser = nil
    end
    
    if self.hotkeyShow then
        self.hotkeyShow:disable()
    end

    if self.timerEvent then
        self:deleteTimer()
    end

    self.sleepTimerMenu:delete()
    return self
end

function obj:init()

    -- if statement to prevent dupes especially during dev
    -- We check to see if our menu already exists, and if so
    -- we delete it. Then we create a new one from scratch
    if self.sleepTimerMenu then
        self.sleepTimerMenu:delete()
    end

    self.sleepTimerMenu = hs.menubar.new():setMenu(obj.startMenuChoices)
    self:setTitleStyled("☾")

    self:initChooser()
    -- adds a menubar click callback to invoke show/hide chooser
    -- so sleep timer can be set with mouse only

    return self
end


return obj