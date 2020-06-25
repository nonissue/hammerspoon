--[[ 
    === HammerText ===
    Based on: https://github.com/Hammerspoon/hammerspoon/issues/1042

    WARNING: Does not work reliably / unstable. I haven't spent much time debugging it.

    How to "install":
    - Simply copy and paste this code in your "init.lua".

    How to use:
      - Add this init.lua to ~/.hammerspoon/Spoons/HammerText.spoon
      - Add your hotstrings (abbreviations that get expanded) to the "keywords" list following the example format.
      
      ht = hs.loadSpoon("HammerText")
      ht.keywords ={
         nname = "Max Rydahl Andersen",
         xdate = function() return os.date("%B %d, %Y") end,
      }
      ht:start()

    Features:
    - Text expansion starts automatically in your init.lua config.
    - Hotstring expands immediately.
    - Word buffer is cleared after pressing one of the "navigational" keys.
      PS: The default keys should give a good enough workflow so I didn't bother including other keys.
          If you'd like to clear the buffer with more keys simply add them to the "navigational keys" conditional.

    Limitations:
    - Can't expand hotstring if it's immediately typed after an expansion. Meaning that typing "..name..name" will result in "My name..name".
      This is intentional since the hotstring could be a part of the expanded string and this could cause a loop.
      In that case you have to type one of the "buffer-clearing" keys that are included in the "navigational keys" conditional (which is very often the case).
--]]
--[[
Nonissue notes:
    December 27, 2019
        I think this causes memory leaks/performance problems, but I can't be sure.
        - [ ] Doesn't handle command-deleting a string (Possibly fixed December 28, 2019)
        - [ ] Doesn't handle selecting and then deleting a word

    Issues (Updated 2020-06-23)
    - [x]   Doesn't work when 'typing over' selected text
                - Oh, I think it is capturing keyboard shortcuts (Ie. When '⌘ + a' is pressed, a shouldn't be captured )
                - UPDATE: this, i think, is handled now
    - [ ]   HammerText doesn't discern between inputs, so if you start typing in one field, change focus (by say, 
            clicking on a new window, or invoke spotlight), it adds any new input to the existing 'word', even though
            the string is split across two windows
]]
local obj = {}
obj.__index = obj

-- Metadata
obj.name = "HammerText"
obj.version = "1.0"
obj.author = "Multiple Authors"

--- Keychain.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new("HammerText")

obj.keyWatcher = nil

--- HammerText.keywords
--- Variable
--- Map of keywords to strings or functions that return a string
--- to be replaced.
obj.keywords = {
    ["..name"] = "My name",
    ["..addr"] = "My address"
}

function obj:expander()
    local word = ""
    local keyMap = require "hs.keycodes".map
    local keyWatcher

    -- create an "event listener" function that will run whenever the event happens
    keyWatcher =
        hs.eventtap.new(
        {hs.eventtap.event.types.keyDown},
        function(ev)
            local keyCode = ev:getKeyCode()
            local char = ev:getCharacters()
            local flags = ev:getFlags()

            -- print_r(flags)
            -- if "delete" key is pressed
            if keyCode == keyMap["delete"] then
                if flags["cmd"] then
                    word = ""
                    return false
                end
                if #word > 0 then
                    -- remove the last char from a string with support to utf8 characters
                    local t = {}
                    for _, chars in utf8.codes(word) do
                        table.insert(t, chars)
                    end
                    table.remove(t, #t)
                    word = utf8.char(table.unpack(t))
                    obj.logger.i("Word after deleting: ", word)
                end
                return false -- pass the "delete" keystroke on to the application
            end

            -- Handle case where char used in keyboard shortcut could be captured
            if next(flags) == nil then
                obj.logger.i("no flags detected")
                obj.logger.i("Word after appending: ", word)
                word = word .. char
            end

            if next(flags) ~= nil then
                return false
            end

            -- if one of these "navigational" keys is pressed
            if
                keyCode == keyMap["return"] or keyCode == keyMap["space"] or keyCode == keyMap["up"] or
                    keyCode == keyMap["down"] or
                    keyCode == keyMap["left"] or
                    keyCode == keyMap["right"]
             then
                word = "" -- clear the buffer
            end

            obj.logger.i("Word to check if hotstring:", word)

            -- finally, if "word" is a hotstring
            local output = obj.keywords[word]
            if type(output) == "function" then -- expand if function
                local _, o = pcall(output)
                if not _ then
                    obj.logger.ef("~~ expansion for '" .. what .. "' gave an error of " .. o)
                -- could also set o to nil here so that the expansion doesn't occur below, but I think
                -- seeing the error as the replacement will be a little more obvious that a print to the
                -- console which I may or may not have open at the time...
                -- maybe show an alert with hs.alert instead?
                end
                output = o
            end

            if output then
                for i = 1, utf8.len(word), 1 do
                    hs.eventtap.keyStroke({}, "delete", 0)
                end -- delete the abbreviation
                hs.eventtap.keyStrokes(output) -- expand the word
                word = "" -- clear the buffer
            end

            return false -- pass the event on to the application
        end
    ):start() -- start the eventtap

    -- return keyWatcher to assign this functionality to the "expander" variable to prevent garbage collection
    return keyWatcher
end

--- HammerText:start()
--- Method
--- Start HammerText
---
--- Parameters:
---  * None
function obj:start()
    print("Heeey! Hammertext is running")
    obj.keyWatcher = obj:expander()
end

function obj:stop()
    if (obj.keyWatcher) then
        obj.keyWatcher:stop()
        obj.logger.i("Stopped HammerText eventtap watcher")
    end
    -- expander()
end

return obj
