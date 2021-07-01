------------------------------------------------------------------------------
--                                NONSENSE                                  --
------------------------------------------------------------------------------

-- random
local emojis = {
    {
        ["text"] = "¯\\_(ツ)_/¯",
        ["subText"] = "Kirby",
        ["uuid"] = "0001"
    },
    {
        ["text"] = "ᕙ(⇀‸↼‶)ᕗ",
        ["subText"] = "yay",
        ["uuid"] = "0002"
    },
    {
        ["text"] = "ლ(ಠ益ಠლ)",
        ["subText"] = "boo",
        ["uuid"] = "0003"
    }
}

local function emojiChooserCallback(choice)
    hs.alert(choice["text"])
    hs.pasteboard.setContents(choice["text"])
    hs.eventtap.keyStrokes(choice["text"])
end

local emojiChooser =
    hs.chooser.new(
    function(choice)
        if not (choice) then
            return
        else
            emojiChooserCallback(choice)
        end
    end
):rows(3):width(20):choices(emojis):searchSubText(true)

hs.hotkey.bind(
    mash,
    "K",
    function()
        emojiChooser:show()
    end
)
