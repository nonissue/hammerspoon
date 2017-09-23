-- sounds.lua

local mod = {}

local sounds_dir = os.getenv("HOME") .. "/.hammerspoon/media/sounds/"
print(sounds_dir)

local inception = hs.sound.getByFile(sounds_dir .. "inception.mp3")
print(inception)

inception:play()

return mod