-- Generic functions and defaults
-- Largely taken from: https://github.com/zzamboni/oh-my-hammerspoon/blob/master/omh-lib.lua

apw = {}

hostname = hs.host.localizedName()
logger = hs.logger.new("apw-hs")
hs_config_dir = os.getenv("HOME") .. "/.hammerspoon/"

return apw
