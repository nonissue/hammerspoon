-- A status/menubarlet to reflect the current 'burnrate' for battery.

--[[

Overview:
Give user visual way to track the rate at which their battery is draining, and provide a warning if it is
draining very quickly.

Background:
While on battery, there are times when I've left a program running that drains my battery quickly
that I no longer need. If I am not paying very close attention to how quickly my battery is draining,
this mistake may cause a significant impact on battery life.
Another possible example is run-away processes. During dev, sometimes builds/threads hit 100% without me realzing


Method:
While on battery power only, I calculate it as current designCapacity / currentAmperage
Hammerspoon is able to provide both numbers. This works because I am not overly concerned about
WHAT is causing the drain, just that it is happening, and that the user is alerted when
the battery is draining very quickly.

Caveats:
My dichotomy (low/med/hi etc) is something I arbitrarily settled on, and is not thorough or scientific
Furthermore, my calculation ( designCapacity / currentAmperage ) *should* return a number close to
macOS' "time remaining" figure. This is not perfect, as different computers have different expectations
in terms of overall battery duration. Also, batteries that aren't at 100% of their original capacity
will not last as long, but in my opinion, this should not matter as the 'burnrate' is being calculated
based on design capacity.

Implementation inspiration:
* oh-my-hammerspoon https://github.com/zzamboni/oh-my-hammerspoon/blob/master/plugins/keyboard/menubar_indicator.lua
* ShowyEdge (https://pqrs.org/osx/ShowyEdge/index.html.en)
* Statuslets (From https://github.com/cmsj/hammerspoon-config/blob/master/init.lua)

More resources/info:
* https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man1/powermetrics.1.html
* https://randomfoo.net/2013/11/08/more-on-os-x-mavericks-power-usage
* https://blog.mozilla.org/nnethercote/2015/08/26/what-does-the-os-x-activity-monitors-energy-impact-actually-measure/

Todo:
[ ] Change display to make it a statuslet, or bar along top of screen
[ ] Enable config so user can set battery options (as burrnate will vary between devices)
[ ] Alternately: could replace sys battery indicator
[ ] Fix bracketing for display (Something better than Low/Med/High)
[ ] Improve formula? Normalize for range 1-10 or something?

]]--

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
    setBurnrateText("BR:" .. burnrateRounded)
    -- setBurnrateText("BR: Low / " .. burnrateRounded)
  elseif designCap / cur_amh > 4 then
    -- setBurnrateIcon()
    setBurnrateText("BR:" .. burnrateRounded)
    -- setBurnrateText("BR: Med / " .. burnrateRounded)
  else
    setBurnrateText("BR:" .. burnrateRounded)
    -- setBurnrateText("BR: Hi / " .. burnrateRounded)
  end
end

-- show burnrate as graphic

hs.battery.watcher.new(check_burnrate):start()
local burnrateMenu = hs.menubar.new()

function setBurnrateIcon(rate)
  -- burnrateMenu:setIcon("test.pdf")
  burnrateMenu:setTitle(tostring("|"))
  -- burnrateMenu:setIcon(rate)
end

function setBurnrateText(amperage)
  burnrateMenu:setTitle(tostring(amperage))
end

function mod.init()

  if hostname ~= "iMac" then
    logger.i('Enablng burnrate plugin on laptop')
    check_burnrate()
  else
    logger.i('Not enabling burnrate on iMac')
  end
end

return mod
