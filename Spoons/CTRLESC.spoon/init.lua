--- === CTRLESC ===
---
--- Rebind caps lock to escape when pressed alone,
--- control modifier when pressed with other keys
---


--
-- Almost none of this is original work, just combined some existing solutions
-- See Readme for more info
--
--

-- TODO
-- Tests
-- Docs
-- Remove any utilities/functions speciifc to my config
-- Pull on a new hammerspoon config and see if it works
local obj = {}
obj.__index = obj


-- obj.logger.i('Initializing CTRL-ESC.spoon logger...')
obj.name = "CTRLESC"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue/hammerspoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.logger = hs.logger.new("CTRL-ESC")

obj.prev_mods = {}

-- get length of table so we can check how many keys
-- method borrowed from
-- https://gist.github.com/zcmarine/f65182fe26b029900792fa0b59f09d7f
local function len(t)
    local length = 0
    for k, v in pairs(t) do -- luacheck: ignore
        length = length + 1
    end
    return length
end

-- logic largely copied from
-- https://gist.github.com/zcmarine/f65182fe26b029900792fa0b59f09d7f
function obj:mod_event_handler(event)
    local cur_mods = event:getFlags()

    if cur_mods["ctrl"] and len(cur_mods) == 1 and len(self.prev_mods) == 0 then
        -- we want to go from NO modifiers pressed to only one pressed
        -- in order to consider sending escape.
        -- for example, in the case that user holds down:
        -- [ CMD ] -> [ CMD, CTRL ] -> [ CTRL ] -> [ ]
        -- We DO NOT want to send esc with this pattern
        self.send_esc = true
    elseif self.prev_mods['ctrl'] and len(cur_mods) == 0 and self.send_esc then
        -- so, if our conditions are met, we send the esc keyevent
        -- note: newKeyEvent seems much much faster than keyStroke
        -- for somereason
        hs.eventtap.event.newKeyEvent({}, 'escape', true):post()
        hs.eventtap.event.newKeyEvent({}, 'escape', false):post()

        -- then we set our flag back to false
        self.send_esc = false
    else
        -- in any other case, we don't want to send esc
        self.send_esc = false
    end

    self.prev_mods = cur_mods
    return false
end

function obj:init()
    self.send_esc = false

    self.ctrl_tap = hs.eventtap.new({hs.eventtap.event.types.flagsChanged},
        function(event)
            obj:mod_event_handler(event)
        end)
    self.non_ctrl_tap = hs.eventtap.new({hs.eventtap.event.types.keyDown},
        function(event)
            self.send_esc = false
	        return false
        end
    )
end

function obj:start()
    self.logger.df("CTRLESC.spoon started")

    self.ctrl_tap:start()
    self.non_ctrl_tap:start()
end

function obj:stop()
    obj.logger.df("CTRLESC.spoon stopped")

    self.ctrl_tap:stop()
    self.non_ctrl_tap:stop()

    self.send_esc = false
    self.prev_mods = {}
end

return obj