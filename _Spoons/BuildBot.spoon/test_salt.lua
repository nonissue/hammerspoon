#!/usr/bin/env lua

-- Simple test script for SALT parser
local SaltParser = dofile("SaltParser.lua")

-- Read the actual SALT file
local function readFile(path)
    local file = io.open(path, "r")
    if not file then return nil end
    local content = file:read("*a")
    file:close()
    return content
end

print("Testing SALT Parser...")
print("=====================")

-- Test with the actual SALT file
local saltContent = readFile("Build Orders/Terran_2-1-1.SALT")
if saltContent then
    print("\n1. Testing with Terran_2-1-1.SALT:")
    print("SALT content: " .. saltContent:sub(1, 50) .. "...")

    local parsed, errors = SaltParser.parse(saltContent)
    if parsed and #parsed > 0 then
        print("✓ Successfully parsed " .. #parsed .. " steps")
        print("\nFirst 5 steps:")
        for i = 1, math.min(5, #parsed) do
            local step = parsed[i]
            print(string.format("  %d. [%02ds] %s %s",
                i, step.time, step.supply or "?", step.action or ""))
        end
    else
        print("✗ Failed to parse: " .. (errors or "unknown error"))
    end
else
    print("✗ Could not read SALT file")
end

-- Test with simple text format
print("\n2. Testing with text format:")
local textBuild = [[
12s @14 Pylon at ramp
17s @16 Gateway
20s @17 Scout with probe
27s @20 Cybernetics Core
38s @23 2nd Gas
]]

local parsed2, errors2 = SaltParser.parse(textBuild)
if parsed2 and #parsed2 > 0 then
    print("✓ Successfully parsed " .. #parsed2 .. " steps")
    for i, step in ipairs(parsed2) do
        print(string.format("  %d. [%02ds] @%s %s",
            i, step.time, step.supply or "?", step.action or ""))
    end
else
    print("✗ Failed to parse text: " .. (errors2 or "unknown error"))
end

-- Test with JSON format
print("\n3. Testing with JSON format:")
local jsonBuild = '{"build":[{"time":12,"supply":"14","action":"Pylon"},{"time":17,"supply":"16","action":"Gateway"}]}'

local parsed3, errors3 = SaltParser.parse(jsonBuild)
if parsed3 and #parsed3 > 0 then
    print("✓ Successfully parsed " .. #parsed3 .. " steps")
    for i, step in ipairs(parsed3) do
        print(string.format("  %d. [%02ds] @%s %s",
            i, step.time, step.supply or "?", step.action or ""))
    end
else
    print("✗ Failed to parse JSON: " .. (errors3 or "unknown error"))
end

print("\nTest complete!")