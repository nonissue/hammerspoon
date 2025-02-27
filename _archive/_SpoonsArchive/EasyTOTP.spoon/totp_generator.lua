local obj = {}
obj.__index = obj
obj.__name = "totp_generator"

-- -- Utility for getting current paths
local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

obj.spoonPath = script_path()

-- -- Import basexx utilities
local basexx = dofile(obj.spoonPath.."basexx.lua")

-- binary AND operator
local band = function(a, b)
  return a & b
end

-- convert a hex string to binary string
local function hex_to_binary(hex)
  return hex:gsub('..', function(hexval)
    return string.char(tonumber(hexval, 16))
  end)
end

function obj:generate_token(skey, value)
  print(skey .. " / " .. value)

  local skey = basexx.from_base32(skey)

  
  local value = string.char(
      0, 0, 0, 0,
      band(value, 0xFF000000) / 0x1000000,
      band(value, 0xFF0000) / 0x10000,
      band(value, 0xFF00) / 0x100,
      band(value, 0xFF))
  print(skey .. " / " .. value)
  local hash = hex_to_binary(hs.hash.hmacSHA1(skey, value))
  local offset = band(hash:sub(-1):byte(1, 1), 0xF)
  local function bytesToInt(a,b,c,d)
      return a*0x1000000 + b*0x10000 + c*0x100 + d
  end
  hash = bytesToInt(hash:byte(offset + 1, offset + 4))
  hash = band(hash, 0x7FFFFFFF) % 1000000
  return ("%06d"):format(hash)
end

return obj