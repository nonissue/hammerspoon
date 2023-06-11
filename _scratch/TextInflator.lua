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

local mash = { "cmd", "alt", "ctrl" }

function obj.generateChoices()
    obj.currentChoices = {
        {
            ["text"] = "9935c101ab17a66",
            ["subText"] = "throwaway username",
            ["uuid"] = "0001"
        },
        {
            ["text"] = "site:reddit.com ",
            ["subText"] = "sr site reddit search",
            ["uuid"] = "0002"
        },
        -- issue: text is
        {
            ["text"] = os.date("%y-%m-%d"),
            -- ["text"] = os.date,
            ["subText"] = "current date",
            ["uuid"] = "0003"
        },
        {
            ["text"] = hs.settings.get("context.address"),
            ["subText"] = "address",
            ["uuid"] = "0004"
        }
    }
end

function obj.copyToClipboard(row)
    if (row ~= nil) then
        -- obj.chooser:hide()
        -- self:hide()
        local selectedRow = obj.currentChoices[row]
        hs.alert(selectedRow["text"])
        hs.pasteboard.setContents(selectedRow["text"])
    else
        -- self:hide()
        hs.alert("error")
    end
    -- print_r(obj)
    obj.chooser:hide()
end

function obj.chooserCallback(choice)
    hs.alert(choice["text"])
    hs.pasteboard.setContents(choice["text"])
    hs.eventtap.keyStrokes(choice["text"])
end

function obj.createChooser()
    obj.generateChoices()

    return hs.chooser.new(
        function(choice)
            if not (choice) then
                return
            else
                obj.chooserCallback(choice)
            end
        end
    ):rows(#obj.currentChoices + 1):width(20):choices(obj.currentChoices):searchSubText(true):rightClickCallback(
        obj.copyToClipboard
    )
end

function obj:init()
    obj.chooser = obj.createChooser()

    hs.hotkey.bind(
        mash,
        "J",
        function()
            obj.chooser:show()
        end
    )

    obj.chooser:showCallback(
        function()
            obj.generateChoices()
            obj.chooser:choices(obj.currentChoices)
        end
    )

    return self
end

return obj
