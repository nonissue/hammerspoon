-- A status/menubarlet to reflect the current 'burnrate' for
-- battery

-- implementation inspiration:
-- oh-my-hammerspoon https://github.com/zzamboni/oh-my-hammerspoon/blob/master/plugins/keyboard/menubar_indicator.lua
-- ShowyEdge (https://pqrs.org/osx/ShowyEdge/index.html.en)
-- Statuslets (From https://github.com/cmsj/hammerspoon-config/blob/master/init.lua)


BurnRate = {}

local burnRateMenu = hs.menubar.new()

function BurnRate:new()
    -- test should be local, but just messing with this for now
    test = hs.chooser.new(function(input) print(hs.inspect(input)) end)
        :rows(3)
    test:choices(chooserChoices)
    test:width(20)
    test:subTextColor({red=0, green=0, blue=0, alpha=0.4})
    -- test:bgDark(true)
    hs.hotkey.bind({"cmd", "alt", "ctrl"}, 'd', function() test:show() end)
    -- print(test:query())
end

return BurnRate
