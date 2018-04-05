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

alerts_large = { 
   fillColor = { white = 0, alpha = 0 }, radius = 50, strokeColor = { white = 0.5, alpha = 0 }, 
   strokeWidth = 50, textSize = 100, textColor = { blue = 1, alpha = 0.8}
}

alerts_large_alt = { 
   fillColor = { white = 0, alpha = 0 }, radius = 50, strokeColor = { white = 0.5, alpha = 0 }, 
   strokeWidth = 50, textSize = 20, textColor = { white = 1, alpha = 0.8}
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

hs_config_dir = os.getenv("HOME") .. "/.hammerspoon/"

function notify(title, message)
  hs.notify.new({title=title, informativeText=message}):send()
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
