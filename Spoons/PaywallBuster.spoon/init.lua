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

-- check if safari is in foreground
-- hs.application.launchOrFocus("Safari")
-- hs.application.frontmostApplication()
if not hs.application.frontmostApplication():name() == "Safari" then

end

local chooserTable = {
  {["id"] = 1, ["text"] = "Private Browsing", subText="Opens current url in private browsing mode"},
  {["id"] = 2, ["text"] = "Facebook Outlinking", subText="Passes URL to Facebook handler for outgoing requests", ["baseURL"] = "https://www.facebook.com/flx/warn/?u="},
  {["id"] = 3, ["text"] = "Google as Referrer", subText="Reloads URL with Google as referrer"},
  {["id"] = 4, ["text"] = "WBM / Cache", subText="Attempts to find URL on wayback machine"},
  {["id"] = 5, ["text"] = "Outline.com", subText="sends current url to outline.com"}
}

privateBrowsing = [[
tell application "Safari"
  activate
  tell application "Safari"
    set currentURL to URL of document 1
  end tell
	delay 0.1
	tell application "System Events"
		keystroke "n" using {command down, shift down}
	end tell
	delay 0.1
	tell application "Safari" to set the URL of the front document to currentURL
end tell
]]

getURL = [[
tell application "Safari"
	set currentURL to URL of document 1
end tell
return currentURL
]]

setURL = [[
  tell application "Safari"
	make new document with properties {URL:"http://www.macosxhints.com"}
	tell window 1
		set current tab to (make new tab with properties {URL:"http://www.stackoverflow.com"})
	end tell
end tell
]]

function createWindow(originalURL, newURL)
  hs.osascript.applescript("tell application \"Safari\" to make new document with properties {URL:" .. '"'..originalURL..'"' .. "}")
  -- hs.osascript.applescript("tell application \"Safari\" to make new document with properties {URL: .. originalURL .. }")
  hs.osascript.applescript("tell window 1 of application \"Safari\" to (make new tab with properties {URL:" .. '"'..newURL..'"' .. "})")
end

function setURL(newURL)
  hs.osascript.applescript("tell application \"Safari\" to set the URL of the front document to \"" .. newURL .."\"")
end

function concatURL(baseURL)
  ok, currentURL = hs.osascript._osascript(getURL, "AppleScript")
  if (ok) then
    return baseURL .. hs.http.encodeForQuery(currentURL)
  else 
    hs.alert("Error busting paywall!")
  end
end

function buster(baseUrl)

end

function busterChooserCallback(input)
  print_r(input)
  if input.id == 1 then
    hs.osascript.applescript(privateBrowsing)
  elseif input.id == 2 then
    ok, originalURL = hs.osascript._osascript(getURL, "AppleScript")
    print("\"" .. originalURL .."\"")
    newURL = concatURL(input.baseURL)
    hs.application.launchOrFocus("Safari")
    createWindow(originalURL, newURL)
  elseif input.id == 3 then
    hs.osascript.applescript(privateBrowsing)
  end
end

local chooser = hs.chooser.new(busterChooserCallback)
chooser:choices(chooserTable)
chooser:show()


local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

obj.spoonPath = script_path()

function obj:bindHotkeys(mapping)
  local def = {
    tabToNewWin = hs.fnutils.partial(self.tabToNewWindow, self),
   }

   hs.spoons.bindHotkeysToSpec(def, mapping)
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
function obj:start()
  print("-- Starting PaywallBuster")
  if self.hotkeyShow then
      self.hotkeyShow:enable()
  end
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