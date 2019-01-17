local obj = {}
obj.__index = obj

obj.name = "Timers"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue/hammerspoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.hotkeyShow = nil

obj.timers = {}
obj.timerCount = 0

local minMins = 0
local minSecs = minMins / 60

local maxMins = 300
local maxSecs = maxMins * 60

local sleepInterval = 0.2
local updateInterval = 5
local presetCount = 3

obj.createTimerChoices = {}
obj.startMenuChoices = {}
obj.startMenuCustomChoices = {}
obj.modifyTimerChoices = {}
obj.modifyMenuChoices = {}

local Timer = {}
Timer.__index = Timer

local function formatSeconds(seconds)
    -- from https://gist.github.com/jesseadams/791673
    local seconds = tonumber(seconds)
    if seconds then
        hours = string.format("%02.f", math.floor(seconds / 3600));
        mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)));
        secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60));
        return hours ..":".. mins..":"..secs
    else 
        return false
    end
end

function Timer:new(name, title, type)
    -- o = o or {}
    -- setmetatable(o, self)
    local tmr = {}             -- our new object
    setmetatable(tmr,Timer)

    tmr.name = name
    tmr.title = title
    tmr.type = type
    tmr.endEvent = tmr:processType(tmr.type)

    print("title is: " .. tmr.title)
    tmr.menu = hs.menubar.new():setMenu(Timer:createMenu(tmr)):setTitle(tmr.title)

    return tmr
end

function Timer:processType()
    if self.type == "sleep" then
        return function() hs.caffeinate.systemSleep() end
    elseif self.type == "alert" then
        return function() hs.alert("Timer finished!") end
    elseif self.type == "annoying" then
        -- make a persistent alert that doesn't go away until dismissed
        -- and repeats a sound every 10 seconds?
        return function() 
            hs.alert("Timer finished!") 
            hs.alert("Timer finished!") 
            hs.alert("Timer finished!") 
            hs.alert("Timer finished!") 
            hs.alert("Timer finished!") 
            hs.alert("Timer finished!") 
        end
    else 
        return hs.alert("no function provided")
    end
end

function Timer:startTimer(mins)
    if self.timerEvent then
        hs.alert("Timer already started")
    else
        self:updateMenu()
        -- self.sleepTimerMenu:setMenu(self.modifyMenuChoices)
        -- self:updateBrightnessAndVol(timerInMins)
        -- hs.brightness.set(50) -- only works if automatically adjust brightness is off
        self.timerEvent = hs.timer.doAfter(
            tonumber(mins) * 60,
            function()
                self:deleteTimer()
                self:endEvent()
                -- hs.caffeinate.systemSleep()
            end
        )
    end
end

function Timer:deleteTimer()
    self.timerEvent:stop()
    self.timerEvent = nil
    -- self.menu:delete()
    self.menu:setTitle(self.title)

    -- print("self from delete" .. i(self))

    -- for k,v in pairs(self) do
    --     print("key: " .. k)
    --     self.k = nil
    -- end

    -- self = nil

    -- return self
end



function Timer:cleanup()
    self.timerEvent:stop()
    self.timerEvent = nil
    self.menu:delete()

    print("self from delete" .. i(self))

    for k,v in pairs(self) do
        print("key: " .. k)
        self.k = nil
    end

    self = nil

    return self
end

function Timer:updateMenu()
    hs.timer.doWhile(
        function()
            return self.timerEvent
        end,
        function()
            local timeLeft = self.timerEvent:nextTrigger()
            if math.floor(timeLeft) == 10 then
                hs.alert("Sleeping in 10 seconds...")
                -- obj.menuFont = almostDone
            end
            
            self.menu:setTitle(self.title .. " " .. formatSeconds(timeLeft))
        end,
        1
    )
end


function obj:styleText(text)
    return hs.styledtext.new(
        text
        -- self.menuFont
    )
end

function Timer:actionHandler(choice)
    if choice['action'] == 'stop' and self.timerEvent then
        -- handle stop timer
        self:deleteTimer()
    elseif choice['action'] == 'adjust' and self.timerEvent then
        -- handle inc/dec timer
        self:adjustTimer(choice['m'])
    elseif choice['m'] == nil then
        -- handle custom timer
        print(i(self))
        self:startTimer(tonumber(choice))
        -- self.chooser:query(nil)
    else
        -- handle normal choice
        self:startTimer(choice['m'])
        -- print(i(cur_timer))
        -- self:startTimer(tonumber(choice['m']))
    end
end

function Timer:createMenu()
    self.timerMenu = {}
    print("SELF FROM CREATE!")
    print(i(self))

    for i = 1, presetCount do
        table.insert(self.timerMenu, {
            title = tostring(i * sleepInterval .. "m"),
            ["id"] = i,
            ["action"] = "create",
            ["m"] = i * sleepInterval,
            ["text"] = i * sleepInterval .. "m",
            fn = function() Timer:actionHandler(self.timerMenu[i]) end,
        })
    end

    print(i(self.timerMenu))

    return self.timerMenu
end

function obj:addTimer(name, title, type)
    local newTimer = Timer:new(name, title, type)

    -- local menu = hs.menubar.new():setMenu(obj.startMenuChoices):setTitle(title)
    
    -- local timer = nil


    self.timers[name] = newTimer


    -- table.insert(obj.timers, 
    --     [name] = {
    --         ["name"] = name,
    --         ["menu"] = menu,
    --         ["type"] = type,
    --     }
    --         -- ["timer"] = timer,
    -- )
end

function Timer:toggleTimer(name)
    for i = 1, #obj.timers do
        if obj.timers[i].name == name and obj.timers[i].timer then
            if obj.timers[i].timer:running() then
                obj.timers[i].timer:stop()
            else
                obj.timer[i].timer:start()
            end
            return true
        end
    end
    
    return false
end

function obj:deleteTimer(name)
    obj.timers[name].menu:delete()
    for k,v in pairs(obj.timers[name]) do
        obj.timers[name][k] = nil
    end

    obj.timers[name] = nil
    -- for i = 1, #obj.timers do 
    --     print(i(obj.timers[i]))
    --     print(i(obj.timers[i].name))
    --     if obj.timers[i].name == name then
    --         -- obj.timers[i].menu:delete()
    --         -- also delete timer properly

    --         for k,v in pairs(obj.timers[i]) do
    --             k = nil
    --         end

    --         obj.timers[i] = nil
    --         return true
    --     end
    -- end

    return false
end

function obj:init()
    self:addTimer("sleep", "sleep", "sleep")

    self:addTimer("alert", "alert", "alert")

    self:addTimer("annoying", "annoy", "annoying")

end

return obj