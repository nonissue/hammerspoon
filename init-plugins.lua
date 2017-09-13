-- code to init plugins
-- Entirely copied from oh-my-hammerspoon
-- require this code from init.lua

package.path = package.path .. ';plugins/?.lua'
require('apw-lib')
-- local custom_alerts = {fillColor = { white = 0, alpha = 0.1 }, radius = 70, strokeColor = { white = 1, alpha = 0}, strokeWidth = 0, textSize = 80}

-- apw = {}

hostname = hs.host.localizedName()

apw.plugin_cache={}
local APW_PLUGINS={}
local APW_CONFIG={}

function load_plugins(plugins)
 plugins = plugins or {}
 for i,p in ipairs(plugins) do
    table.insert(APW_PLUGINS, p)
 end
 for i,plugin in ipairs(APW_PLUGINS) do
    logger.df("Loading plugin %s", plugin)
    -- First, load the plugin
    mod = require(plugin)
    -- If it returns a table (like a proper module should), then
    -- we may be able to access additional functionality
    if type(mod) == "table" then
       -- If the user has specified some config parameters, merge
       -- them with the module's 'config' element (creating it
       -- if it doesn't exist)
       if APW_CONFIG[plugin] ~= nil then
          if mod.config == nil then
             mod.config = {}
          end
          for k,v in pairs(APW_CONFIG[plugin]) do
             mod.config[k] = v
          end
       end
       -- If it has an init() function, call it
       if type(mod.init) == "function" then
          logger.i(string.format("Initializing plugin %s", plugin))
          mod.init()
       end
    end
    -- Cache the module
    apw.plugin_cache[plugin] = mod
 end
end

function apw_config(name, config)
   logger.df("apw_config, name=%s, config=%s", name, hs.inspect(config))
   APW_CONFIG[name]=config
end

function apw_go(plugins)
   load_plugins(plugins)
end

local status, err = pcall(function() require("init-local") end)
if not status then
   -- A 'no file' error is OK, but anything else needs to be reported
   if string.find(err, 'no file') == nil then
      error(err)
   end
end

notify("Config Loaded ✔")
-- hs.alert.show("✔", alerts_standard, 1)

-- hs.alert("Config Loaded!", 1)
-- notify("APW Hammerspoon loaded", "Config loaded")
