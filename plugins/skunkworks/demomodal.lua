-- Our pseudo-class for DemoModal

-- Should make this reusable
-- Person sets choices, sets key, sets callback themselves
local mod = {}

mod.config = {
  display_modal_key = {{"cmd", "alt", "ctrl"}, "l"},
  display_modal_exit = {{""}, "escape"},
  modal_choices = {"Choice 1", "Choice 2", "Choice 3", "Choice 4"}
}

-- Table for demo modal
local e = hs.hotkey.modal.new('cmd-alt-ctrl', 'd')


function mod.processKey(i)
    -- here we exit the modal mode because the user has made a valid choice
    -- and we want to close the existing alerts
    e:exit()
    -- once all other alerts are closed and we are out of modal mode, show
    -- the user a message with the result of their choice
    hs.alert("You picked choice " .. tostring(i) .. " from the modal menu", 2)
end

function mod.init()
-- function setupDemoModal()
    -- Set hotkey we want to enter modal.. mode


    -- bind our exit modal mode key to esc
    -- e:bind('', 'escape', function() hs.alert.closeAll() e:exit() end)
    apw.bind(mod.config.display_modal_exit, hs.alert.closeAll)

    -- For loop goes through our choices in our modalChoices table
    -- and for each item in table, binds a corresponding number
    -- By binding only these specific keys, other input is ignored except for
    -- esc key. If we had more than 9 entries in table this would fail
    for i = 1, #mod.config.modal_choices do
        e:bind({}, tostring(i), function() mod.processKey(i) end)
    end

    -- simple way of display the choices want to make available for our modal
    local function displayModalChoices()
        -- Iterate through the modelChoices again and display the key (1-9)
        -- and corresponding item from table
        -- Time to display is set to 99 so all options stay on screen
        for i = 1, #mod.config.modal_choices do
            hs.alert(tostring(i) .. ": " .. mod.config.modal_choices[i], 2)
        end
    end

    -- on modal entry, display choices
    function e:entered() displayModalChoices() end
    -- on model exit, clear all alerts
    function e:exited() hs.alert.closeAll() end

end



-- return DemoModal class
return mod
