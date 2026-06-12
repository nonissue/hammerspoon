# Context.spoon

Mutes audio when leaving home wifi (or waking from sleep away from home),
unmutes when arriving back home. No wifi counts as away.

Home networks are read from the `homeSSIDs` key in `hs.settings`
(set in the main `init.lua`).

It also publishes the `context` watchable so other spoons can react to
system state changes:

| key                     | value                                     |
| ----------------------- | ----------------------------------------- |
| `context.location`      | `"home"` \| `"away"`                      |
| `context.currentSSID`   | string \| nil                             |
| `context.primaryScreen` | `hs.screen` object                        |

`Resolute.spoon` watches `context.primaryScreen` to rebuild its resolution
menu when the primary screen changes — that's why the screen watcher lives
here.

## Usage

```lua
hs.settings.set("homeSSIDs", { "MyNetwork", "MyNetwork-5G" })
hs.loadSpoon("Context"):start()
```

## History

v1 also handled dock position/hiding when docked to a monitor, a menubar
indicator (location / docked state / GPU), a dark mode toggle, drive
ejection, and `sudo pmset` sleep tweaks based on location. All of that was
removed in the v2 overhaul (June 2026) — see git history if any of it is
ever wanted again.
