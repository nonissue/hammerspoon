-- hs.textDroppedToDockIconCallback()
-- hs.dockIconClickCallback()
-- hs.dockIcon(true)
-- initial testing with using the 'send to' contextual menu functionality
hs.textDroppedToDockIconCallback = function(value)
    hs.alert(string.format("Text dropped to dock icon: %s", value))
end
