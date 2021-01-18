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
    if files[1] == ".DS_Store" and #files == 1 then
        return
    end

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

    -- print("\n------------------------\n")

    for z = 1, #files do
        local file = files[z]
    end
    -- print("\n------------------------\n")
    -- print("\tFilelist:")
    for y = 1, #files do
        local file = files[y]
        local fileName = file:match("([^/]+)$")
        local skip = 0

        -- print("\t- " .. file)

        if file ~= nil and string.sub(file, -4) == ".png" and string.sub(fileName, 1, 3) == "apw" then
            -- print(file)
            -- print("\n\n\n" .. hs.fs.attributes(file).creation .. "\n\n\n")
            -- print("\n\n\n" .. "we care about this file" .. file .. "\n\n\n")
            skip = 0
        elseif string.sub(fileName, -4) ~= ".png" then
            -- print("we dont care about this file")
            skip = 1
        elseif string.sub(fileName, 1, 3) ~= "apw" then
            -- print("we dont care about this file")
            skip = 1
        end

        if skip == 1 then
            -- print(file)
            -- print(fileName)
            print(
                "\n\n\t\tSkipping:" ..
                    "\n\t\t\tpath:\t\t" ..
                        file .. "\n\t\t\tfileName:\t" .. fileName .. "\n\t\tReason:\n\t\t\tFails criteria\n"
            )
        else
            difference = os.time() - hs.fs.attributes(file).creation

            -- print("\nFiles. " .. i(files) .. "\n")

            -- get just the file name without the path
            local fileName = file:match("([^/]+)$")

            if difference > 100 then
                -- hs.alert("file isnt a new screenshot!")
                -- hs.alert(file)
                -- print("isnt a new file")
                print(
                    "\n\n\t\tSkipping:" ..
                        "\n\t\t\tpath: " ..
                            file .. "\n\t\t\tfileName: " .. fileName .. "\n\t\tReason: Not a new screenshot\n"
                )

                break
            else
                print("Proceeding with file" .. file)
            end

            -- print("FILE: " .. file)
            -- print(os.time(os.date("!*t")))

            local filePath = file

            obj.newScreenshot = hs.image.imageFromPath(filePath)
            obj.currentScreenshot = hs.pasteboard.readImage("clippyboard")

            -- print("\nfilename. " .. fileName .. "\nfilePath. " .. filePath)

            -- if file doesn't start with prefix set in our macos defaults
            -- then we don't care about it. when a screenshot is created,
            -- it seems like a bunch of temporary files with a period prepended
            -- are created and then removed, which breaks our utility.
            -- We also make sure this is a "file creation" event before continuing
            if obj.wasCreated then
                -- hs.pasteboard.readDataForUTI("public.file-url") == filePath and
                if obj.currentScreenshot:size().w == obj.newScreenshot:size().w then
                    hs.alert("if", 5) "\n   ------------------------\n \n ERROR  ------------------------\n \
                        Already in clipboard! Copying to clipboard... \n  ------------------------\n"
                else
                    print(
                        "\n\n\t------------------------\n\tMatch! Copying to clipboard...\n\t------------------------\n"
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

                    obj.wasCreated = false
                    -- Don't need to go through rest of files if we have a match
                    break
                end
            else
                -- Either a file was modified, deleted or created by macos
                print("file watcher called, but file is either temporary, or has been removed")
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
