-- Our pseudo-class for DemoModal
DemoModal = {}

-- Table for demo modal
local modalChoices = {"Choice 1", "Choice 2", "Choice 3", "Choice 4"}

function DemoModal:new()
-- function setupDemoModal()
    -- Set hotkey we want to enter modal.. mode
    local e = hs.hotkey.modal.new('cmd-alt-ctrl', 'd')

    -- bind our exit modal mode key to esc
    e:bind('', 'escape', function() hs.alert.closeAll() e:exit() end)


    -- For loop goes through our choices in our modalChoices table
    -- and for each item in table, binds a corresponding number
    -- By binding only these specific keys, other input is ignored except for
    -- esc key. If we had more than 9 entries in table this would fail
    for i = 1, #modalChoices do
        e:bind({}, tostring(i), function() DemoModal:processKey(i) end)
    end

    -- simple way of display the choices want to make available for our modal
    local function displayModalChoices()
        -- Iterate through the modelChoices again and display the key (1-9)
        -- and corresponding item from table
        -- Time to display is set to 99 so all options stay on screen
        for i = 1, #modalChoices do
            hs.alert(tostring(i) .. ": " .. modalChoices[i], 99)
        end
    end

    -- on modal entry, display choices
    function e:entered() displayModalChoices() end
    -- on model exit, clear all alerts
    function e:exited() hs.alert.closeAll() end

end

function DemoModal:processKey(i)
    -- here we exit the modal mode because the user has made a valid choice
    -- and we want to close the existing alerts
    e:exit()
    -- once all other alerts are closed and we are out of modal mode, show
    -- the user a message with the result of their choice
    hs.alert("You picked choice " .. tostring(i) .. " from the modal menu", 5)
end

-- return DemoModal class
return DemoModal
