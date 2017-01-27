hs.location.start()
local currentloc = hs.location.get()
hs.location.stop()

local tzOffset = tonumber(string.sub(os.date("%z"), 1, -3))
local times = {}

for i,v in pairs({"sunrise", "sunset"}) do
  times[v] = os.date("%H:%M", hs.location[v](currentloc.latitude, currentloc.longitude, tzOffset))
end

hs.redshift.start(3600, times.sunset, times.sunrise)
