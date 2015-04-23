local hyper = {"cmd", "alt", "ctrl"}


hs.hotkey.bind({"cmd", "alt", "ctrl"}, "H", function()
    hs.hints.windowHints()
end)


function reload_config(files)
   hs.reload()
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/init.lua", reload_config):start()
hs.alert.show("Config loaded")