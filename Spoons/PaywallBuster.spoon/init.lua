--- TODO:
--- [ ] add bindhoykeys method

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

-- check if safari is in foreground
-- hs.application.launchOrFocus("Safari")
-- hs.application.frontmostApplication()
-- if not hs.application.frontmostApplication():name() == "Safari" then
-- end

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

obj.spoonPath = script_path()

-- hotkey binding not working
function obj:bindHotkeys(mapping)
  local def = {
    showPaywallBuster = hs.fnutils.partial(self:show(), self),
   }

   hs.spoons.bindHotkeysToSpec(def, mapping)
end

local chooserTable = {
  {["id"] = 1, ["text"] = "Private Browsing", subText="Opens current url in private browsing mode"},
  {["id"] = 2, ["text"] = "Facebook Outlinking", subText="Passes URL to Facebook handler for outgoing requests", ["baseURL"] = "https://www.facebook.com/flx/warn/?u="},
  {["id"] = 3, ["text"] = "Google as Referrer", subText="Reloads URL with Google as referrer"},
  {["id"] = 4, ["text"] = "WBM / Cache", subText="Attempts to find URL on wayback machine"},
  {["id"] = 5, ["text"] = "Outline.com", subText="sends current url to outline.com"}
}

-- create new private browsing window
privateBrowsing = [[
tell application "Safari"
  activate
	tell application "System Events"
		keystroke "n" using {command down, shift down}
	end tell
	delay 0.1
end tell
]]

getURL = [[
tell application "Safari"
  set currentURL to URL of front document
end tell
return currentURL
]]

setURL = [[
tell application "Safari"
	make new document at end of documents with properties {URL:"http://www.macosxhints.com"}
	tell window 1
		set current tab to (make new tab with properties {URL:"http://www.stackoverflow.com"})
	end tell
end tell
]]

local function focusLastFocused()
  local wf = hs.window.filter
  local lastFocused = wf.defaultCurrentSpace:getWindows(wf.sortByFocusedLast)
  if #lastFocused > 0 then lastFocused[1]:focus() end
end

function obj.createWindow(originalURL, newURL)
  hs.osascript.applescript("tell application \"Safari\" to make new document with properties {URL:" .. '"'..originalURL..'"' .. "}")
  hs.osascript.applescript("tell window 1 of application \"Safari\" to set current tab to (make new tab with properties {URL:" .. '"'..newURL..'"' .. "})")
end

function obj:setURL(newURL)
  hs.osascript.applescript("tell application \"Safari\" to set the URL of the front document to \"" .. newURL .."\"")
end

function obj:getURL()
  local ok, currentURL, err = hs.osascript._osascript(getURL, "AppleScript")
  if (ok) then
    return hs.http.encodeForQuery(currentURL)
  else
    hs.alert("Error Busting Paywall!")
    return nil
  end
end

function obj:concatURL(baseURL)
  local ok, currentURL = hs.osascript._osascript(getURL, "AppleScript")
  if (ok) then
    return baseURL .. hs.http.encodeForQuery(currentURL)
  else 
    hs.alert("Error busting paywall!")
  end
end

function obj:busterChooserCallback(input)
  -- if not inputz then focusLastFocused(); return end
  print_r(input)
  if input['id'] == 1 then
    -- seems to have fixed the binding problem?
    local frontmostURL = obj:getURL()
    hs.osascript.applescript(privateBrowsing)
    obj:setURL(frontmostURL)
  elseif input['id'] == 2 then
    originalURL = self:getURL()
    newURL = self:concatURL(input['baseURL'])
    hs.application.launchOrFocus("Safari")
    self.createWindow(originalURL, newURL)
  elseif input['id'] == 3 then
    hs.osascript.applescript(privateBrowsing)
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
  print("-- Starting PaywallBuster")
  self.chooser = hs.chooser.new(function(choice)
    self:busterChooserCallback(choice)
  end)
  -- self.chooser = hs.chooser.new(self.busterChooserCallback)
  self.chooser:choices(chooserTable)
  self.chooser:rows(#chooserTable)
  -- self.chooser:rows(0)
  self.chooser:width(20)
  self.chooser:bgDark(false)

  return self
end

function obj:show()
  self.chooser:show()
  return self
end

function obj:start()
  print("-- Starting PaywallBuster")
  return self
end

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
---  * Some PaywallBuster plugins will continue performing background work even after this call (e.g. Spotlight searches)
function obj:stop()
  print("-- Stopping PaywallBuster")
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