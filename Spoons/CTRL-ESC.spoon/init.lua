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

-- simplify branch logic
-- though it seems to be working
function obj:mod_handler_new(event)
    local cur_mods = event:getFlags()

    if self.event_tainted and len(cur_mods) == 0 then
        -- if more than one modifier has been pressed,
        -- we know we don't want to send escape
        self.event_started = false
        self.event_tainted = false
        self.prev_mods = cur_mods
        return false
    end

    if not (cur_mods["ctrl"] or self.prev_mods["ctrl"]) then
        -- set event_started to false as ctrl isn't being pressed 
        -- and wasn't pressed previously
        obj.logger.v("\n\nFirst!")
        obj.logger.v("\ncur_mods:\t" .. i(cur_mods) .. "\nprev_mods:\t" .. i(self.prev_mods))
        self.event_started = false

        self.prev_mods = cur_mods
        return false
    end

    if len(cur_mods) > 1 then
        self.event_started = false
        self.event_tainted = true

        self.prev_mods = cur_mods
        return false
        -- return false
    elseif cur_mods["ctrl"] then
        obj.logger.v("\nSecond!")
        obj.logger.v("\ncur_mods:\t" .. i(cur_mods) .. "\nprev_mods:\t" .. i(self.prev_mods))

        self.event_started = true
    elseif len(cur_mods) == 0 and self.event_started == true and not self.event_tainted then
        obj.logger.v("\nSend Esc!")
        obj.logger.v("\ncur_mods:\t" .. i(cur_mods) .. "\nprev_mods:\t" .. i(self.prev_mods))

        -- we know that prev_mods had to contain ctrl
        -- if we got here (first if statement) 
        -- so if cur_mods is empty, prev_mods had to have ctrl it
        -- and so it means ctrl was our only modifier and it is now
        -- key up, so send escape
        hs.eventtap.event.newKeyEvent({}, 'escape', true):post()
        hs.eventtap.event.newKeyEvent({}, 'escape', false):post()
        self.event_tainted = false
        self.event_started = false
    else 
        -- ctrl is not in event flags,
        -- do nothing!
        self.prev_mods = cur_mods
        print("event tainted?" .. tostring(self.event_tainted))
        obj.logger.v("\n\n\nERROR!")
        obj.logger.v("\ncur_mods:\t" .. i(cur_mods) .. "\nprev_mods:\t" .. i(self.prev_mods))
        return false
    end

    self.prev_mods = cur_mods
    -- self.event_tainted = false

    obj.logger.v("\nFell!!")
    obj.logger.v("\ncur_mods:\t" .. i(cur_mods) .. "\nprev_mods:\t" .. i(self.prev_mods))

    return false
end



function obj:mod_handler(event)
    local cur_mods = event:getFlags()

    -- obj.logger.v("\ncur_mods:\t" .. i(cur_mods) .. "\nprev_mods:\t" .. i(self.prev_mods))
    -- obj.logger.v("\nsend_esc:" .. tostring(self.send_esc) .. "\n")

    if len(cur_mods) == 0 and len(self.prev_mods) > 0 and not self.prev_mods['ctrl'] then
        -- just end this I think?
        self.send_esc = false
    elseif self.prev_mods["ctrl"] == cur_mods["ctrl"] then
        -- if ctrl was already pressed, and is still pressed, 
        -- event still going, so wait for next key event
        -- obj.logger.i("not handling event as ctrl hasn't changed")
        self.send_esc = false
        return false
    end

    if cur_mods["ctrl"] and len(cur_mods) == 1 and len(self.prev_mods) == 0 then
        -- only ctrl so far, so preparing to send escape on keyup
        self.send_esc = true
    elseif self.prev_mods["ctrl"] and len(cur_mods) == 0 and self.send_esc then
        -- ctrl pressed solo / event over since len(cur_mods) == 0
        -- obj.logger.v("Sending ESC / Event over")

       -- sending escape
        hs.eventtap.event.newKeyEvent({}, 'escape', true):post()
        hs.eventtap.event.newKeyEvent({}, 'escape', false):post()

        self.send_esc = false
    elseif len(cur_mods) > 0 and len(cur_mods) < len(self.prev_mods) then
        -- this is to handle the case where we have some modifiers
        -- left over, but they haven't been cleared and so 
        -- can contaminate the next time control is pressed
        self.send_esc = false

        -- returning true deletes the event
        return true
    elseif len(cur_mods) == 0 and len(self.prev_mods) > 0 and not self.prev_mods['ctrl'] then
        self.send_esc = false
    else
        self.send_esc = true
    end

    self.prev_mods = cur_mods

    return false
end

function obj:init() 
    obj.logger.i("CTRL-ESC.spoon initialized")
    obj.send_esc = false
    self.event_started = false
    self.event_tainted = false

    -- self.ctrl_tap = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(event) obj:mod_handler(event) end)
    self.ctrl_tap = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(event) obj:mod_handler_new(event) end)
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