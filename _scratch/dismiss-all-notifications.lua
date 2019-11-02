
-- COPIED FROM: https://github.com/af/dotfiles/blob/63370411e709e006b26f07781376da1e6d7ae2c8/hammerspoon/utils.lua#L51
-- Close all open notifications
local function dismissAllNotifications()
    local success, result = hs.applescript([[
    tell application "System Events"
        tell process "Notification Center"
            set theWindows to every window
            repeat with i from 1 to number of items in theWindows
                set this_item to item i of theWindows
                try
                    click button 1 of this_item
                end try
            end repeat
        end tell
    end tell
    ]])
    if not success then
        hs.logger.e("Error dismissing notifcations")
        hs.logger.e(result)
    end
end

hs.hotkey.bind(mash, "N", dismissAllNotifications)