--[[
hidutil property -m 'keyboard' -g 'Product'
hidutil property -m '{"ProductID":632}' --get "Product"

FRemap = require("foundation_remapping")
remapper = FRemap.new()
-- hidutil property -m '{"LocationID": 52510720, "PrimaryUsage": 6}' --get 'Product'
-- remapper = FRemap.new({vendorID = 0x0405, productID = 0x077d})
remapper = FRemap.new({vendorID = 1917, productID = 1029})

-- remapper = FRemap.new({LocationID = 52510720, productID = 0x077d})
-- remapper:remap(0x1e, 0xe0)
-- caps lock is 57 / 0x39, lctrl is 224 / 0xe0

-- damn so this works to remap Home to lctl
-- THIS WORKS CONFIRMED
-- i(remapper:remap("CapsLock", "lctl"))
i(remapper:remap("Home", "lctl"))

-- power button to escape
i(remapper:remap(0x700000066, "lctl"):register())
-- i(remapper:remap(0x700000039, "lctl"):register())
-- i(remapper:remap(0x700000039, 0x700000082):register()) -- caps lock to locking caps lock
-- i(remapper:remap(0x700000039, 0x700000082):register()) -- caps lock to locking caps lock
print(i(remapper:register()))

-- i(remapper:remap(0x70000007f, 'lctl'):register())

-- i(remapper:remap("Home", "lctl"))
-- i(remapper:remap('LockCapsLock', 'lctl'))
print(i(remapper:register()))

-- local FRemap = require("foundation_remapping")
-- remapper:remap("[", "]") -- when press a, type b
-- remapper:unregister()
]]
-- https://github.com/cfenollosa/aekii
-- https://github.com/RehabMan/OS-X-Voodoo-PS2-Controller/issues/103#issuecomment-320736223
-- figure out locking caps lock keycode, then try and rebind it?
-- https://github.com/pqrs-org/Karabiner-Elements/issues/2035
-- Thanks to qaisjp, giving up caps lock entirely do the trick for me. I only used caps lock for IME switching, which can be worked around by a shortcut preference at macOS preference ➤ keyboard ➤ shortcuts ➤ 'Select the previous input source'.
-- If your favorite shortcut is not ordinary, e.g. Left⇧ + Right⇧, do it with an extra step.
-- In Karabiner map your favorite combination to F19
-- Bind 'Select the previous input source' to F19
-- https://apple.stackexchange.com/questions/283252/how-do-i-remap-a-key-in-macos-sierra-e-g-right-alt-to-right-control
-- touchbar = require("hs._asm.undocumented.touchbar")
-- quick and dirty example -- I'll put up a better one shortly
-- note that not all of the methods used here have an effect since we only support modal touch bars atm
