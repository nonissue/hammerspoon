-- A status/menubarlet to reflect the current 'burnrate' for
-- battery

-- implementation inspiration:
-- oh-my-hammerspoon https://github.com/zzamboni/oh-my-hammerspoon/blob/master/plugins/keyboard/menubar_indicator.lua
-- ShowyEdge (https://pqrs.org/osx/ShowyEdge/index.html.en)
-- Statuslets (From https://github.com/cmsj/hammerspoon-config/blob/master/init.lua)

-- More info:
-- https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man1/powermetrics.1.html
-- https://randomfoo.net/2013/11/08/more-on-os-x-mavericks-power-usage
-- https://blog.mozilla.org/nnethercote/2015/08/26/what-does-the-os-x-activity-monitors-energy-impact-actually-measure/


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
