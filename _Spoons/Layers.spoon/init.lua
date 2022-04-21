--- === Layers ===
---
--- Yikes. Attempt to bind a quick dbl press of fn key to changing keyboard layout Layer
--- eg. custom layout for sc2
---
---

local obj = {}
obj.__index = obj

-- obj.logger.i('Initializing CTRL-ESC.spoon logger...')
obj.name = "Layers"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue/hammerspoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.logger = hs.logger.new("LAYERS")

obj.prev_mods = {}

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
    elseif self.prev_mods["ctrl"] and len(cur_mods) == 0 and self.send_esc then
        -- so, if our conditions are met, we send the esc keyevent
        -- note: newKeyEvent seems much much faster than keyStroke
        -- for somereason
        hs.eventtap.event.newKeyEvent({}, "escape", true):post()
        hs.eventtap.event.newKeyEvent({}, "escape", false):post()

        -- then we set our flag back to false
        self.send_esc = false
    else
        -- in any other case, we don't want to send esc
        self.send_esc = false
    end

    self.prev_mods = cur_mods
    return false
end

function round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function obj:mod_event_handler_fn(event)
    local cur_mods = event:getFlags()
    local cur_keys = event:getKeyCode()
    local cur_type = event:getType()
    local ts = event:timestamp()

    -- local cur_keys = event:getKeyCode()
    if cur_keys ~= 179 then
        self.fn_count = 0
        return false
    end

    if self.fn_count == 0 then
        obj.first_invocation = event:timestamp() / 1000000000
        print(obj.first_invocation)
    end

    keypress_interval = 0

    if self.fn_count == 1 then
        obj.second_invocation = event:timestamp() / 1000000000
        keypress_interval = round(obj.second_invocation - obj.first_invocation, 1)
        hs.alert("Interval: " .. keypress_interval)
    end

    if keypress_interval > 1 then
        self.fn_count = 0
        obj.first_invocation = 0
        obj.second_invocation = 0
        return false
    end

    if self.fn_count == 1 and keypress_interval < 1 then
        hs.alert("Layer Switched!")
        obj.first_invocation = 0
        obj.second_invocation = 0
        keypress_interval = 0
        self.fn_count = 0
        return false
    end

    self.fn_count = self.fn_count + 1

    self.prev_mods = cur_mods
    return false
end

function obj:init()
    self.send_esc = false
    self.fn_count = 0
    self.first_invocation = 0
    self.second_invocation = 0

    self.fn_down =
        hs.eventtap.new(
        -- {hs.eventtap.event.types.flagsChanged},
        {hs.eventtap.event.types.keyDown},
        function(event)
            obj:mod_event_handler_fn(event)
        end
    )
    self.non_ctrl_tap =
        hs.eventtap.new(
        {hs.eventtap.event.types.keyDown},
        function(event)
            self.send_esc = false
            return false
        end
    )
end

function obj:start()
    self.logger.df("CTRLESC.spoon started")

    self.fn_down:start()
    -- self.non_ctrl_tap:start()
end

function obj:stop()
    obj.logger.df("CTRLESC.spoon stopped")

    self.fn_down:stop()
    -- self.non_ctrl_tap:stop()

    self.send_esc = false
    self.prev_mods = {}
end

return obj
