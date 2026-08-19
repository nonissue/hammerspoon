--- === AppWinCycle ===
---
--- Restores convenient macOS application-window cycling on compact keyboards
--- without a dedicated grave (`) key.
---
--- Command+Escape is remapped to Command+` when the key event originates
--- from a keyboard matching the configured keyboard type. Command+Shift+Escape
--- similarly maps to Command+Shift+` for cycling in the opposite direction.
---
--- Events from other keyboards are passed through unchanged.

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "AppWinCycle"
obj.version = "1.0"
obj.author = "Andy"
obj.homepage = "https://andy.ws"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- AppWinCycle.keyboard_type
--- Variable
--- The macOS keyboard type for which AppWinCycle should enable its remappings.
---
--- The keyboard type can be determined from a key event using
--- `hs.eventtap.event.properties.keyboardEventKeyboardType`.
obj.keyboard_type = nil

--- AppWinCycle:start()
--- Method
--- Starts AppWinCycle and enables application-window cycling remappings.
---
--- The following remappings are enabled for the configured keyboard type:
---
--- * Command+Escape → Command+`
--- * Command+Shift+Escape → Command+Shift+`
---
--- Parameters:
---
--- * None
---
--- Returns:
---
--- * The AppWinCycle Spoon object
function obj:start()
    if self.event_tap then
        return self
    end

    self.event_tap = hs.eventtap.new(
        { hs.eventtap.event.types.keyDown },
        function (event)
            local keyboard_type = event:getProperty(
                hs.eventtap.event.properties.keyboardEventKeyboardType
            )

            -- Ignore events originating from other keyboards.
            if keyboard_type ~= self.keyboard_type then
                return false
            end

            -- Escape has the macOS virtual keycode 53.
            if event:getKeyCode() ~= 53 then
                return false
            end

            local flags = event:getFlags()

            -- Command+Escape → Command+`
            --
            -- Cycle forward through windows belonging to the active
            -- application.
            if flags.cmd
                and not flags.shift
                and not flags.alt
                and not flags.ctrl
            then
                hs.eventtap.keyStroke({ "cmd" }, "`", 0)
                return true
            end

            -- Command+Shift+Escape → Command+Shift+`
            --
            -- Cycle backward through windows belonging to the active
            -- application.
            if flags.cmd
                and flags.shift
                and not flags.alt
                and not flags.ctrl
            then
                hs.eventtap.keyStroke({ "cmd", "shift" }, "`", 0)
                return true
            end

            return false
        end
    )

    self.event_tap:start()

    return self
end

--- AppWinCycle:stop()
--- Method
--- Stops AppWinCycle and disables its application-window cycling remappings.
---
--- Parameters:
---
--- * None
---
--- Returns:
---
--- * The AppWinCycle Spoon object
function obj:stop()
    if self.event_tap then
        self.event_tap:stop()
        self.event_tap = nil
    end

    return self
end

return obj
