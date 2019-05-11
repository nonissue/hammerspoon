# TODO

Updated: 19-04-24

## Next

* BEFORE ANYTHING ELSE:
  * [ ] Write docs for spoons
  * ~~[ ] Make them proper git submodules~~ EDIT: git submodules suck
  * [ ] Clean them up if necessary
  * [ ] REMOVE ANY UTILITIES OR FUNCTIONS SPECIFIC TO MY CONFIG
  * [ ] add spoon loader spoon and hammerspoon config k/v store
  * [ ] test spoons on empty config
  * [ ] remove any styled text as it may cause mem leaks
  * SUBMIT THEM
  * [ ] use key/value store for configurable variables/defaults
    * [ ] screen resolutions
    * [ ] wifi ssid
    * [ ] ...
* [ ] Fuck, just found hs.fnutils, can replace a lot of my janky custom methods

### Changes/Fixes

* [ ] move hotkey binding from spoons to main init!
* [ ] gen proper docs for my spoons (PaywallBuster, SafariKeys, SystemContexts, Zzz)
* [ ] TESTING

### Features

* [ ] Customizable cheat-sheet-style plugin
  * cheat-sheets for
    * [ ] tmux
    * [ ] vim
    * [ ] my hammerspoon
* [ ] resolve caps-lock issue with [this](https://gist.github.com/townewgokgok/f2161047b790a2984e438471f383010e)
* [ ] Genericize timer spoon, let it be used for multiple things (alerts, screen wake)
  * Inspiration: <https://github.com/scottcs/dot_hammerspoon/blob/master/.hammerspoon/modules/timer.lua>

## Future

### Misc

* [ ] chooser to start/stop spoons, with persistence? (++)
* [ ] marquee/animated ticker with updates in menubar
* ~~[ ] current weather?~~ Don't really care about this
* [ ] Spoon: App context switcher (using chooser)?
  * eg. 'hammerspoon' -> opens hammerspoon console, opens vscode with hammerspoon project open
    * eg. 'scratch.js' -> opens javascript sandbox?
* [ ] make all menubar-lets enable/disable through the same interface (chooser / hs.settings)
* [ ] Safari: move all tabs after current tab to new window
  * [ ] this is slow, but works: <https://stackoverflow.com/questions/54066100/applescript-to-split-safari-tabs-into-new-window>

### Finished

* [x] migrate remaining plugins to spoons
* [x] implement better reloading? may be a spoon already for this
* [x] finish implementing Resolute
* [x] finish inc/dec in Zzz
* [x] proper window management (like [this](https://github.com/binesiyu/hammerspoon/blob/c47456e6d1eef0b161fe6784cab9a648eab83b51/ws.lua))
* [x] remove init-plugins and apw-lib
* [x] SPEED UP RELOAD

### Discontinued

* [A] update Zzz so it can do the opposite (keep computer awake for a certain amount of time)
* [A] Use menubar hotkey options for simple ideas? (not possible?)
