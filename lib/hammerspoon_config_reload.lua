-- https://github.com/zzamboni/oh-my-hammerspoon/blob/23016eb58c1234e765b16e46c5b4b551bc88e9a4/plugins/apps/hammerspoon_config_reload.lua

---- Configuration file management
---- Original code from http://www.hammerspoon.org/go/#fancyreload

-- utils = require('utilies')

local mod={}
local configFileWatcher

mod.config = {
   auto_reload = true,
}

-- Automatic config reload if any files in ~/.hammerspoon change
function reloadConfig(files)
   doReload = false
   for _,file in pairs(files) do
      if file:sub(-4) == ".lua" then
         doReload = true
      end
   end
   if doReload then
      hs.reload()
   end
end

function mod.init()
   if mod.config.auto_reload then
      print("Setting up config auto-reload watcher on %s", hs_config_dir)
      configFileWatcher = hs.pathwatcher.new(hs_config_dir, reloadConfig)
      configFileWatcher:start()
   end

  --  Manual config reload
    -- apw.bind(mod.config.manual_reload_key, hs.reload)
end

return mod
