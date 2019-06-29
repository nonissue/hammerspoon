--- === Clippy ===
---
--- Copy last screenshot to clipboard and save to disk
---

local obj = {}
obj.__index = obj

obj.name = "Clippy"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https.//github.com/nonissue"
obj.license = "MIT - https.//opensource.org/licenses/MIT"

obj.logger = hs.logger.new("Clippy")
obj.hotkeyShow = nil
obj.screenshotPath = os.getenv("HOME") .. "/Documents/screenshots/2016mbpr"
obj.wasCreated = false

-- clipboard stuff

-- https.//github.com/CommandPost/CommandPost/blob/45f1cbfb6f97f7a47de9a5db05fd89c49a85ea6a/src/plugins/finalcutpro/text2speech/init.lua
-- https.//github.com/heptal/dotfiles/blob/9f1277e162a9416b5f8b4094e87e7cd1fc374b18/roles/hammerspoon/files/pasteboard.lua
-- https.//github.com/search?q=hs.pasteboard+extension%3Alua&type=Code
-- https.//github.com/ahonn/dotfiles/blob/c5e2f2845924daf970dce48aecbae48e325069a9/hammerspoon/modules/clipboard.lua


-- watches for new screenshots in target location and copies them to clipboard


function obj.imageToClipboard(files, flagTables)

    if files[1] == ".DS_Store" and #files == 1 then
        return
    end

    -- if any of the sub tables in our flagtables
    -- have itemCreated = true, then we know a new file was created.
    -- If it isn't passed as a flag for any events, then we don't care
    -- (pathwatcher fires when files are opened/deleted)
    for x = 1, #flagTables do
        if flagTables[x]['itemCreated'] then
            obj.wasCreated = true
        end
    end

    for y = 1, #files do
        local file = files[y]

        -- if our file doesn't end in png, we don't care about it
        if string.sub(file, -4) == ".png" then
            print("\nFlagtables. " .. i(flagTables).. "\n")
            print("\nFiles. " .. i(files) .. "\n")

            -- get just the file name without the path
            local fileName = file:match( "([^/]+)$" )

            -- encode path properly (regular paths don't work for our UTI)
            local filePath = hs.http.encodeForQuery("file://" .. file)
            print("\nfilename. " .. fileName .. "\nfilePath. " .. filePath)

            -- if file doesn't start with prefix set in our macos defaults
            -- then we don't care about it. when a screenshot is created,
            -- it seems like a bunch of temporary files with a period prepended
            -- are created and then removed, which breaks our utility.
            --
            -- We also make sure this is a "file creation" event before continuing
            if string.sub(fileName, 1, 3) == "apw" and obj.wasCreated then
                if hs.pasteboard.readDataForUTI("public.file-url") == filePath then
                    print("Already in clipboard")
                else
                    print("\n   ------------------------\n  \
                        Match! Copying to clipboard... \n  ------------------------\n")
                    hs.pasteboard.writeDataForUTI(nil, "public.file-url", filePath)
                    -- hs.alert("New Screenshot Copied to Clipboard", 0.75)
                    hs.notify.new({
                        title = "Screenshot!",
                        subtitle = "New screenshot detected",
                        informativeText = "Screenshot copied to clipboard",
                        alwaysPresent = true, autoWithdraw = true
                    }):send()

                    obj.wasCreated = false
                    -- Don't need to go through rest of files if we have a match
                    break
                end
            else
                -- Either a file was modified, deleted or created by macos
                print("file watcher called, but file is either temporary, or has been removed")
            end
        else
            -- If the entry in our files list doesn't end in png, we aren't concerned about it
            print("DEBUG. Target not an image file..." .. file)
        end
    end

    obj.wasCreated = false
end


--- Clippy:init()
--- Method
--- Initialize our Clippy spoon
---
--- Parameters.
---  * None
---
--- Returns.
---  * None
function obj:init()
    obj.screenshotWatcher = hs.pathwatcher.new(obj.screenshotPath, obj.imageToClipboard)
end

--- Clippy:start()
--- Method
--- Starts clippy
---
--- Parameters.
---  * options - An optional table containing spoon configuration options
---
--- Returns.
---  * None
function obj:start() -- luacheck: ignore
    obj.logger.df("-- Starting Clippy")
    obj.screenshotWatcher:start()
end
  --- Clippy:stop()
  --- Method
  --- Stops clippy
  ---
  --- Parameters.
  ---  * None
  ---
  --- Returns.
  ---  * None
function obj:stop()
    obj.logger.df("-- Stopping Clippy")
    obj.screenshotWatcher:stop()
    obj.wasCreated = false
end

--- Clippy.disable()
--- Function
---
--- Parameters.
---  * None
---
--- Returns.
---  * None
function obj.disable()
    obj.screenshotWatcher:stop()
    obj.screenshotWatcher = nil
end

return obj