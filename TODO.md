# TODO

Updated: 19-04-24

## Lua / Meta

### Error Catching

```lua
    -- https://www.lua.org/pil/8.4.html
    -- returns false when normally HS will crash
        function test()
            if zzz == nil then
                error()
            end
            print(zzz .. "hi")
        end

        pcall(test)
```

## Next

- BEFORE ANYTHING ELSE:
  - [ ] Upload images somewhere... https://github.com/heptal/dotfiles/blob/master/roles/hammerspoon/files/imgur.lua
  - [ ] Use hs.watchable for Context spoon
  - [ ] use try catch? https://github.com/matthewfallshaw/hammerspoon-config/blob/e038e30f649383cd9f6e3711c52ed1ac2d826f78/utilities/try_catch.lua
  - [ ] Write docs for spoons
    - [ ] Fenestra
    - [ ] AfterDark
    - [~] Context
    - [ ] PaywallBuster
    - [ ] Zzz
    - [ ] Resolute
    - [ ] CTRLESC
    - [ ] SafariKeys
  - [ ] Set spoon hotkeys properly (like Fenestra does?)
    - [x] Resolute
    - [x] Fenestra
    - [x] Zzz
    - [x] SafariKeys
    - [ ] PaywallBuster
  - [ ] Improve config reload time
  - [ ] Create menubar spoon that controls config of other spoons
  - [ ] REMOVE ANY UTILITIES OR FUNCTIONS SPECIFIC TO MY CONFIG
  - [~] test spoons on empty config
  - [ ] remove any styled text as it may cause mem leaks
  - SUBMIT THEM
  - [ ] use key/value store for configurable variables/defaults
    - [ ] screen resolutions
    - [x] Drives to eject
    - [x] wifi ssid
- [ ] Fuck, just found hs.fnutils, can replace a lot of my janky custom methods

### Changes/Fixes

- [ ] gen proper docs for my spoons (PaywallBuster, SafariKeys, SystemContexts, Zzz)

### Features

- [ ] Customizable cheat-sheet-style plugin
  - cheat-sheets for
    - [ ] tmux
    - [ ] vim
    - [ ] my hammerspoon
- [ ] resolve caps-lock issue with [this](https://gist.github.com/townewgokgok/f2161047b790a2984e438471f383010e)
- [ ] Genericize timer spoon, let it be used for multiple things (alerts, screen wake)
  - Inspiration: <https://github.com/scottcs/dot_hammerspoon/blob/master/.hammerspoon/modules/timer.lua>

## Future

### Misc

- [ ] marquee/animated ticker with updates in menubar
- [ ] Spoon: App context switcher (using chooser)?
  - eg. 'hammerspoon' -> opens hammerspoon console, opens vscode with hammerspoon project open
    - eg. 'scratch.js' -> opens javascript sandbox?

### Finished

- [x] migrate remaining plugins to spoons
- [x] implement better reloading? may be a spoon already for this
- [x] finish implementing Resolute
- [x] finish inc/dec in Zzz
- [x] proper window management (like [this](https://github.com/binesiyu/hammerspoon/blob/c47456e6d1eef0b161fe6784cab9a648eab83b51/ws.lua))
- [x] remove init-plugins and apw-lib
- [x] SPEED UP RELOAD

### Discontinued

- [A] update Zzz so it can do the opposite (keep computer awake for a certain amount of time)
- [A] Use menubar hotkey options for simple ideas? (not possible?)
- [A] Make them proper git submodules / EDIT: git submodules suck
- [A] quickreference notes chooser (with things like server details, etc)
- [A] Safari: move all tabs after current tab to new window
  - [A] this is slow, but works: <https://stackoverflow.com/questions/54066100/applescript-to-split-safari-tabs-into-new-window>
- [A] current weather? Don't really care about this
