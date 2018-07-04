local mod = {}

local supermash = {"cmd", "alt", "ctrl"}
local sounds_dir = os.getenv("HOME") .. "/.hammerspoon/media/sounds/"

local inception = hs.sound.getByFile(sounds_dir .. "inception.mp3")
local airhorn = hs.sound.getByFile(sounds_dir .. "mlg-airhorn.mp3")

-- was too easy to hit as A
-- hs.hotkey.bind(supermash, 'A', function() 
	-- alert_repeat("🚨📢", alerts_nobg, 0.5, 1, 3)
	-- alert_lrg(" 🚨 📢 ")
	-- airhorn:play() 
-- end)

return mod