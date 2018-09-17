-- quick file to control things im playing with

spinner = require("spinner")

local testSpinner = spinner.new()
testSpinner:start()
hs.timer.doAfter(15,
        function()
            testSpinner:stop()
    end
)
