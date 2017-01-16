local mod = {}


-- A global variable for the Hyper Mode
local k = hs.hotkey.modal.new({}, "F17")

-- HYPER+L: Open news.google.com in the default browser
lfun = function()
   -- news = "app = Application.currentApplication(); app.includeStandardAdditions = true; app.doShellScript('open http://news.google.com')"
   -- hs.osascript.javascript(news)
   hs.alert("modal trigged!")
   k.triggered = true
end
k:bind('', 'l', nil, lfun)
--
-- -- HYPER+M: Call a pre-defined trigger in Alfred 3
-- mfun = function()
--   cmd = "tell application \"Alfred 3\" to run trigger \"emoj\" in workflow \"com.sindresorhus.emoj\" with argument \"\""
--   hs.osascript.applescript(cmd)
--   k.triggered = true
-- end
-- k:bind({}, 'm', nil, mfun)
--
-- -- HYPER+E: Act like ⌃e and move to end of line.
-- efun = function()
--   hs.eventtap.keyStroke({'⌃'}, 'e')
--   k.triggered = true
-- end
-- k:bind({}, 'e', nil, efun)
--
-- -- HYPER+A: Act like ⌃a and move to beginning of line.
-- afun = function()
--   hs.eventtap.keyStroke({'⌃'}, 'a')
--   k.triggered = true
-- end
-- k:bind({}, 'a', nil, afun)

-- Enter Hyper Mode when F18 (Hyper/Capslock) is pressed
mod.pressedF12 = function()
   hs.alert("Entering modal")
   k.triggered = false
   k:enter()
end

-- Leave Hyper Mode when F18 (Hyper/Capslock) is pressed,
--   send ESCAPE if no other keys are pressed.
mod.releasedF12 = function()
   hs.alert("Entering modal")
   k:exit()
   if not k.triggered then
      hs.eventtap.keyStroke({}, 'ESCAPE')
   end
end

-- Bind the Hyper key
function mod.init()
   hs.alert("exiting modal")
   f18 = hs.hotkey.bind({}, 'F18', mod.pressedF12, mod.releasedF12)
end

return mod
