--- === SafariKeys ===
---
-- SafariKeys

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "SafariKeys"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"

function obj:bindHotkeys(mapping)
  local def = {
    tabToNewWin = hs.fnutils.partial(self.tabToNewWindow, self),
    mailToSelf = hs.fnutils.partial(self.mailToSelf, self),
    mergeAllWindows = hs.fnutils.partial(self.mergeAllWindows, self),
    pinOrUnpinTab = hs.fnutils.partial(self.pinOrUnpinTab, self),
    cycleUserAgent = hs.fnutils.partial(self.cycleUserAgent, self),
   }

   hs.spoons.bindHotkeysToSpec(def, mapping)
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
  print("-- Starting SafariKeys")
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
  print("-- Stopping SafariKeys")
  self.chooser:hide()
  if self.hotkeyShow then
      self.hotkeyShow:disable()
  end
  return self
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
  local str_iPad = {"Develop", "User Agent", "Safari — iOS 11.0 — iPad"}

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
  ------------------------------------------------------------------------------
function obj:mailToSelf()
  script = [[
    tell application "Safari"
      set currentURL to URL of document 1
    end tell
    return currentURL
  ]]

  -- hs.alert("current url is" .. hs.applescript(script))
  ok, result = hs.applescript(script)
  if (ok) then
    hs.applescript.applescript([[
      tell application "Safari"
      set result to URL of document 1
      end tell
      tell application "Mail"
      set theMessage to make new outgoing message with properties {subject: "MTS: " & result, content:result, visible:true}
      tell theMessage
      make new to recipient with properties {name:"Mail to Self", address:"hammerspoon@nonissue.org"}
      send
      end tell
      end tell
    ]])
    
    hs.alert.show(" ↧ ", 2)
  end
end

-- mails current url to myself using mailtoself function

  
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
  
return obj
------------------------------------------------------------------------------
-- End of safari stuff
------------------------------------------------------------------------------