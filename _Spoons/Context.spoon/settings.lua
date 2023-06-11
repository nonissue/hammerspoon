--[[
    TODO:
        - [ ] Clear watchers? not sure if we have to
        - [ ] obj:showSettings
]]
local obj = {}
obj.__index = obj

obj.name = "Context.Settings"
obj.version = "1.0"
obj.author = "andy williams <andy@nonissue.org>"
obj.homepage = "https://github.com/nonissue"
obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.logger = hs.logger.new("Context.Settings")

local CONTEXT_SETTINGS_DEFAULTS = {
    debug_mode = true,
    setup_done = false,
    show_appearance_toggle = true,
    show_gpu = false,
    show_location = true,
    show_menu = true
}

function obj:clearSettings()
    for k, v in pairs(CONTEXT_SETTINGS_DEFAULTS) do
        hs.settings.clear("context_settings_" .. k)
    end
end

-- use default settings list to show all settings, default or configured
function obj:showSettings()
    for k, v in pairs(CONTEXT_SETTINGS_DEFAULTS) do
        print("context_settings_" .. k .. ": " .. tostring(hs.settings.get("context_settings_" .. k)))
    end
end

function obj:setDefaultSettings()
    for k, v in pairs(CONTEXT_SETTINGS_DEFAULTS) do
        hs.settings.set("context_settings_" .. k, v)
        hs.settings.watchKey(
            "context.settings.watcher." .. k,
            "context_settings_" .. k,
            function(key)
                hs.alert("context should reload...")
            end
        )
    end

    hs.settings.set("context_settings_setup_done", false)
end

function obj:init()
    if (not hs.settings.get("context_settings_setup_done")) then
        -- Periods don't work with settings.watchKey,
        -- so we can't do something like
        -- context.settings -> table of keys/values
        obj.logger.i("CONTEXT SETUP NOT DONE")
        obj.logger.i("Setting defaults...")
        obj:setDefaultSettings()
    else
        obj.logger.i("CONTEXT SETUP DONE")
    end

    return obj
end

return obj
