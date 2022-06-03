--- === CMDTAB ===
---
--- When using command tab to switch to a running app,
--- open a new window if none are open
---

local obj = {}
obj.__index = obj

-- obj.logger.i('Initializing CTRL-ESC.spoon logger...')
obj.name = "CMDTAB"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue/hammerspoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.logger = hs.logger.new("CMD-TAB")

obj.prev_mods = {}

obj.cmd_down = false

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

function obj:handleModifierEvent(event)
    -- so, a lot of this branching is probably completely pointless
    -- i initially wanted to have so many conditionals so that we could exit as soon as we know
    -- the eventtap event has nothing to do with switching windows, but im not sure if just returning early matters?

    local cur_mods = event:getFlags()
    local cur_keycode = event:getKeyCode()
    local ignore_next_alt = false

    if cur_mods["ctrl"] or cur_mods["capslock"] or cur_mods["fn"] then
        obj.logger.i("IGNORE: CTRL / CAPSLOCK / FN down")

        self.prev_mods = cur_mods
        return false
    elseif len(cur_mods) == 0 and (self.prev_mods["ctrl"] or self.prev_mods["capslock"] or self.prev_mods["fn"]) then
        obj.logger.i("IGNORE: CTRL / CAPSLOCK / FN up")

        self.prev_mods = cur_mods
        return false
    end

    -- I don't really know when we hit this, or what it's for?
    if len(cur_mods) == 0 and not (self.prev_mods["cmd"] or self.prev_mods["alt"]) then
        obj.logger.e("new ignoring. " .. tostring(not (self.prev_mods["cmd"] or self.prev_mods["alt"])))

        self.prev_mods = cur_mods
        return false
    end

    if len(cur_mods) == 0 and not self.prev_mods["cmd"] then
        obj.logger.i("ignoring mod release")

        self.prev_mods = cur_mods
        return false
    end

    if cur_mods["cmd"] and len(cur_mods) == 1 then
        obj.logger.i("INFO: ⌘↓ DETECTED")
        obj.logger.i("INFO: Watching for tab key...")

        self.cmd_down = true
    elseif self.prev_mods["cmd"] and len(cur_mods) == 0 and self.cmdTabMode then
        obj.logger.i("INFO: Exiting window switcher")

        self.cmd_down = false
        self.cmdTabMode = false

        -- obj.menubar:setTitle("CMDTAB: IDLE")
        event:setFlags({alt = true})
        ignore_next_alt = true

        self.prev_mods = cur_mods
        return false
    elseif len(cur_mods) == 0 and len(self.prev_mods) ~= 0 then
        obj.logger.i("INFO: Ignoring. ⌘ released without tab being pressed.")
    elseif len(cur_mods) == 1 and cur_mods["alt"] then
        obj.logger.i("INFO: Alt pressed by itself")
    elseif len(cur_mods) == 2 and cur_mods["alt"] and cur_mods["cmd"] then
        obj.logger.e("!! user pressed alt + cmd themselves")
    else
        -- this could be shift being used to tab backwards through window switcher ui
        obj.logger.e("!! another unhandled case?")
    end

    self.prev_mods = cur_mods
    return false
end

obj.cmdTabMode = false

function obj:handleKeyUpEvent(event)
    local cur_keycode = event:getKeyCode()
    local cur_flags = event:getFlags()

    if cur_keycode ~= 48 then
        return false
    end

    if not cur_flags["cmd"] then
        return false
    end

    if self.cmd_down and cur_keycode == 48 then
        -- obj.menubar:setTitle("CMDTAB: ACTIVE")
        -- hs.alert("CMDTAB mode entered")
        obj.logger.i("INFO: Entering window switcher")
        self.cmdTabMode = true
    else
        event:setFlags({})
        self.cmdTabMode = false
    end

    return
end

function obj:init()
    self.cmd_down = false

    self.modifierWatcher =
        hs.eventtap.new(
        {hs.eventtap.event.types.flagsChanged},
        function(event)
            obj:handleModifierEvent(event)
        end
    )

    self.keyUpWatcher =
        hs.eventtap.new(
        {hs.eventtap.event.types.keyUp},
        function(event)
            if not event:getFlags("cmd") then
                return false
            else
                obj:handleKeyUpEvent(event)
            end
        end
    )
end

function obj:start()
    self.logger.i("CMDTAB.spoon started")

    self.modifierWatcher:start()
    self.keyUpWatcher:start()

    -- obj.menubar = hs.menubar.new()
    -- obj.menubar:setTitle("CMDTAB: IDLE")
end

function obj:stop()
    obj.logger.i("CMDTAB.spoon stopped")

    self.modifierWatcher:stop()
    self.keyUpWatcher:stop()

    self.send_esc = false
    self.prev_mods = {}
end

return obj
