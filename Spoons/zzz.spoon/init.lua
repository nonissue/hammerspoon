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

obj.name = "zzz"
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

-- hotkey binding not working
function obj:bindHotkeys(mapping)
    local def = {
        showPaywallBuster = hs.fnutils.partial(self:show(), self),
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

function obj:secondsLeft()
    local seconds = self:formatSeconds(
        self.timerEvent:nextTrigger()
    )
    return seconds
end

-- change this to chooser with custom time setting
-- which can be copied from paywall buster
function obj:init()
    local sleepTimerMenu = hs.menubar.new()
    sleepTimerMenu:setTitle("☾")
    s = hs.hotkey.modal.new('cmd-alt-ctrl', 's')
    s:bind('', 'escape', function() hs.alert.closeAll() s:exit() end)

    function displaySleepOptions()
        if self.timerEvent then
            hs.alert("Countdown already started with: " .. obj:secondsLeft() .. " left", 5)
            hs.alert("Would you like to cancel the timer? (y/n)")
        else
            hs.alert("Choose your sleep time: ", 99)
            hs.alert("1: 5m / 2: 10m / 3: 15m / 4: 20m / 5: 25m / 6: 30m", 99)
        end
    end

    for i = 1,5 do
        s:bind({}, tostring(i), function() obj:ProcessKey(i) end)
    end

    s:bind({}, "y", function() obj:ProcessKey("y") end)
    s:bind({}, "n", function() obj:ProcessKey("n") end)

    -- top secret janky dev
    s:bind({}, "0", function() obj:ProcessKey("0") end)

    function s:entered() displaySleepOptions() end
    function s:exited() hs.alert.closeAll() end
end

function obj:ProcessKey(i)
    -- does lua have switches? It's got to right....
    -- refactor later (too lazy now ¯\_(ツ)_/¯)
    if i == 'y' then
        hs.alert('stopping countdown')
        self.timerDisplay:stop()
        self.timerEvent:stop()
        sleepTimerMenu:setTitle("☾")
        self.timerEvent = nil
        self.timerDisplay = nil
        s:exit()
    elseif i == 'n' then
        s:exit()
    elseif i == "0" then
        -- top secret janky dev stuff
        countdown = 10
        sleepTimerMenu:setTitle(obj:formatSeconds(countdown))
        print("Secret dev stuff!" .. countdown)
        self.timerEvent = hs.timer.doAfter(countdown, function() hs.caffeinate.systemSleep() end)
        s:exit()
    else
        -- GODDAMN ABSTRACT THIS OUTTA THIS HUGE FUNCTION
        -- take passsed parameter, multiply by 5 * 60 to get number of seconds

        -- COULD technically use the same timer for both functions
        -- just add an if branch to counterDisplay, and if countdown = 0, 
        -- put computer to sleep

        -- Also need to handle when a computer does go to sleep
        -- should delete existing timer? could also write some kind of 
        -- watcher to check for previous timer when computer wakes up from sleep

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

return obj
