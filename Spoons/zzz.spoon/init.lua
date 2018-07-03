-- Todo:
-- [x] Start/stop
-- [ ] Custom times?
-- [x] Menu bar item
-- [x] Not sure if this even works
-- [x] Update Menubar icon with countdown
-- [ ] convert this to a proper module or spoon
-- Make menubar item a clickable list

-- countdowns should persist between hammerspoon loads, it's annoying to klose them. 
-- also find a better way to display the countdown timer, I think menubar isnt best
-- decrease volume over time ?s

-- Basically:
-- cmd + ctrl + opt + s brings up alert modals
-- select a sleep time, its set on a delay
-- eventually menu bar will show you time remaining
-- simple proof of concept works (if you press zero when
-- prompted for model, timer is set to 5 seconds and seems to work)
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

local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end
  
obj.spoonPath = script_path()

-- moving this into init causes duplicates in menubar
-- during dev when we are constantly reloading
local sleepTimerMenu = hs.menubar.new()
sleepTimerMenu:setTitle("☾")

-- Interval between sleep times
-- 15, 25, 45, custom, add five, remove five
local sleepInterval = 15
local presetCount = 3
local sleepTimes = {1, 2, 3}
local sleepTable = {}

-- dynamic chooser options
-- maybe eventually have these user configurable with persistence?
for i = 1, presetCount do
    -- inserts resolutions width in to choicesXZLhd table so we can iterate through them easily later
    table.insert(sleepTable, {
        ["id"] = i,
        ["action"] = "start",
        ["m"] = i * sleepInterval,
        ["text"] = i * sleepInterval .. " minutes",
    })
end

-- literally a bad way to write a switch in lua
function obj:garbageSwitch(case)

    local switch = {
        ["start"] = function()	-- for case 1
            hs.alert("start")
        end,
        ["stop"] = function()	-- for case 2
            hs.alert("stop")
        end,
        ["inc"] = function()	-- for case 3
            hs.alert("inc")
        end,
        ["dec"] = function()	-- for case 3
            hs.alert("dec")
        end
    }

    local f = switch[case]
    if(f) then
        f()
    else
        hs.alert("fell through")
    end
end

-- static chooser entries
-- increase timer by 5 / decrease timer by 5 / stop timer
local staticOptions = {
    {
        ["id"] = #sleepTable + 1, 
        ["action"] = "stop",
        ["m"] = 0,
        ["text"] = "Stop current timer"
    },
    {
        ["id"] = #sleepTable + 1, -- doesn't currently work
        ["action"] = "inc",
        ["m"] = 5,
        ["text"] = "+5 minutes"
    },
    {
        ["id"] = #sleepTable + 1, -- doesn't currently work
        ["action"] = "dec",
        ["m"] = 5,
        ["text"] = "-5 minutes"
    },
}

for i = 1, #staticOptions do
    table.insert(sleepTable, staticOptions[i])
end

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

    if seconds <= 0 then
        return "☾"
    elseif seconds > 3600 then
        hs.alert("Timer must be lower than an hour")
        return "error"
    else
        hours = string.format("%02.f", math.floor(seconds / 3600));
        mins = string.format("%02.f", math.floor(seconds / 60 - (hours*60)));
        secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins *60));
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
            sleepTimerMenu:setTitle(obj:formatSeconds(interval))
        end
    )
end


function obj:timerChooserCallback(choice)
    -- switch on action
    if choice['action'] == 'stop' then
        if not self.timerEvent == nil then
            self:deleteTimer()
        else
            hs.alert("No timer to stop")
        end
    elseif choice['m'] == nil then
        -- should do a check to see if customCountdown is a number
        local customCountdown = tonumber(self.chooser:query())
        if customCountdown < 200 and customCountdown > 0 then
            self:newTimer(customCountdown)
        else 
            hs.alert("Specified value is too big or too small or nonsensical")
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

function obj:init()
    self.chooser = hs.chooser.new(
        function(choice)
            if not (choice) then
                print(self.chooser:query())
            else
                self:timerChooserCallback(choice)
            end
        end
    )

    self.chooser:choices(sleepTable)
    self.chooser:rows(#sleepTable)

    self.chooser:queryChangedCallback(
        function(query)
            if query == '' then
                self.chooser:choices(sleepTable)
            else
                local choices = {
                {["id"] = 0, ["text"] = "Custom", subText="Enter a custom time"},
                }
                self.chooser:choices(choices)
            end
        end
    )

    self.chooser:width(20)
    self.chooser:bgDark(true)

    return self
end

-- change this to chooser with custom time setting

function obj:processKey(i)
    -- does lua have switches? It's got to right....
    -- refactor later (too lazy now ¯\_(ツ)_/¯)
    if i == 'y' then
        hs.alert('stopping countdown')
        self:deleteTimer()
        s:exit()
    elseif i == 'n' then
        s:exit()
    else
        -- GODDAMN ABSTRACT THIS OUTTA THIS HUGE FUNCTION
        -- take passsed parameter, multiply by 5 * 60 to get number of seconds
        countdown = tonumber(i) * 5 * 60
        self.timerEvent = hs.timer.doAfter(
            countdown, 
            function() 
                hs.caffeinate.systemSleep() 
            end)
        self.timerDisplay = hs.timer.doEvery(
            1, 
            function()
                countdown = countdown - 1
                sleepTimerMenu:setTitle(obj:formatSeconds(countdown))
            end)       

        s:exit()
    end
end

function obj:deleteTimer()
    self.timerDisplay:stop()
    self.timerEvent:stop()
    sleepTimerMenu:setTitle("☾")
    self.timerEvent = nil
    self.timerDisplay = nil
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
    print("-- Stopping Zzz")
    self.chooser:hide()
    if self.hotkeyShow then
        self.hotkeyShow:disable()
    end
    return self
end

return obj
