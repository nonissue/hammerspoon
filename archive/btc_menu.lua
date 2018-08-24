-- bitcoin price menubar item
-- UNFINISHED

-- Inspiration: https://github.com/skamsie/hs-weather/blob/master/init.lua

-- Todo:
-- [x] Get API calls working
-- [x] Verify timer functionality / KINDA?
-- [x] Round results / KINDA FIXED WITH MATh.FLOOR
-- [x] Use config file properly.
-- [ ] Implement start/stop mod methods
-- [ ] Store results for trend analysis?
-- [ ] Set up alerts
-- [ ] Daily High / Low -- Or last 24hours?
-- [ ] Show last update time on refresh
-- [ ] Optionally pull current BTC balance from coinbase?
-- [ ] Dropdown menu:
-- * refresh
-- * last update time
-- * currency
-- * daily highs/lows
-- * current bitcoin holdings value
-- [ ] properly log rather than print

-- https://api.coindesk.com/v1/bpi/currentprice/CAD.json
-- https://www.coindesk.com/api/

local mod = {}

local URLBASE = 'https://api.coindesk.com/v1/bpi/currentprice/'
local APIURL = 'https://api.coindesk.com/v1/bpi/currentprice/CAD.json'

local hammerspoonDir = hs.fs.currentDir()
local configFile = (hammerspoonDir .. '/plugins/apps/btc_config.json')

local function readConfig(file)
	local f = io.open(file, "rb")
	
	if not f then
    return {}
	end
	
	local content = f:read("*all")
	
	f:close()
	
  return hs.json.decode(content)
end

function setPriceTitle(app, price)
	-- ugly display hack to remove the decimal
	app:setTitle('BTC: ' .. math.floor(price + 0.5))
end

local function fetchPrice(currency)
	local bitcoinEndpoint = (URLBASE .. currency .. '.json')

	hs.http.asyncGet(bitcoinEndpoint, nil,
	    function(code, body, table)
	      if code ~= 200 then
	        print('-- btc_menu: Could not get price. Response code: ' .. code)
	      else
	        print('-- btc_menu: price returned')

	        local response = hs.json.decode(body)
	        local current_rate = response.bpi[currency].rate_float

	        if response == nil then
	          if mod.btc_menu:title() == '' then
	            setPriceTitle(mod.btc_menu, current_rate)
	          end
	        else
	        	setPriceTitle(mod.btc_menu, current_rate)
	        end
	      end
	    end
	  )
end

function priceAlert()
	return
end

function mod.init() 
	mod.config = readConfig(configFile)
	mod.config.refresh = mod.config.refresh or 240
	mod.config.currency = mod.config.currency or 'USD'

	print(mod.config.currency)
	
	mod.btc_menu = hs.menubar.new()
	
	fetchPrice(mod.config.currency)

	hs.timer.doEvery(
		mod.config.refresh, function () fetchPrice(mod.config.currency) 
	end)
end

mod.stop = function()
  mod.timer:stop()
end

return mod