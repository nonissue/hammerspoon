-- from here:
-- https://github.com/heptal/dotfiles/blob/master/roles/hammerspoon/files/redshift.lua

-- Made redundant by upcoming features in 10.12.4, was going to keep working on this
-- so I could enable/disable/adjust redshift level easily but probably not worthwhile
-- unless I find the new implemntation lacking.

local mod = {}

mod.config = {
  times = {
    -- These aren't accurate
    sunrise = "07:00",
    sunset = "20:00",
  }
}

hs.location.start()
hs.timer.doAfter(1, function()
  loc = hs.location.get()
  hs.location.stop()

  if loc then
      local tzOffset = tonumber(string.sub(os.date("%z"), 1, -3))
      for i,v in pairs({"sunrise", "sunset"}) do
        mod.config.times[v] = os.date("%H:%M", hs.location[v](loc.latitude, loc.longitude, tzOffset))
      end
  end

  hs.redshift.start(3500, mod.config.times.sunset, mod.config.times.sunrise, "3h")
end)

return mod
