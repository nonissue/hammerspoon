--- === PaywallBuster ===
---
-- PaywallBuster

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

-- Private Browsing mode is special / doesnt require baseURL
-- for the other entries, you specify their name, subtext, and then the baseURL of the 
-- URL we wish to call
local chooserTable = {
  {["id"] = 1, ["text"] = "Private Browsing", subText="Opens current url in private browsing mode"},
  {["id"] = 2, ["text"] = "Facebook Outlinking", subText="Passes URL to Facebook handler for outgoing requests", ["baseURL"] = "https://www.facebook.com/flx/warn/?u="},
  {["id"] = 3, ["text"] = "Google as Referrer", subText="Reloads URL with Google as referrer", ["baseURL"] = "http://webcache.googleusercontent.com/search?q=cache:"},
  {["id"] = 4, ["text"] = "WBM / Cache", subText="Attempts to find URL on wayback machine", ["baseURL"] = "https://web.archive.org/web/"},
  {["id"] = 5, ["text"] = "Outline.com", subText="sends current url to outline.com", ["baseURL"] = "https://outline.com/"}
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

local function focusLastFocused()
  local wf = hs.window.filter
  local lastFocused = wf.defaultCurrentSpace:getWindows(wf.sortByFocusedLast)
  if #lastFocused > 0 then lastFocused[1]:focus() end
end

function obj.createWindow(originalURL, newURL)
  hs.osascript.applescript("tell application \"Safari\" to make new document with properties {URL:" .. '"'..originalURL..'"' .. "}")
  hs.osascript.applescript("tell window 1 of application \"Safari\" to set current tab to (make new tab with properties {URL:" .. '"'..newURL..'"' .. "})")
end

-- User can pass in custom URL rather than safari attempting to process the frontmost tab
-- once user pastes URL in chooser modal, they only have one option, which will call 
-- this method :D
function obj:createCustom(URL)
  -- print_r(URL)
  local newURL = "https://outline.com/" .. hs.http.encodeForQuery(URL)
  hs.osascript.applescript("tell window 0 of application \"Safari\" to set current tab to (make new tab with properties {URL:" .. '"'..newURL..'"' .. "})")
end

function obj:setURL(newURL)
  hs.osascript.applescript("tell application \"Safari\" to set the URL of the front document to \"" .. newURL .."\"")
end

function obj:getURL()
  local ok, currentURL, err = hs.osascript._osascript(getURL, "AppleScript")
  if (ok) then
    return currentURL--hs.http.encodeForQuery(currentURL)
  else
    hs.alert("Error Busting Paywall!")
    return nil
  end
end

function obj:bust(baseURL)
  local currentURL = obj:getURL()
  if (currentURL) then
    local newURL = baseURL .. hs.http.encodeForQuery(currentURL)
    hs.application.launchOrFocus("Safari")
    self.createWindow(currentURL, newURL)
  else 
    hs.alert("Error busting paywall!")
  end
end

function obj:busterChooserCallback(choice)
  -- if not choicez then focusLastFocused(); return end
  if choice['id'] == 1 then
    -- seems to have fixed the binding problem [FIXED?]
    local frontmostURL = obj:getURL()
    hs.osascript.applescript(privateBrowsing)
    obj:setURL(frontmostURL)
  elseif choice['id'] == 2 then
    obj:bust(choice['baseURL'])
  elseif choice['id'] == 3 then
    obj:bust(choice['baseURL'])
  elseif choice['id'] == 4 then
    obj:bust(choice['baseURL'])
  elseif choice['id'] == 5 then
    obj:bust(choice['baseURL'])
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
  print("-- Starting PaywallBuster")
  self.chooser = hs.chooser.new(
    function(choice)
      if not (choice) then
        print(self.chooser:query())
        self.chooser:hide()
      else
        self:busterChooserCallback(choice)
      
      --   hs.alert("No choice made?")
      --   return

      end
    end
  )
    
  self.chooser:choices(chooserTable)
  self.chooser:rows(#chooserTable)
    
  self.chooser:queryChangedCallback(function(query)
    if query == '' then
      self.chooser:choices(chooserTable)
    else
      local choices = {
        {["id"] = 0, ["text"] = "Custom", subText="Enter a custom url to open with default method"},
      }
      self.chooser:choices(choices)
    end
  end)
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