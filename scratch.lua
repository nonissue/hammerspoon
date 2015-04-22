-- Not sure if this will work, but would be awesome for
-- desktop setup

SCREEN_NAME_INTERNAL = 'Color LCD'
SCREEN_NAME_EXTERNAL = 'DELL U2713HM'
local internal_original_brightness = 42
function screen_switch_handler(name)

    if name == SCREEN_NAME_INTERNAL then
        hs.alert.show("Internal screen detected!")
        hs.brightness.set(internal_original_brightness)
    elseif name == SCREEN_NAME_EXTERNAL then
        hs.alert.show("External screen detected!")
        internal_original_brightness = hs.brightness.get()
        hs.brightness.set(0)
    end
end