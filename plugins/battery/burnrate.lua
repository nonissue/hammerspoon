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

-- Todo:
-- [ ] Change display to make it a statuslet, or bar along top of screen
-- [ ] Enable config so user can set battery options (as burrnate will vary between devices)
-- [ ] Alternately: could replace sys battery indicator
-- [ ] Fix bracketing for display (Something better than Low/Med/High)
-- [ ] Improve formula? Normalize for range 1-10 or something?

local mod = {}

-- Nonsense placeholder config options
mod.config = {
  enableIndicator = true,
  allScreens = false,
}

--------------------------------------------------
-- Handler directly called by the "low-level" watcher API.
--------------------------------------------------
local cur_amh = nil
function check_burnrate()
  -- BurnRate = Rate of Battery drain = BR
  cur_amh = math.abs(hs.battery.amperage())
  designCap = hs.battery.designCapacity()
  local burnrateActual = designCap / cur_amh
  local burnrateRounded = round(burnrateActual, 1)
  if hs.battery.isCharging() then
    setBurnrateText("Charging")
  elseif designCap / cur_amh > 10 then
    setBurnrateText("BR: N/A / " .. burnrateRounded)
  elseif designCap / cur_amh > 7 then
    setBurnrateText("BR: Low / " .. burnrateRounded)
  elseif designCap / cur_amh > 4 then
    setBurnrateText("BR: Med / " .. burnrateRounded)
  else
    setBurnrateText("BR: Hi / " .. burnrateRounded)
  end
end

hs.battery.watcher.new(check_burnrate):start()
local burnrateMenu = hs.menubar.new()

function setBurnrateText(amperage)
  burnrateMenu:setTitle(tostring(amperage))
end

function mod.init()
  logger.i('Enablng burnrate plugin')
  check_burnrate()
end

return mod
