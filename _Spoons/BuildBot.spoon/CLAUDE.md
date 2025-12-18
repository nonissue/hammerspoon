# BuildBot.spoon - Starcraft 2 Build Order Overlay

## Overview

BuildBot is a Hammerspoon Spoon that provides a real-time overlay for Starcraft 2 build orders. It displays the current and upcoming build steps with precise timing information, helping players learn and execute complex build orders.

## Key Features

- **Real-time Overlay**: Shows current and next 2 build steps with timing
- **Game Integration**: Only displays when Starcraft 2 is focused
- **Timing Control**: Start/pause/resume/stop functionality for manual synchronization
- **SALT Encoding Support**: Parses various build order formats via SaltParser.lua
- **Visual Feedback**: Shows elapsed time and timing ahead/behind indicators

## Architecture

### Core Components

1. **`init.lua`** - Main spoon implementation with overlay management and timer logic
2. **`SaltParser.lua`** - Parser for SALT encoding and various build order formats
3. **`prompts.md`** - Documentation/prompts (minimal content currently)

### Data Flow

```
Build Order Input → SaltParser → Internal Format → Timer Logic → Canvas Overlay
```

## Build Order Format

Internal format uses tables with:
```lua
{
  time = 38,           -- seconds from game start
  supply = "23",       -- supply count (optional)
  action = "2nd Gas"   -- description of the action
}
```

## SALT Parser Capabilities

The SaltParser supports multiple input formats:
- **JSON**: Direct JSON with build arrays
- **Base64 JSON**: Base64-encoded JSON (requires hs.base64)
- **Text**: Human-readable text with time markers

### Text Format Examples
- `38s 2nd Gas @23` - 38 seconds, action "2nd Gas", at 23 supply
- `1:20 Gateway` - 1 minute 20 seconds, Gateway
- `12 @14 Pylon at ramp` - 12 seconds, at 14 supply, Pylon at ramp

## Usage

### Basic Setup
```lua
local BA = hs.loadSpoon("BuildBot")
BA:bindHotkeys({
  start = {{"ctrl","alt","cmd"}, "S"},
  pause = {{"ctrl","alt","cmd"}, "P"},
  resume = {{"ctrl","alt","cmd"}, "R"},
  stop = {{"ctrl","alt","cmd"}, "X"},
  toggle = {{"ctrl","alt","cmd"}, "H"},
  reload = {{"ctrl","alt","cmd"}, "L"},
})
```

### Loading Build Orders
```lua
-- Manual build table
BA:loadBuild({
  { time=12, supply="14", action="Pylon at ramp" },
  { time=17, supply="16", action="Gateway" },
  { time=20, supply="17", action="Scout" },
})

-- From SALT encoding
BA:loadSALT("your_salt_string_here")
```

## Configuration

Key settings in `obj.cfg`:
- `pollInterval = 0.2` - HUD update frequency
- `maxVisibleSteps = 3` - Number of steps to show
- `textSize = 24` - Overlay font size
- `align` - Positioning on screen (top-left by default)
- `bundleID = "com.blizzard.starcraft2"` - Target application

## Timer System

The timer tracks elapsed game time and handles:
- **Start/Sync**: Manual synchronization with game start
- **Pause/Resume**: Preserves elapsed time during pauses
- **Step Tracking**: Shows ahead/behind timing with +/- indicators

## Current Implementation Status

### Working Features
- ✅ Overlay display and positioning
- ✅ Timer logic with pause/resume
- ✅ Hotkey bindings
- ✅ Game focus detection
- ✅ SALT parser with multiple format support
- ✅ Build order step progression

### Areas for Testing/Improvement
- 🔄 SALT parser validation (mentioned as untested)
- 🔄 Performance optimization for longer build orders
- 🔄 Additional input format support
- 🔄 Error handling for malformed SALT strings

## File Structure
```
BuildBot.spoon/
├── init.lua          # Main spoon implementation
├── SaltParser.lua    # Build order format parser
├── prompts.md        # Documentation fragments
└── CLAUDE.md         # This documentation
```

## Development Notes

The implementation follows Hammerspoon Spoon conventions with proper lifecycle management. The overlay uses `hs.canvas` for rendering and `hs.window.filter` for game detection.

The SALT parser is particularly robust, attempting multiple parsing strategies and gracefully falling back when formats don't match.

## Recent Session History (2025-09-18)

### Issue Encountered
- BuildBot spoon was not loading due to "table being nil" error
- Problem traced to previous transparency changes in display logic

### Changes Made
1. **Transparency Feature Attempt**: Previously attempted to add transparency to previous build steps by modifying:
   - `fmtStepLine()` function to return styled text objects with alpha values
   - `_composeText()` function to handle styled text arrays instead of simple strings

2. **Issue Identified**: The styled text implementation broke the spoon loading because:
   - `fmtStepLine()` inconsistently returned either strings or styled text objects
   - Code tried to access `.text` property on string returns, causing nil table errors

3. **Solution Applied**: Reverted transparency changes:
   - Restored `fmtStepLine()` to return simple strings (removed `dimmed` parameter)
   - Simplified `_composeText()` to concatenate strings with `table.concat()`
   - Removed all styled text object handling

### Current Status
- BuildBot spoon code is functional again
- User has commented out the spoon loading in `init.lua` (lines 365-423)
- Need to uncomment the BuildBot loading code to test functionality

### Next Steps
- User should uncomment BuildBot loading section in `init.lua`
- Test spoon loading and basic functionality
- If transparency is still desired, implement it properly with consistent return types