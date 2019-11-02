--[[
targetapp://x-callback-url/translate?
   x-success=sourceapp://x-callback-url/acceptTranslation&
   x-source=SourceApp&
   x-error=sourceapp://x-callback-url/translationError&
   word=Hello&
   language=Spanish


bear://x-callback-url/search?term=mental&show_window=no&x-success=hammerspoon://bearSearchResults?results=
   x-success=sourceapp://x-callback-url/acceptTranslation&
   x-source=SourceApp&
   x-error=sourceapp://x-callback-url/translationError&
   word=Hello&
   language=Spanish

   https://elaptics.co.uk/marginalia/2017/bear-running-list/
]]

function handleJSON(eventName, notes)
    print("callback")
    print(i(notes))
    print(i(notes['notes']))
    -- return notes
end

hs.urlevent.bind("bearSearchResults", handleJSON)

-- hs.urlevent.openURL("bear://x-callback-url/search?term=mental&show_window=no&token=F48970-B4D5E5-AF75EA&x-success=hammerspoon://bearSearchResults?notes")

--[[
    keyboard shortcut invokes chooser
    chooser accepts query string to search bear
    chooser populated with results
    current frontmost tab url appended to selected note?
]]