-- Move this to spoon

local obj = {}
obj.__index = obj

obj.name = "TextInflator"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"

function obj.currentDate()
    print(os.date("%y/%m/%d"))
    hs.pasteboard.setContents(choice["text"])
    hs.eventtap.keyStrokes(choice["text"])
end

local mash = {"cmd", "alt", "ctrl"}

local inflates = {
    {
        ["text"] = "site:reddit.com ",
        ["subText"] = "sr site reddit search",
        ["uuid"] = "0001"
    },
    {
        ["text"] = hs.settings.get("context.address"),
        ["subText"] = "address",
        ["uuid"] = "0002"
    },
    {
        ["text"] = os.date("%y-%m-%d"),
        ["subText"] = "current date",
        ["uuid"] = "0004"
    }
}

function obj.chooserCallback(choice)
    hs.alert(choice["text"])
    hs.pasteboard.setContents(choice["text"])
    hs.eventtap.keyStrokes(choice["text"])
end

obj.chooser =
    hs.chooser.new(
    function(choice)
        if not (choice) then
            return
        else
            obj.chooserCallback(choice)
        end
    end
):rows(#inflates):width(20):choices(inflates):searchSubText(true)

function obj:init()
    hs.hotkey.bind(
        mash,
        "J",
        function()
            obj.chooser:show()
        end
    )

    return self
end

return obj
