-- Generic functions and defaults
-- Largely taken from: https://github.com/zzamboni/oh-my-hammerspoon/blob/master/omh-lib.lua

apw = {}

hostname = hs.host.localizedName()
logger = hs.logger.new('apw-hs')

-- alert styles
alerts_standard = { 
   fillColor = { white = 0.2, alpha = 0.2 }, 
   radius = 40, 
   strokeColor = { white = 0, alpha = 0.1}, 
   strokeWidth = 10, 
   textSize = 50, 
   textColor = { white = 1, alpha = 1}
}

-- The following seems to have become my favourite but it's naming is ridiculous as it has a bg
-- wtf.
alerts_nobg = { 
   fillColor = { white = 0, alpha = 1 }, radius = 20, 
   strokeColor = { white = 1, alpha = 0.1}, strokeWidth = 10, textSize = 40, 
   textColor = { white = 1, alpha = 1}
}

alerts_nobg_sml = { 
   fillColor = { white = 0, alpha = 1 }, radius = 20, strokeColor = { white = 1, alpha = 0.1}, 
   strokeWidth = 10, textSize = 28, textColor = { white = 1, alpha = 1}
}

notificationFont = {
   font = {name = "National 2", size = 40},
   underlineColor = {blue = 1, alpha = 0.5},

   -- backgroundColor = {white = 1, alpha = 0.2},
   -- strokeWidth = -5,
   strokeColor = {black = 1, alpha = 0.2},
   -- kerning = -2,
   underlineStyle = 1,
   -- lineStyles = double,
   -- lineStyles = { lineStyles.single | linePatterns.dash | lineAppliesToWord },   -- linePatterns = dot,
   lineAppliesTo = word,
   -- baselineOffset = 0.5,
   -- shadow = 1,
   -- fontTraits = Poster,

   color = {blue = 1, alpha = 1}
}

alertFont = {
   font = {name = "New Grotesk Square seven", size = 50},
   underlineColor = {blue = 1, alpha = 0.5},

   -- backgroundColor = {white = 1, alpha = 0.2},
   -- strokeWidth = -5,
   strokeColor = {black = 1, alpha = 0.2},
   paragraphStyle = { },
   -- kerning = -2,
   underlineStyle = 1,
   -- lineStyles = double,
   -- lineStyles = { lineStyles.single | linePatterns.dash | lineAppliesToWord },   -- linePatterns = dot,
   lineAppliesTo = word,
   -- baselineOffset = 0.5,
   -- shadow = 1,
   -- fontTraits = Poster,

   color = {blue = 1, alpha = 1}
}

alertFont = hs.styledtext.new(notificationFont)

alerts_large = { 
   fillColor = { white = 0, alpha = 0.2 }, radius = 100, strokeColor = { white = 1, alpha = 1 }, 
   strokeWidth = 50, textSize = 100, textColor = { black = 1, alpha = 0.8}
}

alerts_large_alt = {
   atScreenEdge = 0,
   fillColor = { white = 1, alpha = 0.8 }, 
   radius = 10, 
   strokeColor = { blue = 1, alpha = 0.2 }, 
   strokeWidth = 5, 
   -- textSize = 125, textColor = { blue = 1, alpha = 1},
   textStyle = notificationFont
}

alerts_medium = { 
   fillColor = { white = 0, alpha = 0.2}, radius = 60, 
   strokeColor = { white = 0, alpha = 0.2 }, strokeWidth = 10, 
   textSize = 55, textColor = { white = 0, alpha = 1}
}

test_style = {
   fillColor = { white = 0, alpha = 0.2}, 
   radius = 60, 
   strokeColor = { white = 0, alpha = 0.2 }, 
   strokeWidth = 10, 
   textSize = 55, 
   textColor = { white = 0, alpha = 1}, 
   textStyle = {},
}

function alerts_display()
  -- hs.alert("test_style", test_style, 99)
  -- hs.alert("alerts_nobg_sml", alerts_nobg_sml, 99)
  -- hs.alert("alerts_large", alerts_large, 4)
  hs.alert("Important Alert!", alerts_large_alt, 5)
  -- hs.alert("Important Two!", alerts_large_alt, 5)
  -- hs.alert("alerts_large_alt", alerts_large_alt, 99)
  -- hs.alert("alerts_medium", alerts_medium, 99)
end

-- alerts_display()
-- alerts_display()

-- testCallbackFn = function(result) print("Callback Result: " .. result) end 
-- hs.dialog.alert(100, 100, testCallbackFn, "Message", "Informative Text", "Button One", "Button Two", "NSCriticalAlertStyle") hs.dialog.alert(200, 200, testCallbackFn, "Message", "Informative Text", "Single Button")
-- hs.dialog.blockAlert("Message", "Informative Text", "Button One", "Button Two", "NSCriticalAlertStyle")

-- testCallbackFn = function(result) print("Callback Result: " .. result) end testWebviewA = hs.webview.newBrowser(hs.geometry.rect(250, 250, 250, 250)):show() testWebviewB = hs.webview.newBrowser(hs.geometry.rect(450, 450, 450, 450)):show() hs.dialog.webviewAlert(testWebviewA, testCallbackFn, "Message", "Informative Text", "Button One", "Button Two", "warning") hs.dialog.webviewAlert(testWebviewB, testCallbackFn, "Message", "Informative Text", "Single Button")

hs_config_dir = os.getenv("HOME") .. "/.hammerspoon/"

function notify(title, message)
  -- hs.notify.new({title=title, informativeText=message, hasActionButton=false}):send()
end

function alert(message)
   hs.alert.show(message, alerts_nobg, 1.5)
end



function chooseContrastingColor(c)
   local L = 0.2126*(c.red*c.red) + 0.7152*(c.green*c.green) + 0.0722*(c.blue*c.blue)
   local black = { ["red"]=0.000,["green"]=0.000,["blue"]=0.000,["alpha"]=1 }
   local white = { ["red"]=1.000,["green"]=1.000,["blue"]=1.000,["alpha"]=1 }
   if L>0.5 then
      return black
   else
      return white
   end
end

function apw.capture(cmd, raw)
   local tmpfile = os.tmpname()
   os.execute(cmd .. ">" .. tmpfile)
   local f=io.open(tmpfile)
   local s=f:read("*a")
   f:close()
   os.remove(tmpfile)
   if raw then return s end
   s = string.gsub(s, '^%s+', '')
   s = string.gsub(s, '%s+$', '')
   s = string.gsub(s, '[\n\r]+', ' ')
   return s
end

function apw.bind(keyspec, fun)
  hs.hotkey.bind(keyspec[1], keyspec[2], fun)
end

function sortedkeys(tab)
   local keys={}
   -- Create sorted list of keys
   for k,v in pairs(tab) do table.insert(keys, k) end
   table.sort(keys)
   return keys
end

local clock = os.clock
function apw.sleep(n)  -- seconds
   local t0 = clock()
   while clock() - t0 <= n do end
end

return apw
