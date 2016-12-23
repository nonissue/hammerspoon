-- A status/menubarlet to reflect the current 'burnrate' for
-- battery

-- implementation inspiration:
-- oh-my-hammerspoon https://github.com/zzamboni/oh-my-hammerspoon/blob/master/plugins/keyboard/menubar_indicator.lua
-- ShowyEdge (https://pqrs.org/osx/ShowyEdge/index.html.en)
-- Statuslets (From https://github.com/cmsj/hammerspoon-config/blob/master/init.lua)


local mod = {}
--
mod.config = {
  enableIndicator = true,
  allScreens = false,
}

function mod.init()
  logger.i('Enablng burnrate plugin')
  -- hs.alert('enabling burrnate plugin')
end

return mod
