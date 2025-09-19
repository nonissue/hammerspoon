-- SaltParser.lua
-- Utility to parse SC2 SALT strings into {time, supply, action} tables

local M = {}

local json = require("hs.json")
local haveBase64, b64 = pcall(require, "hs.base64")

local function validateTime(time)
    return time and time >= 0 and time <= 7200
end

local function parseTime(tok)
    tok = (tok or ""):lower()
    local h, m, s
    if tok:match("^%d+:%d%d:%d%d$") or tok:match("^%d+:%d%d$") then
        local parts = {}
        for part in tok:gmatch("%d+") do parts[#parts + 1] = tonumber(part) end
        if #parts == 2 then
            m, s = parts[1], parts[2]
            local time = m * 60 + s
            return validateTime(time) and time or nil
        elseif #parts == 3 then
            h, m, s = parts[1], parts[2], parts[3]
            local time = h * 3600 + m * 60 + s
            return validateTime(time) and time or nil
        end
    end
    local mm, ss = tok:match("^(%d+)m(%d+)s$")
    if mm and ss then
        local time = tonumber(mm) * 60 + tonumber(ss)
        return validateTime(time) and time or nil
    end
    mm = tok:match("^(%d+)m$")
    if mm then
        local time = tonumber(mm) * 60
        return validateTime(time) and time or nil
    end
    ss = tok:match("^(%d+)s$")
    if ss then
        local time = tonumber(ss)
        return validateTime(time) and time or nil
    end
    if tok:match("^%d+$") then
        local time = tonumber(tok)
        return validateTime(time) and time or nil
    end
    return nil
end

local function pushStep(t, steps)
    local time = tonumber(t.time) or parseTime(t.time)
    if not time then return end
    local supply = t.supply and tostring(t.supply) or nil
    steps[#steps + 1] = { time = time, supply = supply, action = t.action or "" }
end

local function parseJSON(str)
    local ok, data = pcall(json.decode, str)
    if not ok or not data then return nil end
    local arr = data.build or data.steps or data
    local steps = {}
    if type(arr) == "table" then
        for _, v in ipairs(arr) do pushStep(v, steps) end
    end
    return #steps > 0 and steps or nil
end

local function parseBase64JSON(str)
    if not haveBase64 then return nil end
    local ok, decoded = pcall(b64.decode, str)
    if not ok or not decoded then return nil end
    return parseJSON(decoded)
end

local function parseText(str)
    local steps, raw = {}, {}
    for seg in str:gmatch("[^;\n]+") do
        local line = seg:gsub("%s+", " "):match("^%s*(.-)%s*$")
        if line ~= "" then raw[#raw + 1] = line end
    end
    for _, line in ipairs(raw) do
        local tTime = line:match("(%d+:%d%d:%d%d)") or line:match("(%d+:%d%d)") or
            line:match("(%d+%s*[sm])") or line:match("(%d+)")
        local time = tTime and parseTime(tTime)
        local supply = line:match("@(%d+)") or line:match("^%s*(%d+)%s+") or
            line:match("%s+(%d+)%s+") or line:match("supply[:%s]*(%d+)")
        local act = line
        if tTime then act = act:gsub(tTime, "", 1) end
        if supply then act = act:gsub("@" .. supply, "", 1) end
        act = act:match("^%s*(.-)%s*$")
        if time then steps[#steps + 1] = { time = time, supply = supply, action = act } end
    end
    return #steps > 0 and steps or nil
end

function M.parse(s)
    local parsers = { parseJSON, parseBase64JSON, parseText }
    local errors = {}

    for _, f in ipairs(parsers) do
        local ok, res = pcall(f, s)
        if ok and res then
            table.sort(res, function (a, b) return a.time < b.time end)
            return res, nil
        elseif not ok then
            errors[#errors + 1] = tostring(res)
        end
    end

    local errorMsg = #errors > 0 and table.concat(errors, "; ") or "Unknown format"
    return {}, errorMsg
end

return M
