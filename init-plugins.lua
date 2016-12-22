-- code to init plugins

-- require this code from init.lua

package.path = package.path .. ';plugins/?.lua'

apw = {}

hostname = hs.host.localizedName()

omh.plugin_cache={}


return apw
