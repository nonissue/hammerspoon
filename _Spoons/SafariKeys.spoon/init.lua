--- === SafariKeys ===
---
-- SafariKeys

local obj = {}
obj.__index = obj

-- Don't run some of these if safari isn't frontmost application
-- could write a factory function to wrap module method passed to hs.fnutils
-- to that function

-- Metadata
obj.name = "SafariKeys"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.logger = hs.logger.new("SafariKeys")

local mash = {"cmd", "alt", "ctrl"}
local hyper = {"cmd", "alt"}

obj.defaultHotkeys = {
    tabToNewWin = {mash, "T"},
    mailToSelf = {mash, "U"},
    mergeAllWindows = {mash, "M"},
    pinOrUnpinTab = {hyper, "P"},
    cycleUserAgent = {mash, "7"},
    addToReadingList = {mash, "R"}
}

function obj:bindHotkeys(mapping)
    local def = {
        tabToNewWin = hs.fnutils.partial(self.tabToNewWindow, self),
        mailToSelf = hs.fnutils.partial(self.mailToSelf, self),
        mergeAllWindows = hs.fnutils.partial(self.mergeAllWindows, self),
        pinOrUnpinTab = hs.fnutils.partial(self.pinOrUnpinTab, self),
        cycleUserAgent = hs.fnutils.partial(self.cycleUserAgent, self),
        addToReadingList = hs.fnutils.partial(self.addToReadingList, self)
    }

    hs.spoons.bindHotkeysToSpec(def, mapping)
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- SAFARI STUFF STARTS
------------------------------------------------------------------------------
-- cycleUserAgent
------------------------------------------------------------------------------
-- Taken from: http://www.hammerspoon.org/go/#applescript
-- modified to toggle between iOS and default
-- Useful for sites that insist on flash installations
-- Tricking them into thinking device is mobile is

-- This is pretty brittle (it breaks when safari is updated)
-- and I do it largely to force sites to present
-- HTML5 video when flash is offered by default
--
-- Probably a better way tn o do it.
------------------------------------------------------------------------------
function obj:cycleUserAgent()
    hs.application.launchOrFocus("Safari")
    local safari = hs.appfinder.appFromName("Safari")

    local str_default = {"Develop", "User Agent", "Default (Automatically Chosen)"}
    local str_iPad = {"Develop", "User Agent", "Safari — iOS 12.1.3 — iPad"}

    local default = safari:findMenuItem(str_default)
    local iPad = safari:findMenuItem(str_iPad)

    if (default and default["ticked"]) then
        safari:selectMenuItem(str_iPad)
        hs.alert.show("UA: iPad", 1.5)
    end
    if (iPad and iPad["ticked"]) then
        safari:selectMenuItem(str_default)
        hs.alert.show("UA: Default", 2)
    end
end

------------------------------------------------------------------------------
-- mailToSelf
------------------------------------------------------------------------------
-- Gets current url from active safari tab and mails it to specified address
-- problem is, no alert when DND is on. hmmm.
function obj.addToReadingList()
    local ok, result =
        hs.osascript.applescript(
        [[
        tell application "Safari"
	        set result to URL of document 1
        end tell
        tell application "Safari" to add reading list item result
    ]]
    )

    if (ok) then
        hs.alert.show(" ⚯⁺")
        obj.logger.i("Added item to reading list")
    else
        obj.logger.e("Error adding item to reading list")
        obj.logger.e(result)
    end
end

-- Attempt to accept URl if passed, and if no URL is passed
-- Grabs the URL of the frontmost safari tab
-- Not working as I can't get string interpolation working with
-- hs.osascript
function obj:addToReadingListTest(url)
    local ok, result

    if (not url) then
        local _, _ =
            hs.osascript.applescript(
            [[
            tell application "Safari"
                set result to URL of document 1
            end tell
            tell application "Safari" to add reading list item result
        ]]
        )
    else
        obj.logger.e("URL: " .. url)
        local script = string.format([[tell application "Safari" to add reading list item %s]], url)
        obj.logger.e(script)

        ok, result = hs.osascript.applescript(script)

        if (not ok) then
            obj.logger.e("error saving passed url")
            obj.logger.e(result)
        end
    end

    if (ok) then
        hs.alert.show(" ⚯⁺")
        obj.logger.i("Added item to reading list")
    else
        obj.logger.e("Error adding item to reading list")
    end
end

function obj.mailToSelf()
    local firefox = hs.application.get("Firefox")
    local frontApp = hs.application.frontmostApplication()

    -- this shit is too unreliable
    if frontApp == firefox then
        hs.alert("Can't currently save url from firefox")
        return
    end

    -- local ok, firefoxsaveres = hs.osascript.applescript([[
    --     use scripting additions
    --     use framework "Foundation"
    --     tell application "System Events" to tell process "firefox"
    --         set frontmost to true
    --         set the_title to name of windows's item 1
    --         set the_title to (do shell script "echo " & quoted form of the_title & " | tr '[' ' '")
    --         set the_title to (do shell script "echo " & quoted form of the_title & " | tr ']' ' '")
    --     end tell
    --     tell application "System Events"
    --         keystroke "l" using command down
    --         delay 1
    --         keystroke "c" using command down
    --     end tell
    --     set the_url to the clipboard
    --     tell application "Mail"
    --         set theMessage to make new outgoing message with properties ¬
    --             {subject:"MTS: " & the_title, content:the_url, visible:true}
    --         tell theMessage
    --             make new to recipient with properties {name:"Mail to Self", address:"hammerspoon@nonissue.org"}
    --             send
    --         end tell
    --     end tell
    -- ]])

    -- return the_title & ": " & the the_url as text

    -- if not ok then
    --     hs.logger.e("error saving url from firefox")
    --     return
    -- end

    -- if frontApp == firefox then
    --     -- hs.alert("Frontmost app is firefox")
    --     if result and ok then
    --         hs.alert("frontmost url = result: " .. result)
    --         hs.alert("URL:" .. result)
    --     end
    --     return
    -- end

    local script =
        [[
            tell application "Safari"
                set currentURL to URL of document 1
            end tell
            return currentURL
        ]]

    -- hs.alert("current url is" .. hs.applescript(script))
    local ok, _ = hs.applescript(script)
    if (ok) then
        hs.applescript.applescript(
            [[
            tell application "Safari"
                set theURL to URL of document 1
                set theSource to source of front document
                set AppleScript's text item delimiters to "title>"
                set theSource to second text item of theSource
                set AppleScript's text item delimiters to "</"
                set theTitle to first text item of theSource
            end tell

            tell application "Mail"
                set theMessage to make new outgoing message with properties ¬
                    {subject: "MTS: " & theTitle, content: theURL, visible:true}
                tell theMessage
                    make new to recipient with properties {name:"Mail to Self", address:"hammerspoon@nonissue.org"}
                    send
                end tell
            end tell
        ]]
        )

        hs.alert.show(" ↧ ", 2)
    end
end

------------------------------------------------------------------------------
-- siteSpecificSearch
------------------------------------------------------------------------------
-- take current root of url (eg. if url is www.example.com/directory),
-- the root is example.com. Then prompt user for keyword(s), and do a
-- google site-specific search on that domain.
-- eg: (google: query site:example.com)
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- tabToNewWindow
------------------------------------------------------------------------------
-- makes new window from current tab in safari
-- could maybe send it to next monitor immediately if there is one?
------------------------------------------------------------------------------
function obj:tabToNewWindow()
    hs.application.launchOrFocus("Safari")
    local safari = hs.appfinder.appFromName("Safari")

    local target_item_in_menu = {"Window", "Move Tab to New Window"}
    safari:selectMenuItem(target_item_in_menu)

    hs.alert.show(" ⎘ ", 1.5)
end

------------------------------------------------------------------------------
-- mergeAllWindows
------------------------------------------------------------------------------
-- Merges all separate windows into one window
------------------------------------------------------------------------------
function obj:mergeAllWindows()
    hs.application.launchOrFocus("Safari")
    local safari = hs.appfinder.appFromName("Safari")

    local target_item_in_menu = {"Window", "Merge All Windows"}
    safari:selectMenuItem(target_item_in_menu)
    hs.alert.show(" ⎗ ", 1.5)
end

------------------------------------------------------------------------------
-- pinOrUnpinTab
------------------------------------------------------------------------------
-- Pins or unpins current tab
------------------------------------------------------------------------------
function obj:pinOrUnpinTab()
    local frontApp = hs.application.frontmostApplication():name()

    if frontApp ~= "Safari" then
        return
    end

    hs.application.launchOrFocus("Safari")
    local safari = hs.appfinder.appFromName("Safari")

    local pin_tab = {"Window", "Pin Tab"}
    local unpin_tab = {"Window", "Unpin Tab"}

    if (safari:findMenuItem(pin_tab)) then
        -- new pin tab
        hs.alert.show(" ⍇ ", 1.5)
        safari:selectMenuItem(pin_tab)
    else
        hs.alert.show(" ⍈ ", 1.5)
        safari:selectMenuItem(unpin_tab)
    end
end

--- SafariKeys:start()
--- Method
--- Starts SafariKeys
---
--- Parameters:
---  * None
---
--- Returns:
---  * The SafariKeys object
function obj:start()
    obj.logger.df("-- Starting SafariKeys")
    if self.hotkeyShow then
        self.hotkeyShow:enable()
    end

    return self
end

--- SafariKeys:stop()
--- Method
--- Stops SafariKeys
---
--- Parameters:
---  * None
---
--- Returns:
---  * The SafariKeys object
---
--- Notes:
---  * Some SafariKeys plugins will continue performing background work even after this call (e.g. Spotlight searches)
function obj:stop()
    obj.logger.df("-- Stopping SafariKeys")
    self.chooser:hide()
    if self.hotkeyShow then
        self.hotkeyShow:disable()
    end
    return self
end

return obj
------------------------------------------------------------------------------
-- End of safari stuff
------------------------------------------------------------------------------
