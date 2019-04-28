# TODO

Updated: 19-04-24

## Next

* BEFORE ANYTHING ELSE:
  * [ ] Write docs for spoons
  * ~~[ ] Make them proper git submodules~~ EDIT: gitsubmodules suck
  * [ ] Clean them up if necessary
  * [ ] REMOVE ANY UTILITIES OR FUNCTIONS SPECIFIC TO MY CONFIG
  * [ ] add spoon loader spoon and hammerspoon config k/v store
  * [ ] test spoons on empty config
  * [ ] remove any styledtext as it may cause mem leaks
  * SUBMIT THEM
  * [ ] use key/value store for configurable variables/defaults
  	* [ ] screen resolutions
	* [ ] wifi ssid
	* [ ] ...


### Changes/Fixes

* [ ] move hotkey binding from spoons to main init!
* [ ] gen proper docs for my spoons (PaywallBuster, SafariKeys, SystemContexts, Zzz)
* [ ] TESTING

### Features

* [ ] Customizable cheatsheet-esque plugin
    * cheatsheets for
        * [ ] tmux
        * [ ] vim
        * [ ] myhammerspoon
* [ ] resolve capslock issue with [this](https://gist.github.com/townewgokgok/f2161047b790a2984e438471f383010e)
* [ ] genericize timer spoon, let it be used for multiple things (alerts, screen wake)
  * Inspiration: https://github.com/scottcs/dot_hammerspoon/blob/master/.hammerspoon/modules/timer.lua

## Future

### Misc

* [ ] chooser to start/stop spoons, with persistence? (++)
* [ ] marquee/animated ticker with updates in menubar
* [ ] current weather?
* [ ] Spoon: App context switcher (using chooser)?
    * eg. 'hammerspoon' -> opens hammerspoon console, opens vscode with hammerspoon project open
    * eg. 'scratchjs' -> opens javascript sandbox?
* [ ] make all menubarlets enable/disableable through the same interface (chooser?)

### Finished

* [x] migrate remaining plugins to spoons
* [x] implement better reloading? may be a spoon already for this
* [x] finish implementing Resolute
* [x] finish inc/dec in Zzz
* [x] proper window management (like [this](https://github.com/binesiyu/hammerspoon/blob/c47456e6d1eef0b161fe6784cab9a648eab83b51/ws.lua))
* [x] remove init-plugins and apw-lib
* [x] SPEED UP RELOAD

### Discontinued

* [A] update Zzz so it can do the opposte (keep computer awale for a certain amount of time)
* [A] Use menubar hotkey options for simple ideas? (not possible?)
