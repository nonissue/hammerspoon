--- === CMDESC ===
---
--[[

HOLY FUCK I THOUGHT THE SHORTCUT FOR CYCLING APP WINDOWS win_scr_frame

⌘ + ~

So I was like, how the fuck do we get ~?

Spent all this time figuring out how to hit ~ (shift + keycode 50)
But.. it's just ⌘ + `

EDIT: Nope, it's shift + grave 

Keycodes

Escape = 53
Accent Grave = 50
Tilde = mods(shift) + 50

This types a tilde:

hs.eventtap.event.newKeyEvent({"cmd", "shift"}, 50, true):post()

oh shit, it seems to be really working?

]]
local obj = {}
obj.__index = obj

-- obj.logger.i('Initializing CMD-ESC.spoon logger...')
obj.name = "CMDESC"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue/hammerspoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.logger = hs.logger.new("CMDESC")
obj.logging = true

obj.cmd_held_down_alone = false
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
    local cur_keycode = event:getKeyCode()

    local function log_shit()
        if (obj.logging) then
            obj.logger.i(
                "\n\n\tcmd dwn: " ..
                    tostring(self.cmd_held_down_alone) ..
                        "\t\tcur_mods: " .. len(cur_mods) .. "\t\tprev_mods: " .. len(self.prev_mods) .. "\n"
            )
        end
    end

    -- obj.logger.i(i(event:getFlags()))

    if cur_mods["cmd"] and len(cur_mods) == 1 then
        -- cmd is down alone! start watching for next key pressed
        -- we set cmd_held_down == true
        self.cmd_held_down_alone = true

        -- logging
        log_shit()
    elseif len(cur_mods) == 0 and len(self.prev_mods) == 1 and self.cmd_held_down_alone then
        -- logging
        -- cmd was down alone, but has been released without escape being pressed.
        self.cmd_held_down_alone = false
        -- obj:setMenuItems()

        log_shit()
    else
        -- cases that fall through?
        -- we could set self.cmd_held_down_alone = true
        self.cmd_held_down_alone = false

        log_shit()
    end

    if self.cmd_held_down_alone and cur_keycode == 53 then
        hs.alert("⌘ + ~")

        obj.logger.i("Success! Firing: ⌘ + ~")
        -- event:setFlags({shift = true})
        -- hs.eventtap.event.newKeyEvent({"cmd"}, 50, true):post()
        hs.eventtap.event.newKeyEvent({"shift"}, "`", true):post()
        hs.eventtap.event.newKeyEvent({"shift"}, "`", false):post()
        -- hs.eventtap.event.newKeyEvent({"cmd", "shift"}, 50, true):post()
        self.cmd_held_down_alone = false
    end

    self.prev_mods = cur_mods

    return false
end

function obj:init()
    self.send_tilde = false
    self.cmd_held_down_alone = false

    self.cmd_tap =
        hs.eventtap.new(
        {hs.eventtap.event.types.flagsChanged},
        function(event)
            local mods = event:getFlags()
            if not mods["cmd"] and not mods["shift"] then
                -- obj.logger.i("Not cmd or shift, we don't care")
                return false
            end
            -- obj.logger.e("cmd_tap fired")
            -- obj.logger.e(i(event))
            -- obj.logger.e(event:getKeyCode())
            -- hs.alert("caps fired")
            obj:mod_event_handler(event)
        end
    )
    self.non_cmd_tap =
        hs.eventtap.new(
        {hs.eventtap.event.types.keyDown},
        function(event)
            -- obj.logger.e("non_cmd_tap fired")
            -- obj.logger.e(i(event))
            -- obj.logger.e(event:getKeyCode())]
            -- local cur_keycode = event:getKeyCode()

            self.send_tilde = false

            if (not event:getFlags("cmd") or not event:getFlags("shift")) and event:getKeyCode() then
                return false
            else
                obj:mod_event_handler(event)
            end

            return false
        end
    )
end

function obj:start()
    self.logger.df("CMDESC.spoon started")

    self.cmd_tap:start()
    self.non_cmd_tap:start()
end

function obj:stop()
    obj.logger.df("CMDESC.spoon stopped")

    self.cmd_tap:stop()
    self.non_cmd_tap:stop()

    self.send_esc = false
    self.prev_mods = {}
end

return obj
