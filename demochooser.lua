DemoChooser = {}

-- local chooserChoices = {"Choice 1", "Choice 2", "Choice 3", "Choice 4"}

local chooserChoices = {
 {
  ["text"] = "First Choice",
  ["subText"] = "This is the subtext of the first choice",
  ["uuid"] = "0001"
 },
 { ["text"] = "Second Option",
   ["subText"] = "I wonder what I should type here?",
   ["uuid"] = "Bbbb"
 },
 { ["text"] = "Third Possibility",
   ["subText"] = "What a lot of choosing there is going on here!",
   ["uuid"] = "III3"
 },
}


function DemoChooser:new()

    local test = hs.chooser.new(function(input) print(input) end)
        :rows(5)

    test:choices(chooserChoices)
    test:show()

end


function DemoChooser:displayTest()
    hs.alert("It works!", 5)
end

return DemoChooser
