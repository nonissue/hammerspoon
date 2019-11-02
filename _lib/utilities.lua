local obj = {}
obj.__index = obj

-- Metadata
obj.name = "utilities"

-- function obj.bind(keyspec, fun)
--     hs.hotkey.bind(keyspec[1], keyspec[2], fun)
-- end

-- I find it a little more flexible than hs.inspect for developing
-- i like this, but it's not used many places. hmm.
function obj.print_r ( t )
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"    ")
        print("}")
    else
        sub_print_r(t,"    ")
    end
    print()
end

-- only used one place? 
-- plugins/battery/burnrate.lua
function obj.round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    if num >= 0 then 
        return math.floor(num * mult + 0.5) / mult
    else 
        return math.ceil(num * mult - 0.5) / mult 
    end
end

function obj.has_val(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end


return obj