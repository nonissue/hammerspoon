--- === Zzz ===
---
-- Sleep timer for macs

-- [x] stop timer may not be working [ fixed 18-07-03 ]

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
obj.timerActive = false

-- I should probably just normalize everything to seconds?
local minMins = 0
local minSecs = minMins / 60

local maxMins = 300
local maxSecs = maxMins * 60

local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end
  
obj.spoonPath = script_path()

-- moving this into init causes duplicates in menubar
-- during dev when we are constantly reloading

-- Interval between sleep times
local sleepInterval = 15
-- Number of sleep times displayed in chooser
local presetCount = 3
local sleepTable = {}
obj.createTimerChoices = {}
obj.modifyTimerChoices = {}
-- chooser optinos should be two distinct tables
-- createTimerChoices:
    -- Preset intervals
-- timerModify
    -- timerStop
    -- timerInc
    -- timerDec


-- dynamic chooser options
-- maybe eventually have these user configurable with persistence?
-- could add a timer running variable so i could modify displayed options
for i = 1, presetCount do
    table.insert(obj.createTimerChoices, {
        ["text"] = i * sleepInterval .. " minutes",
        ["id"] = i,
        ["action"] = "create",
        ["m"] = i * sleepInterval,
    })
end

print(hs.inspect(createTimerChoices))

-- static chooser entries
-- increase timer by 5 / decrease timer by 5 / stop timer
obj.modifyTimerChoices = {
    {
        ["id"] = 1,
        ["action"] = "stop",
        ["m"] = 0,
        ["text"] = "Stop current timer"
    },
    {
        ["id"] = 2, -- doesn't currently work
        ["action"] = "inc",
        ["m"] = 5,
        ["text"] = "+5 minutes"
    },
    {
        ["id"] = 3, -- doesn't currently work
        ["action"] = "dec",
        ["m"] = 5,
        ["text"] = "-5 minutes"
    },
}

local timerStarted = {["group"] = "timerStarted"}
local timerStopped = {["group"] = "timerStopped"}
-- IDEA
-- Only show these if timer is running?
-- for i = 1, #modifyTimerChoices do
    -- modifyTimer[i]["group"] = "timerStarted"
    -- table.insert(sleepTable, modifyTimer[i])
    -- table.insert(sleepTable[i], timerStarted[0])
-- end

print(hs.inspect(modifyTimerChoices))

-- hotkey binding not working
function obj:bindHotkeys(mapping)
    local def = {
        showTimerMenu = hs.fnutils.partial(self:show(), self),
        }

        hs.spoons.bindHotkeysToSpec(def, mapping)
end

function obj:formatSeconds(seconds)
    -- from https://gist.github.com/jesseadams/791673
    local seconds = tonumber(seconds)

    if seconds <= minSecs then
        return "Error: timer less than or eq to 0"
    elseif seconds > maxSecs then -- not really the place to check this??
        hs.alert("Timer must be lower than two hours?")
        return "error"
    else
        hours = string.format("%02.f", math.floor(seconds / 3600));
        mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)));
        secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60));
        return "☾ " .. mins..":"..secs
    end
end

-- simple method to get time remaining 
-- in easily readable form
function obj:timeRemaining()
    if self.timerEvent == nil then
        return "Error: No timer event found to print"
    else 
        local seconds = self:formatSeconds(
            self.timerEvent:nextTrigger()
        )

        return seconds
    end
end

-- hs.timer interval is in seconds
function obj:newTimer(timerInMins)
    self.sleepTimerMenu:returnToMenuBar()
    if self.timerEvent then
        hs.alert("Timer already started")
    else 
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
                self.sleepTimerMenu:setTitle(obj:formatSeconds(interval))
            end
        )
        self.timerActive = true
    end
end

function obj:timerChooserCallback(choice)
    -- switch on action
    if choice['action'] == 'stop' then
        -- if not self.timerEvent == nil then
        if self.timerEvent then
            self:deleteTimer()
            -- return
        else
            print(choice['action'])
            hs.alert("No timer to stop")
            -- return
        end
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
        if choice['id'] > 0 and choice['id'] < 5 then
            self:newTimer(mins)
        else
            hs.alert("Invalid option, error", 3)
        end
    end
end

function obj:incTimer(minutes)
    local incrementSecs = minutes * 60
end

function obj:deleteTimer()
    self.timerDisplay:stop()
    self.timerEvent:stop()
    self.sleepTimerMenu:setTitle("☾")
    self.sleepTimerMenu:removeFromMenuBar()
    self.timerEvent = nil
    self.timerDisplay = nil
    self.timerActive = false
end

function obj:hide()
    self.chooser:hide()
    return self
end

function obj:show()
    self.chooser:show()
    return self
end

function obj:start()
    print("-- Starting Zzz")
    return self
end

function obj:stop()
    hs.alert("-- Stopping Zzz.spoon")
    self.chooser:hide()
    if self.hotkeyShow then
        self.hotkeyShow:disable()
    end

    obj:deleteTimer()
    self.sleepTimerMenu:delete()
    return self
end

function obj:getCurrentChoices()
    if self.timerActive then 
        return self.modifyTimerChoices
    elseif self.timerActive == false then
        return self.createTimerChoices
    end
end


function obj:init()

    -- if statement to prevent dupes especially during dev
    -- We check to see if our menu already exists, and if so
    -- we delete it. Then we create a new one from scratch
    if self.sleepTimerMenu then
        self.sleepTimerMenu:delete()
    end
    self.sleepTimerMenu = hs.menubar.new()
    -- self.sleepTimerMenu:setTitle("☾")
    self.sleepTimerMenu:removeFromMenuBar()
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
        -- function(query)
        --     if query == '' then
        --         self.chooser:choices(sleepTable)
        --     elseif query > 0 and query < 300 then
        --         local choices = {
        --         {["id"] = 0, ["text"] = "Custom", subText="Enter a custom time"},
        --         }
        --         self.chooser:choices(choices)
        --     end
        -- end
    

    self.chooser:width(20)
    self.chooser:bgDark(true)

    return self
end


return obj