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
obj.debug = true
obj.hotkeyShow = nil
obj.screenshotPath = os.getenv("HOME") .. "/Documents/screenshots/2021mbp"
obj.filenamePrefix = "apw"
obj.copyDelay = 0.5
obj.maxCopyAttempts = 5
obj.recentScreenshotWindow = 15
obj.pendingScreenshots = {}
obj.processedScreenshots = {}
-- https://github.com/CommandPost/CommandPost/blob/develop/src/plugins/finalcutpro/text2speech/init.lua
-- https://github.com/heptal/dotfiles/blob/9f1277e162a9416b5f8b4094e87e7cd1fc374b18/roles/hammerspoon/files/pasteboard.lua
-- https://github.com/search?q=hs.pasteboard+extension%3Alua&type=Code
-- https://github.com/ahonn/dotfiles/blob/c5e2f2845924daf970dce48aecbae48e325069a9/hammerspoon/modules/clipboard.lua

local function debugLog(message)
    if obj.debug then
        print("Clippy: " .. message)
    end
end

local function fileNameFromPath(path)
    if type(path) ~= "string" then
        return nil
    end

    return path:match("([^/]+)$")
end

function obj.pruneProcessedScreenshots()
    local cutoff = os.time() - 86400

    for filePath, processedAt in pairs(obj.processedScreenshots) do
        if processedAt < cutoff then
            obj.processedScreenshots[filePath] = nil
        end
    end
end

function obj.isCandidateScreenshot(filePath, flagTable)
    local fileName = fileNameFromPath(filePath)

    if fileName == nil or fileName == ".DS_Store" then
        return false, "Ignored file"
    end

    if type(flagTable) == "table" and flagTable.itemIsDir then
        return false, "Directory event"
    end

    if fileName:sub(1, 1) == "." then
        return false, "Temporary file"
    end

    if fileName:sub(-4):lower() ~= ".png" then
        return false, "Not a PNG"
    end

    if obj.filenamePrefix ~= nil and fileName:sub(1, #obj.filenamePrefix) ~= obj.filenamePrefix then
        return false, "Prefix mismatch"
    end

    if type(flagTable) ~= "table" then
        return false, "Missing event flags"
    end

    if not (flagTable.itemCreated or flagTable.itemModified or flagTable.itemRenamed) then
        return false, "No creation-like flag"
    end

    return true
end

function obj.notifyScreenshotCopied(filePath)
    local fileName = fileNameFromPath(filePath) or filePath

    hs.notify.new(
        function ()
            hs.execute(string.format("open %q", obj.screenshotPath))
        end,
        {
            title = "Clippy",
            subTitle = "New screenshot detected",
            informativeText = fileName .. " copied to clipboard",
            hasActionButton = true,
            actionButtonTitle = "Open in Finder",
            alwaysPresent = true,
            autoWithdraw = false,
            withdrawAfter = 0
        }
    ):send()
end

function obj.scheduleScreenshotCopy(filePath, attempt)
    if obj.processedScreenshots[filePath] ~= nil or obj.pendingScreenshots[filePath] ~= nil then
        return
    end

    obj.pendingScreenshots[filePath] = hs.timer.doAfter(obj.copyDelay, function ()
        obj.pendingScreenshots[filePath] = nil
        obj.processScreenshot(filePath, attempt or 1)
    end)
end

function obj.retryScreenshotCopy(filePath, attempt, reason)
    if attempt >= obj.maxCopyAttempts then
        debugLog("Giving up on " .. filePath .. ": " .. reason)
        return
    end

    debugLog(
        "Retrying " ..
        filePath ..
        " (" ..
        tostring(attempt + 1) ..
        "/" ..
        tostring(obj.maxCopyAttempts) ..
        "): " ..
        reason
    )
    obj.scheduleScreenshotCopy(filePath, attempt + 1)
end

function obj.processScreenshot(filePath, attempt)
    if obj.processedScreenshots[filePath] ~= nil then
        return
    end

    local attributes = hs.fs.attributes(filePath)
    if attributes == nil or attributes.mode ~= "file" then
        obj.retryScreenshotCopy(filePath, attempt, "File not ready")
        return
    end

    local createdAt = attributes.creation or attributes.modification or attributes.change
    if createdAt ~= nil and os.time() - createdAt > obj.recentScreenshotWindow then
        debugLog("Ignoring stale event for " .. filePath)
        return
    end

    if attributes.size == nil or attributes.size == 0 then
        obj.retryScreenshotCopy(filePath, attempt, "File is empty")
        return
    end

    local screenshot = hs.image.imageFromPath(filePath)
    if screenshot == nil then
        obj.retryScreenshotCopy(filePath, attempt, "Image could not be loaded yet")
        return
    end

    hs.pasteboard.writeObjects(screenshot)
    obj.processedScreenshots[filePath] = os.time()
    obj.pruneProcessedScreenshots()

    debugLog("Copied screenshot to clipboard: " .. filePath)
    obj.notifyScreenshotCopied(filePath)
end

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
    for index, filePath in ipairs(files) do
        local flagTable = flagTables[index] or {}
        local shouldProcess, reason = obj.isCandidateScreenshot(filePath, flagTable)

        if shouldProcess then
            obj.scheduleScreenshotCopy(filePath, 1)
        else
            debugLog("Ignoring " .. tostring(filePath) .. ": " .. reason)
        end
    end
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

    for _, timer in pairs(obj.pendingScreenshots) do
        timer:stop()
    end

    obj.pendingScreenshots = {}
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
    if obj.screenshotWatcher ~= nil then
        obj.screenshotWatcher:stop()
        obj.screenshotWatcher = nil
    end

    for _, timer in pairs(obj.pendingScreenshots) do
        timer:stop()
    end

    obj.pendingScreenshots = {}
    obj.processedScreenshots = {}
end

return obj
