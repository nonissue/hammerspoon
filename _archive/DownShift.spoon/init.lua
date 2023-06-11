--- === DownShift ===
---
--- Working I think
--- Concerned window filter is really noisy and may have performance implications

--- hs.application.name => SC2
--- bundleID: com.blizzard.starcraft2
---
--- hs.redshift.start(3500, "21:30", "11:00", 1)
--- hs.redshift.stop()
--- hs.redshift.toggle()

--[[
Color temp range: 1000K - 10,000K (default 6500K)

3600K and 1400K; lower values (minimum 1000K) result in a more pronounced adjustment

LOL just use this from hammerspoon docs:

local wfRedshift=hs.window.filter.new({VLC={focused=true},Photos={focused=true},loginwindow={visible=true,allowRoles='*'}},'wf-redshift')
-- start redshift: 2800K + inverted from 21 to 7, very long transition duration (19->23 and 5->9)
hs.redshift.start(2800,'21:00','7:00','4h',true,wfRedshift)

]]




local obj = {}
obj.__index = obj


obj.name = "DownShift"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue/hammerspoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.logger = hs.logger.new("DownShift")
obj.logger.i('Initializing DownShift.spoon logger...')

obj.window_filter = nil

function obj:start()
    if not obj.window_filter then
        obj.window_filter = hs.window.filter.new(
            { SC2 = { focused = true }, "Code", loginwindow = { visible = true, allowRoles = '*' } },
            'window_filter')
        -- start redshift: 2800K + inverted from 21 to 7, very long transition duration (19->23 and 5->9)

        hs.redshift.start(2500, '21:00', '11:00', '1h', false, obj.window_filter)
    else
        hs.alert("Error: DownShift is already running!")
    end

    hs.alert("Started DownShift!")
end

function obj:stop()
    if obj.window_filter then
        hs.redshift.stop()
        obj.window_filter = nil
    end
end

-- get length of table so we can check how many keys
-- method borrowed from
-- https://gist.github.com/zcmarine/f65182fe26b029900792fa0b59f09d7f
local function len(t)
    local length = 0
    -- changed this to stateless iterators
    -- and i think it's working?
    for _, _ in pairs(t) do
        length = length + 1
    end
    return length
end

function obj:app_watcher_callback(event)

end

function obj:init()
    self.downshift_app_watcher = hs.application.watcher.new(
        function(name, event, app)
            if event == hs.application.watcher.activated then
                if name == "iTerm2" then
                    self.ctrl_tap:start()
                    self.non_ctrl_tap:start()
                else
                    self.ctrl_tap:stop()
                    self.non_ctrl_tap:stop()
                end
            end
        end
    )
end

-- function obj:start()
--     self.logger.df("DownShift.spoon started")

--     self.ctrl_tap:start()
--     self.non_ctrl_tap:start()
-- end

-- function obj:stop()
--     obj.logger.df("DownShift.spoon stopped")

--     self.ctrl_tap:stop()
--     self.non_ctrl_tap:stop()

--     self.send_esc = false
--     self.prev_mods = {}
-- end

return obj
