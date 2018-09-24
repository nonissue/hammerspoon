--- === Zzz ===
---
-- Sleep timer for mac

--[[
    TODO:
    * [ ] Basically needs a complete refactor
        * overly complicated
    * [ ] remove unused/functions vars
    * [ ] proper spoon docs
    * [ ] proper spoon-style key binding
    * [ ] fix lag with timer inc/dec actions
        * timer has to be deleted then recreated which looks bad
    * [ ] refactor so only one timer object needed
        * currently using two: 
            doAt for sysleep
            doEvery for menubar display
    * [ ] verify choice['m'] is only being set as num
        * so I can remove tonumber() casts which shouldn't be reqd
    * [ ] simplify timerChooserCallback() logic
]]--

local obj = {}
obj.__index = obj

obj.name = "Zzz"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.chooser = nil
obj.timerDisplay = nil
obj.timerEvent = nil
obj.hotkeyShow = nil

-- I should probably just normalize everything to seconds?
local minMins = 0
local minSecs = minMins / 60

local maxMins = 300
local maxSecs = maxMins * 60

-- moving this into init causes duplicates in menubar
-- during dev when we are constantly reloading

-- Interval between sleep times
local sleepInterval = 15

-- Number of sleep times displayed in chooser
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

obj.menuFont = {
    font = {name = "Input Mono", size = 14},
    color = {hex = "#FF6F00"}
}

function obj:styleText(text)
    return hs.styledtext.new(
        text, 
        self.menuFont
    )
end

obj.createTimerChoices = {}
obj.startMenuChoices = {}
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

-- print(i(obj.startMenuChoices))

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
        title = "Stop Timer",
        fn = function() obj:timerChooserCallback(obj.modifyTimerChoices[1]) end,
    },
    {
        ["id"] = 2,
        ["action"] = "adjust",
        ["m"] = 5,
        ["text"] = "+5m",
        title = "+5m",
        fn = function() obj:timerChooserCallback(obj.modifyTimerChoices[2]) end,
    },
    {
        ["id"] = 3,
        ["action"] = "adjust",
        ["m"] = -5,
        ["text"] = "-5m",
        title = "-5m",
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
        -- return "[☾ " .. mins .. "]"
    end
end

-- hs.timer interval is in seconds
function obj:newTimer(timerInMins)
    self.sleepTimerMenu:returnToMenuBar()
    if self.timerEvent then
        hs.alert("Timer already started")
    else
        self.sleepTimerMenu:setMenu(self.modifyMenuChoices)
        -- i don't like having two functions for this
        -- and setting two variables
        interval = tonumber(timerInMins) * 60
        self.timerEvent = hs.timer.doAfter(
            interval, 
            function() 
                hs.caffeinate.systemSleep() 
            end
        )
        self.timerDisplay = hs.timer.doEvery(
            1, 
            function()
                interval = interval - 1
                if interval == 11 then
                    hs.alert("Sleeping in 10 seconds...")
                end
                
                self:setTitleStyled(obj:formatSeconds(interval))
            end
        )
    end
end

function obj:timerChooserCallback(choice)
    -- switch on action
    if choice['action'] == 'stop' then
        if self.timerEvent then
            self:deleteTimer()
        else
            hs.alert("Error: No timer to stop")
            return
        end
    elseif choice['action'] == 'adjust' and self.timerEvent then
        self:adjustTimer(choice['m'])
    elseif choice['m'] == nil then
        -- should do a check to see if customCountdown is a number
        local customCountdown = tonumber(self.chooser:query())
        -- Make sure the specified minutes are a reasonable amount
        if customCountdown < maxMins and customCountdown > minMins then
            self:newTimer(customCountdown)
        else 
            hs.alert("Specified value is too big or too small or nonsensical, try again")
            self.chooser:cancel()
            self.chooser:show()
        end
    else
        local mins = tonumber(choice['m'])
        if choice['id'] > 0 and choice['id'] <= #obj.createTimerChoices then
            self.sleepTimerMenu:setMenu(self:getMenuChoices())
            self:newTimer(mins)
        else
            hs.alert("Invalid option, error", 3)
        end
    end
end

function obj:adjustTimer(minutes)
    if minutes < 0 then
        local currentDuration = self.timerEvent:nextTrigger() / 60
        if currentDuration - minutes < 3 then
            hs.alert("nah that doesn't make sense")
            return
        else
            local newTimerTime = self.timerEvent:nextTrigger() / 60 + minutes
            self.timerEvent:setNextTrigger(newTimerTime)
            self:deleteTimer()
            self:newTimer(newTimerTime)
        end
    elseif minutes > 0 then
        local newTimerTime = self.timerEvent:nextTrigger() / 60 + minutes
        self:deleteTimer()
        self:newTimer(newTimerTime)
    end
end

function obj:deleteTimer()
    self.timerDisplay:stop()
    self.timerEvent:stop()
    self:setTitleStyled("☾")
    self.sleepTimerMenu:setMenu(self.startMenuChoices)
    self.timerEvent = nil
    self.timerDisplay = nil
end

function obj:show()
    self.chooser:show()
    return self
end

function obj:hide()
    self.chooser:hide()
    return self
end

function obj:start()
    print("-- Starting Zzz")
    return self
end

function obj:stop()
    hs.alert("-- Stopping Zzz.spoon")
    self.chooser:cancel()
    if self.hotkeyShow then
        self.hotkeyShow:disable()
    end

    obj:deleteTimer()
    self.sleepTimerMenu:delete()
    return self
end

function obj:getCurrentChoices()
    if self.timerEvent then
        return self.modifyTimerChoices
    else
        return self.createTimerChoices
    end
end

function obj:getMenuChoices()
    if self.timerEvent then
        return self.modifyMenuChoices
    else
        return self.startMenuChoices
    end
end

function obj:chooserToggle()
    self.chooser:choices(self:getCurrentChoices())
    self.chooser:rows(#self:getCurrentChoices())
    
    if self.chooser:isVisible() then
        -- cancel rather than hide
        -- hide persists entered text in the search field
        -- which i dont want
        self.chooser:cancel()
    else 

        self.chooser:show()
    end
end

function obj:init()

    -- if statement to prevent dupes especially during dev
    -- We check to see if our menu already exists, and if so
    -- we delete it. Then we create a new one from scratch
    if self.sleepTimerMenu then
        self.sleepTimerMenu:delete()
    end
    self.sleepTimerMenu = hs.menubar.new():setMenu(obj:getMenuChoices())
    self:setTitleStyled("☾")
    
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

    -- adds a menubar click callback to invoke show/hide chooser
    -- so sleep timer can be set with mouse only
    -- self.sleepTimerMenu:setClickCallback(function() self:chooserToggle() end)

    return self
end


return obj