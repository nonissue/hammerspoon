-- Todo:
-- [ ] Start/stop
-- [ ] Custom times?
-- [ ] Menu bar item
-- [ ] Not sure if this even works

SleepTimer = {}
SleepTimer.__index = Action
local sleepTimerMenu = hs.menubar.new()

function SleepTimer.new()
    s = hs.hotkey.modal.new('cmd-alt-ctrl', 's')
    s:bind('', 'escape', function() hs.alert.closeAll() s:exit() end)

    function displaySleepOptions()
        if newCountdown then
            -- print(newCountdown)
            -- print(newCountdown:nextTrigger())
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

    function s:entered() displaySleepOptions() end
    function s:exited() hs.alert.closeAll() end
end

function SleepTimer.ProcessKey(i)
    if i == 'y' then
        print('stopping countdown')
        hs.alert('stopping countdown')
        -- Stops the timer so we don't have a run away
        newCountdown:stop()
        sleepTimerMenu:delete()
        -- removes references to object as even though it is stopped it still exists
        newCountdown = nil
        s:exit()
    else
    -- take passsed parameter, multiply by 5 * 60 to get number of seconds

        countdown = tonumber(i) * 5 * 60
        sleepTimerMenu:setTitle(countdown)
        print(countdown)
        newCountdown = hs.timer.doAfter(countdown, function() hs.caffeinate.systemSleep() end)
    -- newCountdown = hs.timer.doAfter(countdown, function() print('sleeping in five seconds!') end)
    -- hs.timer.doAfter(co)
        s:exit()
        -- return newCountdown
    end
end


-- I don't think this does anything.
function SleepTimer.start(countdown)

end

return SleepTimer
