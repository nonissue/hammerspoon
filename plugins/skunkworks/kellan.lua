-- only written as a proof of concept for a friend
-- who wanted this functionality.

local mod = {}

local supermash = {"cmd", "alt", "ctrl"}

hs.hotkey.bind(supermash, 'right', hs.itunes.next)
hs.hotkey.bind(supermash, 'left', hs.itunes.previous)

return mod
