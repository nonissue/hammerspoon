---

**Important**: as of `21-04-27`, issue may be resolved.

---

# Hammerspoon Got Greedy

## Log

### `21-04-27` (**Important:** Potentially Resolved)

- Might be fixed with `0.9.88`. Noticed this line:
  - > Changed: hs.loadSpoon() no longer duplicates already loaded Spoons if the global namespace is used
- Before, mem usage after `14:56` hours of uptime was `77mb`.
- After update, mem usage hasn't climbed above `43.0mb`

### `21-04-06`

- Newer version of hammerspoon use far more memory than older versions without anything significant changing with my config.
- Reverted to `0.9.82` and memory usage went down from `~450mb` (after a minute or two of usage) to a consistent `~150mb`.

## Next Steps

### Tasks

- Update and check `hs.crash.residentSize()`
- On `0.9.82`, it's `118943744` after a few minutes of use
  - Activity Monitor Mem Stats:
    - Real Mem Size: `114.3 MB`
    - Virt Mem Size: `5.23 GB`
    -
- Update and run `hs.crash.attemptMemoryRelease()` and see if memory usage drops significantly
- Verify that nothing unexpected is being loaded/required (WIP Spoons, undocumented modules, etc.)
