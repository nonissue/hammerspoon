DemoChooser = {}

-- local chooserChoices = {"Choice 1", "Choice 2", "Choice 3", "Choice 4"}

-- Idea here is to have a chooser appear, and then I can use it to do a google
-- site specific search from the lsit of sites.

-- Useful because I search a few sites on a regular basis for specific info

local chooserChoices = {
 {
  ["text"] = "Reddit",
  ["subText"] = "Quickly search reddit",
  ["uuid"] = "site:reddit.com"
 },
 { ["text"] = "Kijiji (Edmonton)",
   ["subText"] = "Quick search local kjiji",
   ["uuid"] = "site:edmonton.kijiji.ca"
 },
 { ["text"] = "Third Possibility",
   ["subText"] = "What a lot of choosing there is going on here!",
   ["uuid"] = "III3"
 },
}

function DemoChooser:new()
    -- test should be local, but just messing with this for now
    test = hs.chooser.new(function(input) print(hs.inspect(input)) end)
        :rows(5)
    test:choices(chooserChoices)
    test:width(30)
    test:subTextColor({red=0, green=0, blue=0, alpha=0.1})
    -- test:bgDark(true)
    hs.hotkey.bind({"cmd", "alt", "ctrl"}, 'd', function() test:show() end)
    -- print(test:query())
end

function SiteSearchQuery(site)
  local site_search = hs.chooser.new(function(site, query) print(site) end)
end


return DemoChooser
