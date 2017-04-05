-- Kellan.lua aka media controls


local newmash =    {"cmd", "alt", "ctrl", "shift"}

hs.hotkey.bind(newmash, "right", hs.itunes.next())
hs.hotkey.bind(newmash, "left", hs.itunes.previous())
