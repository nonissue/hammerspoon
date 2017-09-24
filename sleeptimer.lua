-- Todo:
-- [x] Start/stop
-- [ ] Custom times?
-- [x] Menu bar item
-- [x] Not sure if this even works
-- [x] Update Menubar icon with countdown
-- [ ] convert this to a proper module or spoon
-- Make menubar item a clickable list

-- Basically:
-- cmd + ctrl + opt + s brings up alert modals
-- select a sleep time, its set on a delay
-- eventually menu bar will show you time remaining
-- simple proof of concept works (if you press zero when
-- prompted for model, timer is set to 5 seconds and seems to work)


SleepTimer = {}
SleepTimer.__index = Action
local sleepTimerMenu = hs.menubar.new()
sleepTimerMenu:setTitle("☾")

function SecondsToClock(seconds)
    -- from https://gist.github.com/jesseadams/791673
    local seconds = tonumber(seconds)

    if seconds <= 0 then
        return "00:00:00";
    elseif seconds > 3600 then
        hs.alert("Timer must be lower than an hour")
        return "error"
    else
        hours = string.format("%02.f", math.floor(seconds/3600));
        mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
        secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
        return "☾ " .. mins..":"..secs
    end
end

function SleepTimer.new()
    s = hs.hotkey.modal.new('cmd-alt-ctrl', 's')
    s:bind('', 'escape', function() hs.alert.closeAll() s:exit() end)

    function displaySleepOptions()
        if newCountdown then
            hs.alert("Countdown already started with: " .. newCountdown:nextTrigger() .. "s left", 5)
            hs.alert("Would you like to cancel the timer? (y/n)")
        else
            hs.alert("Choose your sleep time: ", 99)
            hs.alert("1: 5m / 2: 10m / 3: 15m / 4: 20m / 5: 25m / 6: 30m", 99)
        end
    end

    for i = 1,5 do
        s:bind({}, tostring(i), function() SleepTimer.ProcessKey(i) end)
    end

    s:bind({}, "y", function() SleepTimer.ProcessKey("y") end)
    s:bind({}, "n", function() SleepTimer.ProcessKey("n") end)

    -- top secret janky dev
    s:bind({}, "0", function() SleepTimer.ProcessKey("0") end)

    function s:entered() displaySleepOptions() end
    function s:exited() hs.alert.closeAll() end
end

function SleepTimer.ProcessKey(i)
    -- does lua have switches? It's got to right....
    -- refactor later (too lazy now ¯\_(ツ)_/¯)
    if i == 'y' then
        hs.alert('stopping countdown')
        SleepTimer_active = false
        -- Stops the timer so we don't have a run away
        newCountdown:stop()
        sleepTimerMenu:delete()
        -- removes references to object as even though it is stopped it still exists
        newCountdown = nil
        s:exit()
    elseif i == 'n' then
        s:exit()
    elseif i == "0" then
        -- top secret janky dev stuff
        countdown = 5
        print("Secret dev stuff!" .. countdown)
        newCountdown = hs.timer.doAfter(countdown, function() hs.caffeinate.systemSleep() end)
        s:exit()
    else
        -- take passsed parameter, multiply by 5 * 60 to get number of seconds
        SleepTimer_active = true

        countdown = tonumber(i) * 5 * 60
        newCountdown = hs.timer.doAfter(countdown, function() hs.caffeinate.systemSleep() end)
        counterDisplay = hs.timer.doEvery(1, 
            function() 
                countdown = countdown - 1
                sleepTimerMenu:setTitle(SecondsToClock(countdown))
            end
         )       

        s:exit()
    end
end

return SleepTimer
