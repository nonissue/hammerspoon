local obj = {}
obj.__index = obj

-- Metadata
obj.name = "SafariKeys"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end
obj.spoonPath = script_path()

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
-- cycle_safari_agents
------------------------------------------------------------------------------
-- Taken from: http://www.hammerspoon.org/go/#applescript
-- modified to toggle between iOS and default
-- Useful for sites that insist on flash installations
-- Tricking them into thinking device is mobile is

-- This is pretty brittle (it breaks when safari is updated)
-- and I do it largely to force sites to present
-- HTML5 video when flash is offered by default
--
-- Probably a better way to do it.
------------------------------------------------------------------------------
function cycle_safari_agents()
    hs.application.launchOrFocus("Safari")
    local safari = hs.appfinder.appFromName("Safari")
  
    local str_default = {"Develop", "User Agent", "Default (Automatically Chosen)"}
    local str_iPad = {"Develop", "User Agent", "Safari — iOS 11.0 — iPad"}
  
    local default = safari:findMenuItem(str_default)
    local iPad = safari:findMenuItem(str_iPad)
  
    if (default and default["ticked"]) then
      safari:selectMenuItem(str_iPad)
      
      hs.alert.show("UA: iPad", alerts_standard, 0.7)
    end
    if (iPad and iPad["ticked"]) then
      safari:selectMenuItem(str_default)
      hs.alert.show("UA: Default", alerts_nobg, 2)
    end
  end
  
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, '7', cycle_safari_agents)
  
  ------------------------------------------------------------------------------
  -- mailToSelf
  ------------------------------------------------------------------------------
  -- Gets current url from active safari tab and mails it to specified address
  -- problem is, no alert when DND is on. hmmm.
  ------------------------------------------------------------------------------
  function mailToSelf()
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
      
    -- hs.notify.new({title="Page Emailed", informativeText="URL:\n" .. result}):send()
    -- hs.alert.show("📩", {fillColor = { white = 0, alpha = 0 }, strokeWidth = 0})
    hs.alert.show(" ↧ ", alerts_nobg, 1.2)
  end
  end
  
  -- mails current url to myself using mailtoself function
  hs.hotkey.bind(mash, 'U', mailToSelf)
  
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
  function tabToNewWindow()
    hs.application.launchOrFocus("Safari")
    local safari = hs.appfinder.appFromName("Safari")
  
    local target_item_in_menu = {"Window", "Move Tab to New Window"}
    safari:selectMenuItem(target_item_in_menu)
  
    hs.alert.show(" ⎘ ", alerts_nobg, 1.5)
  end
  
  hs.hotkey.bind(mash, 'T', tabToNewWindow)
  
  ------------------------------------------------------------------------------
  -- mergeAllWindows
  ------------------------------------------------------------------------------
  -- Merges all separate windows into one window
  ------------------------------------------------------------------------------
  function mergeAllWindows()
    hs.application.launchOrFocus("Safari")
    local safari = hs.appfinder.appFromName("Safari")
  
    local target_item_in_menu = {"Window", "Merge All Windows"}
    safari:selectMenuItem(target_item_in_menu)
    hs.alert.show(" ⎗ ", alerts_nobg, 1.5)
  end
  
  hs.hotkey.bind(mash, 'M', mergeAllWindows)
  
  ------------------------------------------------------------------------------
  -- pinOrUnpinTab
  ------------------------------------------------------------------------------
  -- Pins or unpins current tab
  ------------------------------------------------------------------------------
  function pinOrUnpinTab()
    hs.application.launchOrFocus("Safari")
    local safari = hs.appfinder.appFromName("Safari")
  
    local pin_tab = {"Window", "Pin Tab"}
    local unpin_tab = {"Window", "Unpin Tab"}
  
    if (safari:findMenuItem(pin_tab)) then
      -- new pin tab
      hs.alert.show(" ⍇ ", alerts_nobg, 1.5)
      safari:selectMenuItem(pin_tab)
    else
      hs.alert.show(" ⍈ ", alerts_nobg, 1.5)
      safari:selectMenuItem(unpin_tab)
    end
  end
  
  hs.hotkey.bind(mash, 'P', pinOrUnpinTab)
  
  
  function alert_repeat(text, style, interval, start, stop)
    -- kind of a cool little affect, not sure if i love it 
    -- but i can kind of tile alerts overthemselves
    -- another idea would be to have variable sizes using some random 
    -- gen for alert style table
    hs.alert.closeAll()
    local cur_dur = start
    for i=start,stop,interval do
      cur_dur = cur_dur + interval
      hs.alert.show(text, style, cur_dur)
    end
  end
  -- test1 = hs.alert.show("BR𝛀", alerts_nobg, 1.5)
  -- alert_repeat("BR𝛀", alerts_nobg, 0.2, 1, 3)
  
  function alert_test()
    -- Attemtpign to figure out the padding problem with 
    -- hs.alerts.
    local test_string = " test ⌂ "
    local test_color = {red=255/255,blue=120/255,green=120/255,alpha=1}
    local text_style = hs.styledtext.new(test_string, { font = { size=80 }, color=test_color })
    print_r(text_style)
    local text_style1 = hs.styledtext.new(
      test_string,
        {
          font={size=14},
          color=test_color,
          -- paragraphStyle={alignment="left"}
        }
      )
    
    local test_alert_style = {
      fillColor = { white = 0, alpha = 0.2}, 
      -- radius = 60, 
      strokeColor = { white = 0, alpha = 0.2 }, 
      strokeWidth = 10, 
      -- textSize = 55, 
      -- textColor = { white = 0, alpha = 1}, 
      textStyle = text_style,
    }
  
    hs.alert.show(" ⌂ ", test_alert_style, 3)
  end
  
  ------------------------------------------------------------------------------
  -- End of safari stuff
  ------------------------------------------------------------------------------