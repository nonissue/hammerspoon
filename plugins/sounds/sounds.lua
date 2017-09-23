local mod = {}

local supermash = {"cmd", "alt", "ctrl"}
local sounds_dir = os.getenv("HOME") .. "/.hammerspoon/media/sounds/"

local inception = hs.sound.getByFile(sounds_dir .. "inception.mp3")
local airhorn = hs.sound.getByFile(sounds_dir .. "mlg-airhorn.mp3")

hs.hotkey.bind(supermash, 'A', function() airhorn:play() end)

return mod