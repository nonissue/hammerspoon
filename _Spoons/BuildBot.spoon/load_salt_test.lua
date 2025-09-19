-- Test script to load your SALT build order in Hammerspoon
-- Run this in Hammerspoon console: dofile(hs.spoons.resourcePath("load_salt_test.lua"))

local BuildBot = hs.loadSpoon("BuildBot")

-- Read the SALT file
local function readSaltFile()
    local spoonPath = hs.spoons.resourcePath()
    local saltPath = spoonPath .. "/Build Orders/Terran_2-1-1.SALT"

    local file = io.open(saltPath, "r")
    if not file then
        print("❌ Could not open SALT file at: " .. saltPath)
        return nil
    end

    local content = file:read("*a")
    file:close()
    return content:match("^%s*(.-)%s*$") -- trim whitespace
end

print("🧪 Testing SALT Loading...")
print("=" .. string.rep("=", 25))

local saltContent = readSaltFile()
if saltContent then
    print("📄 SALT content: " .. saltContent:sub(1, 50) .. "...")

    -- Try to parse and load it
    BuildBot:loadSALT(saltContent)

    -- Check if build was loaded
    if #BuildBot._build > 0 then
        print("✅ Successfully loaded " .. #BuildBot._build .. " build steps")
        print("\n📋 First 5 steps:")
        for i = 1, math.min(5, #BuildBot._build) do
            local step = BuildBot._build[i]
            print(string.format("  %d. [%02ds] %s %s",
                i, step.time, step.supply or "?", step.action or ""))
        end

        -- Set up hotkeys
        BuildBot:bindHotkeys({
            start = {{"ctrl","alt","cmd"}, "S"},
            pause = {{"ctrl","alt","cmd"}, "P"},
            resume = {{"ctrl","alt","cmd"}, "R"},
            stop = {{"ctrl","alt","cmd"}, "X"},
            toggle = {{"ctrl","alt","cmd"}, "H"},
        })

        print("\n🎮 Hotkeys bound:")
        print("  Ctrl+Alt+Cmd+S: Start build timer")
        print("  Ctrl+Alt+Cmd+P: Pause")
        print("  Ctrl+Alt+Cmd+R: Resume")
        print("  Ctrl+Alt+Cmd+X: Stop")
        print("  Ctrl+Alt+Cmd+H: Toggle overlay")
        print("\n🎯 Ready! Press Ctrl+Alt+Cmd+H to toggle overlay, then S to start!")

    else
        print("❌ No steps were loaded from SALT file")
    end
else
    print("❌ Could not read SALT file")
end