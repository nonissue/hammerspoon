local mod = {}

local supermash = {"cmd", "alt", "ctrl", "shift"}

-- hs.hotkey.bind(alt, 'space', hs.grid.maximizeWindow)

hs.hotkey.bind(supermash, 'right', hs.itunes.next)
hs.hotkey.bind(supermash, 'left', hs.itunes.previous)

return mod
