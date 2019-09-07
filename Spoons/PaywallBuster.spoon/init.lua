--- === PaywallBuster ===
---
-- PaywallBuster

--[[
    Update:
    THese methods are becoming less and less succeesful.
    Might want to roll my own using google's search indexer IP address
    
    some ideas lifted from here:
    https://github.com/iamadamdev/bypass-paywalls-firefox/

    https://stackoverflow.com/questions/20937287/how-to-intercept-a-web-request
    
    Also, if we allow javascript from apple events, we might be able to injectjs
    in pages using applescript?

    At this point it looks like I should just write a safari app extension
    https://github.com/infernoboy/JavaScript-Blocker-5
    https://developer.apple.com/documentation/safariservices/creating_a_content_blocker
    https://developer.apple.com/documentation/safariservices/safari_app_extensions/injecting_a_script_into_a_webpage
    https://ulyngs.github.io/blog/posts/2018-11-02-how-to-build-safari-app-extensions/
    https://medium.com/snips-ai/how-to-block-third-party-scripts-with-a-few-lines-of-javascript-f0b08b9c4c0
    https://developer.apple.com/documentation/safariservices/safari_app_extensions?changes=_2&language=objc
]]

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "PaywallBuster"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.chooser = nil
obj.hotkeyShow = nil

obj.logger = hs.logger.new("PaywallBuster")

-- hotkey binding not working
function obj:bindHotkeys(mapping)
    local def = {
        showPaywallBuster = hs.fnutils.partial(self:show(), self)
    }

    hs.spoons.bindHotkeysToSpec(def, mapping)
end

-- Private Browsing mode is special / doesnt require baseURL
-- for the other entries, you specify their name, subtext, and then the baseURL of the
-- URL we wish to call
local chooserTable = {
    {["id"] = 1, ["text"] = "Private Browsing", subText = "Opens current url in private browsing mode"},
    {
        ["id"] = 2,
        ["text"] = "Facebook Outlinking",
        subText = "Passes URL to Facebook handler for outgoing requests",
        ["baseURL"] = "https://www.facebook.com/flx/warn/?u="
    },
    {
        ["id"] = 3,
        ["text"] = "Google as Referrer",
        subText = "Reloads URL with Google as referrer",
        ["baseURL"] = "http://webcache.googleusercontent.com/search?q=cache:"
    },
    {
        ["id"] = 4,
        ["text"] = "WBM / Cache",
        subText = "Attempts to find URL on wayback machine",
        ["baseURL"] = "https://web.archive.org/web/"
    },
    {
        ["id"] = 5,
        ["text"] = "Outline.com",
        subText = "sends current url to outline.com",
        ["baseURL"] = "https://outline.com/"
    },
    {
        ["id"] = 6,
        ["text"] = "iOS User Agent",
        subText = "Changes Safari UA string to 'Safari iOS'.",
        ["baseURL"] = ""
    },
    {
        ["id"] = 7,
        ["text"] = "WSJ",
        subText = "Workaround for the WSJ",
        ["baseURL"] = ""
    }
}

-- create new private browsing window
local privateBrowsing =
    [[
    tell application "Safari"
    activate
        tell application "System Events"
            keystroke "n" using {command down, shift down}
        end tell
        delay 0.1
    end tell
]]

local getURL = [[
    tell application "Safari"
    set currentURL to URL of front document
    end tell
    return currentURL
]]

-- local function focusLastFocused()
--     local wf = hs.window.filter
--     local lastFocused = wf.defaultCurrentSpace:getWindows(wf.sortByFocusedLast)
--     if #lastFocused > 0 then
--         lastFocused[1]:focus()
--     end
-- end

function obj.createWindow(originalURL, newURL)
    hs.osascript.applescript(
        'tell application "Safari" to make new document with properties {URL:' .. '"' .. originalURL .. '"' .. "}"
    )
    hs.osascript.applescript(
        'tell window 1 of application "Safari" to set current tab to (make new tab with properties {URL:' ..
            '"' .. newURL .. '"' .. "})"
    )
end

-- User can pass in custom URL rather than safari attempting to process the frontmost tab
-- once user pastes URL in chooser modal, they only have one option, which will call
-- this method :D
function obj.createCustom(URL)
    -- print_r(URL)
    local newURL = "https://outline.com/" .. hs.http.encodeForQuery(URL)
    hs.osascript.applescript(
        'tell window 0 of application "Safari" to set current tab to (make new tab with properties {URL:' ..
            '"' .. newURL .. '"' .. "})"
    )
end

function obj.setURL(newURL)
    hs.osascript.applescript('tell application "Safari" to set the URL of the front document to "' .. newURL .. '"')
end

function obj.getURL()
    local ok, currentURL, err = hs.osascript._osascript(getURL, "AppleScript")
    if (ok) then
        return currentURL
    else
        hs.alert("Error Busting Paywall: " .. err)
        return nil
    end
end

function obj:bust(baseURL)
    local currentURL = obj.getURL()
    if (currentURL) then
        local newURL = baseURL .. hs.http.encodeForQuery(currentURL)
        hs.application.launchOrFocus("Safari")
        self.createWindow(currentURL, newURL)
    else
        hs.alert("Error busting paywall!")
    end
end

function obj:busterChooserCallback(choice)
    -- change this to a lookup table or something
    -- simpler
    -- if not choicez then focusLastFocused(); return end
    if choice["id"] == 1 then
        -- seems to have fixed the binding problem [FIXED?]
        local frontmostURL = obj.getURL()
        hs.osascript.applescript(privateBrowsing)
        obj.setURL(frontmostURL)
    elseif choice["id"] == 2 then
        obj:bust(choice["baseURL"])
    elseif choice["id"] == 3 then
        obj:bust(choice["baseURL"])
    elseif choice["id"] == 4 then
        obj:bust(choice["baseURL"])
    elseif choice["id"] == 5 then
        obj:bust(choice["baseURL"])
    elseif choice["id"] == 6 then
        -- figure out a way to make the obj:bust function more flexible
        -- to handle this
        local frontmostURL = obj.getURL()
        local UAString = {"Develop", "User Agent", "Safari — iOS 12.1.3 — iPhone"}
        hs.appfinder.appFromName("Safari"):selectMenuItem(UAString)
        obj.setURL(frontmostURL)
    elseif choice["id"] == 7 then
        -- figure out a way to make the obj:bust function more flexible
        -- to handle this
        -- also, this method seems to work, but will break if the url already
        -- has ?mod=rsswn at the end
        local frontmostURL = obj.getURL()
        local newURL = hs.http.encodeForQuery(frontmostURL) .. "?mod=rsswn"
        hs.application.launchOrFocus("Safari")
        self.createWindow(frontmostURL, newURL)
    else
        local URL = self.chooser:query()
        obj:createCustom(URL)
    end
end

--- PaywallBuster:start()
--- Method
--- Starts PaywallBuster
---
--- Parameters:
---  * None
---
--- Returns:
---  * The PaywallBuster object
function obj:init()
    obj.logger.df("-- Initializing PaywallBuster")
    self.chooser =
        hs.chooser.new(
        function(choice)
            if not (choice) then
                self.chooser:hide()
                return
                -- print(self.chooser:query())
            else
                --   hs.alert("No choice made?")
                --   return
                self:busterChooserCallback(choice)
            end
        end
    )

    self.chooser:choices(chooserTable)
    self.chooser:rows(#chooserTable)

    self.chooser:queryChangedCallback(
        function(query)
            if query == "" then
                self.chooser:choices(chooserTable)
            else
                local choices = {
                    {["id"] = 0, ["text"] = "Custom", subText = "Enter a custom url to open with default method"}
                }
                self.chooser:choices(choices)
            end
        end
    )

    self.chooser:width(20)
    self.chooser:bgDark(false)

    return self.chooser
end

function obj:show()
    self.chooser:show()
    return self
end

-- function obj:start()
--     obj.logger.df("-- Starting PaywallBuster")
--     self:init()
--     return self
-- end

--- PaywallBuster:stop()
--- Method
--- Stops PaywallBuster
---
--- Parameters:
---  * None
---
--- Returns:
---  * The PaywallBuster object
---
--- Notes:
---  * N/A
-- function obj:stop()
--     obj.logger.df("-- Stopping PaywallBuster")
--     self.chooser:hide()
--     if self.hotkeyShow then
--         self.hotkeyShow:disable()
--     end
--     return self
-- end

return obj
