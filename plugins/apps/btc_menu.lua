-- bitcoin price menubar item
-- UNFINISHED

-- Inspiration: https://github.com/skamsie/hs-weather/blob/master/init.lua

-- Todo:
-- [x] Get API calls working
-- [ ] Verify timer functionality
-- [ ] Round results
-- [ ] Use config file properly.
-- [ ] Implement start/stop mod methods
-- [ ] Click to refresh?
-- [ ] Store results for trend analysis?
-- [ ] Set up alerts

-- https://api.coindesk.com/v1/bpi/currentprice/CAD.json
-- https://www.coindesk.com/api/

local mod = {}

-- local hammerDir = hs.fs.currentDir()

local URLBASE = 'https://api.coindesk.com/v1/bpi/currentprice/'
local APIURL = 'https://api.coindesk.com/v1/bpi/currentprice/CAD.json'


local configFile = ('config.json')

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

local function fetchPrice()
	-- CUstomize in future to accept diff currencies
	local bitcoinEndpoint = (APIURL)
	hs.http.asyncGet(bitcoinEndpoint, nil,
	    function(code, body, table)
	      if code ~= 200 then
	        print('-- btc_menu: Could not get weather. Response code: ' .. code)
	      else
	        print('-- btc_menu: price')

	        local response = hs.json.decode(body)
	        local current_rate = response.bpi.USD.rate_float

	        print(current_rate)

	        if response == nil then
	          if mod.btc_menu:title() == '' then
	            setPriceTitle(mod.btc_menu, current_rate)
	          end
	        else
	        	-- Handle updates properly?
	        	setPriceTitle(mod.btc_menu, current_rate)
	        	print('Updating Price!')
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

	mod.config.refresh = mod.config.refresh or 300

	mod.btc_menu = hs.menubar.new()
	fetchPrice()

	hs.timer.doEvery(
		mod.config.refresh, function () fetchPrice() 
	end)
end

mod.stop = function()
  mod.timer:stop()
end

return mod