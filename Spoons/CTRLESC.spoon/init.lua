-- 
-- Almost none of this is original work, just combined some existing solutions
-- See Readme for more info
--

-- TODO
-- [EDIT: I probably wont, sending ESCAPE on keyup is better imo] add delay timer?
-- Tests
-- Docs
-- Remove any utilities/functions speciifc to my config
-- Pull on a new hammerspoon config and see if it works


local obj = {}
obj.__index = obj

obj.logger = hs.logger.new('CTRL-ESC', 'verbose')
obj.logger.i('Initializing CTRL-ESC.spoon logger...')

obj.name = "CTRLESC"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue/hammerspoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.prev_mods = {}
obj.msg = "MODS: "

-- get length of table so we can check how many keys
local function len(t)
    local length = 0
    for k, v in pairs(t) do
    	length = length + 1
    end
    return length
end

-- i tried to simplify this, but ended up making it more complicated
-- but i think it works better though ?
function obj:mod_handler_new(event)
    local cur_mods = event:getFlags()
    print("\n\nkey event")
    print("cur_mods" .. i(cur_mods))
    print("prev_mods" .. i(self.prev_mods))

    if self.event_tainted and len(cur_mods) == 0 then
        -- len(cur_mods) means this will only be called on
        -- the LAST modifier flag keyup event
        -- if the event was tainted when the last key goes up,
        -- we can clear the event_tainted flag 
        self.event_started = false
        self.event_tainted = false
        self.prev_mods = cur_mods

        return false
    end

    if not (cur_mods["ctrl"] or self.prev_mods["ctrl"]) then
        -- set event_started to false as ctrl isn't being pressed 
        -- and wasn't pressed previously
        self.event_started = false
        self.prev_mods = cur_mods

        return false
    end

    if len(cur_mods) > 1 then
        -- if we have more than one key modifier pressed,
        -- we don't want to send esc
        -- This handles the following case: 
        -- if the user presses cmd, then ctrl
        -- then releases cmd, then releases ctrl, 
        -- we don't want to send esc even though
        -- prev_mods will be { ctrl = true } and len(cur_mods) == 0
        self.event_started = false
        self.event_tainted = true

        self.prev_mods = cur_mods
        return false
    elseif cur_mods["ctrl"] then
        -- not sure if this branch is needed tbh
        self.event_started = true
    elseif len(cur_mods) == 0 and self.event_started == true and not self.event_tainted then
        -- we know that prev_mods had to contain ctrl
        -- so if cur_mods is empty, prev_mods had to have ctrl it
        -- and so it means ctrl was our only modifier and it is now
        -- key up, so send escape

        hs.eventtap.event.newKeyEvent({}, 'escape', true):post()
        hs.eventtap.event.newKeyEvent({}, 'escape', false):post()
        self.event_tainted = false
        self.event_started = false
    else 
        self.prev_mods = cur_mods

        return false
    end

    self.prev_mods = cur_mods

    return false
end



function obj:mod_handler(event)
    local cur_mods = event:getFlags()
    print("\n\nkey event")
    print("cur_mods" .. i(cur_mods))
    print("prev_mods" .. i(self.prev_mods))

    if len(cur_mods) == 0 and len(self.prev_mods) > 0 and not self.prev_mods['ctrl'] then
        -- just end this I think?
        self.send_esc = false
    elseif self.prev_mods["ctrl"] == cur_mods["ctrl"] then
        self.send_esc = false
        self.prev_mods = cur_mods
        return false
    end

    if cur_mods["ctrl"] and len(cur_mods) == 1 and len(self.prev_mods) == 0 then
        -- only ctrl so far, so preparing to send escape on keyup
        self.send_esc = true
    elseif self.prev_mods["ctrl"] and len(cur_mods) == 0 and self.send_esc then
        -- ctrl pressed solo / event over since len(cur_mods) == 0
        obj.logger.v("Sending ESC / Event over")

       -- sending escape
        hs.eventtap.event.newKeyEvent({}, 'escape', true):post()
        hs.eventtap.event.newKeyEvent({}, 'escape', false):post()

        self.send_esc = false
    elseif len(cur_mods) > 0 and len(cur_mods) < len(self.prev_mods) then
        -- this is to handle the case where we have some modifiers
        -- left over, but they haven't been cleared and so 
        -- can contaminate the next time control is pressed
        hs.alert("do we hit this?")
        self.send_esc = false

        -- returning true deletes the event
        return true
    elseif len(cur_mods) == 0 and len(self.prev_mods) > 0 and not self.prev_mods['ctrl'] then
        self.send_esc = false
    else
        self.send_esc = true
    end

    print("gotem x2")

    self.prev_mods = cur_mods

    return false
end

function obj:init() 
    obj.logger.i("CTRLESC.spoon initialized")
    obj.send_esc = false
    self.event_started = false
    self.event_tainted = false

    -- self.ctrl_tap = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(event) obj:mod_handler(event) end)
    self.ctrl_tap = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(event) obj:mod_handler(event) end)
    self.non_ctrl_tap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, 
        function(event)
            -- if any non-modifier key is pressed
            -- we disable our send_esc flag as
            -- escape is only sent when only control is 
            -- pressed
            -- hs.alert("non_ctrl_tap")
            self.send_esc = false
            self.event_started = false
	        return false
        end
    )

    -- im wrong about this
    -- FIXME
    -- (Based on spoon docs)
    -- user shouldn't have to invoke :start() imo
    -- FIXME --
    -- SOOO im wrong about this, hammerspon docs make it clear
    -- this shouldnt be here
    
    self:start()
end

function obj:start()
    obj.logger.i("CTRL-ESC.spoon started")

    obj.ctrl_tap:start()
    obj.non_ctrl_tap:start()
end

function obj:stop()
    obj.logger.i("CTRL-ESC.spoon stopped")

    self.ctrl_tap:stop()
    self.non_ctrl_tap:stop()

    self.send_esc = false
    self.prev_mods = {}
end

return obj