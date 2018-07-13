-- UPDATE 18/01/10 : This was kind of dumb and is obsolete. 

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

local green = {color = {green = 1, alpha = 1}}
local yellow = {color = {red = 1, green = 1, alpha = 1}}
local orange = {color = {red = 1, green = 0.64, blue = 0, alpha = 1}}
local red = {color = {red = 1, alpha = 1}}


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
  -- egpu only provides 60w which is enough to charge
  -- most of the time, but hs/system doesnt consider 
  -- it to be charging
  if hs.battery.isCharging() or cur_amh == 0 then
    setBurnrateText("⚡︎", green)
  elseif designCap / cur_amh > 15 then
    setBurnrateText("⚡︎: " .. burnrateRounded .. " ERR", red)
  elseif designCap / cur_amh > 10 then
    setBurnrateText("⚡︎: " .. burnrateRounded, green)
  elseif designCap / cur_amh > 6 then
    setBurnrateText("⚡︎: " .. burnrateRounded, green)
  elseif designCap / cur_amh > 4 then
    -- notify("High Power Usage")
    setBurnrateText("⚡︎: ".. burnrateRounded, orange)
  else
    setBurnrateText("⚡︎: " .. burnrateRounded, red)
  end
end

-- show burnrate as graphic

hs.battery.watcher.new(check_burnrate):start()
local burnrateMenu = hs.menubar.new()

function setBurnrateIcon(rate)
  burnrateMenu:setTitle(tostring("|"))
end

function setBurnrateText(amperage, color)
  local title = hs.styledtext.new(tostring(amperage), color)
  burnrateMenu:setTitle(title)
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
