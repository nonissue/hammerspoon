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

obj.newScreenshot = nil
obj.currentScreenshot = nil
obj.stop = 0
obj.skip = 0
-- for an explanation of this variable, see first if block in obj.imageToClipboard
obj.lastRuntime = 0
-- https://github.com/CommandPost/CommandPost/blob/develop/src/plugins/finalcutpro/text2speech/init.lua
-- https://github.com/heptal/dotfiles/blob/9f1277e162a9416b5f8b4094e87e7cd1fc374b18/roles/hammerspoon/files/pasteboard.lua
-- https://github.com/search?q=hs.pasteboard+extension%3Alua&type=Code
-- https://github.com/ahonn/dotfiles/blob/c5e2f2845924daf970dce48aecbae48e325069a9/hammerspoon/modules/clipboard.lua

--- Clippy.imageToClipboard(files, flagtables)
--- Method
--- Search repositories for a pattern
---
--- Parameters:
---  * files - files passed along from our filewatcher
---  * flags - file flags passed as context from our filewatcher
---
--- Returns:
---  * Nothing
function obj.imageToClipboard(files, flagTables)
    -- Simple way to debounce things as there several file events within the span of a few seconds
    -- when a screenshot is created, and pathwatcher fires for all of them.
    -- To prevent this, when we have successfully copied a screenshot to the pasteboard,
    -- we set obj.lastRuntime, which is compared to the current time on each invocation.
    -- if less than a second has passed since the last run, we return to avoid redundant invocations
    if os.time() - obj.lastRuntime < 2 then
        print("DEBUG: Clippy pathwatcher debounced")
        return
    end

    -- We definitely don't care if it's a .DS_Store file, lawl
    if files[1] == ".DS_Store" and #files == 1 then
        return
    end

    -- NOTE: not sure if this check is necessary?
    -- if any of the sub tables in our flagtables
    -- have itemCreated = true, then we know a new file was created.
    -- If it isn't passed as a flag for any events, then we don't care
    -- (pathwatcher fires when files are opened/deleted)
    for x = 1, #flagTables do
        if flagTables[x]["itemCreated"] then
            obj.wasCreated = true
        end
    end

    obj.wasCreated = true

    for y = 1, #files do
        local file = files[y]
        local fileName = file:match("([^/]+)$")

        -- hacky way to skip iterations of the for loop
        if
            file ~= nil and string.sub(file, -4) == ".png" and string.sub(fileName, 1, 3) == "apw" and
                flagTables[y]["itemIsDir"] ~= true
         then
            obj.skip = 0
        elseif string.sub(fileName, -4) ~= ".png" then
            obj.skip = 1
        elseif string.sub(fileName, 1, 3) ~= "apw" then
            obj.skip = 1
        end

        -- more skip loop
        if obj.skip == 1 then
            if obj.debug == true then
                print(
                    "\n\n\t\tSkipping:" ..
                        "\n\t\t\tpath:\t\t" ..
                            file .. "\n\t\t\tfileName:\t" .. fileName .. "\n\t\tReason:\n\t\t\tFails criteria\n"
                )
            end
        else
            difference = os.time() - hs.fs.attributes(file).creation
            local fileName = file:match("([^/]+)$")

            if difference > 100 then
                if obj.debug == true then
                    print(
                        "\n\n\t\tSkipping:" ..
                            "\n\t\t\tpath: " ..
                                file .. "\n\t\t\tfileName: " .. fileName .. "\n\t\tReason: Not a new screenshot\n"
                    )
                end
            end

            local filePath = file

            -- if file doesn't start with prefix set in our macos defaults
            -- then we don't care about it. when a screenshot is created,
            -- it seems like a bunch of temporary files with a period prepended
            -- are created and then removed, which breaks our utility.
            -- We also make sure this is a "file creation" event before continuing
            obj.newScreenshot = hs.image.imageFromPath(filePath)
            obj.currentScreenshot = hs.pasteboard.readImage("clippyboard")
            if obj.currentScreenshot ~= nil and obj.currentScreenshot:size().w == obj.newScreenshot:size().w then
                print("\n\n\t------------------------\n\nERROR! Already in clipboard!\n\t------------------------\n")
                obj.skip = 1
                return
            end

            if obj.skip == 1 then
                print("we should be skipping now...")
                break
            else
                if obj.wasCreated then
                    print(
                        "\n\n\t------------------------\n\t💯 Match! Copying:\n" ..
                            "\t• " .. fileName .. "\n\tto clipboard.\n\t------------------------\n"
                    )
                    hs.pasteboard.writeObjects(obj.newScreenshot)
                    hs.notify.new(
                        {
                            title = "Screenshot!",
                            subtitle = "New screenshot detected",
                            informativeText = "Screenshot copied to clipboard",
                            alwaysPresent = true,
                            autoWithdraw = true
                        }
                    ):send()

                    obj.lastRuntime = os.time()
                    obj.wasCreated = false
                    obj.skip = 1
                    -- Don't need to go through rest of files if we have a match

                    -- Either a file was modified, deleted or created by macos
                    -- print("file watcher called, but file is either temporary, or has been removed")
                    break
                end
            end
        end
    end

    obj.wasCreated = false
end

--- Clippy:init()
--- Method
--- Initialize our Clippy spoon
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:init()
    obj.screenshotWatcher = hs.pathwatcher.new(obj.screenshotPath, obj.imageToClipboard)
end

--- Clippy:start()
--- Method
--- Starts clippy
---
--- Parameters:
---  * options - An optional table containing spoon configuration options
---
--- Returns:
---  * None
function obj:start() -- luacheck: ignore
    obj.logger.df("-- Starting Clippy")
    obj.screenshotWatcher:start()
end
--- Clippy:stop()
--- Method
--- Stops clippy
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:stop()
    obj.logger.df("-- Stopping Clippy")
    obj.screenshotWatcher:stop()
    obj.wasCreated = false
end

--- Clippy.disable()
--- Function
--- disables clippy
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj.disable()
    obj.screenshotWatcher:stop()
    obj.screenshotWatcher = nil
end

return obj
