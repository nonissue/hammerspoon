
# OUTDATED DOCS For Reference

## QUICK OVERVIEW

* OVERALL: THIS IS NOT STABLE
  * Feel free to grab ideas / copy code, but there's a lot of cruft
  * things change all the time
  * things may break
* init.lua -> main init
* apw-lib.lua, init-plugins.lua ->
  * before spoons existed, I copied the plugin system from oh-my-hammerspoon. 
  * these files largely handle that
  * I also now use spoons
* spoons -> spoons i've written (SafariKeys, SystemContexts, PaywallBuster) and some I didn't
  * mostly a work in progress, probably stay away from using any of these
  * SafariKeys -> Hotkeys for common tasks I want to do in safari
    * Change user agent
    * Merge all windows
    * Pull tab to new window
    * mail current page to self
  * SystemContexts -> not finished
  * PaywallBuster -> a modal plugin that provides a variety of options for skirting paywalls
    * Currently takes the frontmost URL in safari
      * Uses:
        * Facebook outlinking
        * Google Cache
        * Wayback machine
* plugins -> aforementioned custom plugins for custom plugin system (deprecated)

## Functions

### Window resizing/movement

* Resizes windows (fullscreen/halfscreen/75/25)
* Throws windows between monitors if there are two

### Resolution modification

* Can set resolution using modal hotkey
* Currently, possible resolutions are passed in manually from table of tables
* Creates a menubar item that displays current resolution width and when clicked, toggles between two most common for me to use

### Mail-to-self

* Hotkey bound to mail current Safari url to my email
* I use it for reading stuff later

### Pull current tab from safari

* Pulls current tab from safari and creates a new window with it

### User agent toggle

* Toggles user agent for safari for iOS dev
* Stolen from hammerspoon intro
* Modified to switch between default and iPad

## Outdated Todo List

### 17/12/21

* This is cool: 
  https://github.com/ashfinal/awesome-hammerspoon#search-something---g

* [ ] Tests?
  * https://github.com/heptal/dotfiles/blob/master/roles/hammerspoon/files/hsluatests.lua
* [x] Laptop resolution changing
* [x] Battery alerts on laptop *kind* *of* see burnrate plugin
* [x] Change settings based on location (wifi ssid?)
* [x] Better display of resolution options (ala hs.hints)
  * Don't really use this functionality anymore, so can probably
    safely delete this item
* [x] grab active url from safari, send to clipboard?
  * Done-ish. Currently mails to self.
  * [ ] site-specific search from current url
* [ ] move other modules from init to plugins
  * [ ] window management
  * [x] safari stuff
  * [ ] application management?
* [x] KIRBY SHRUG ¯\_(ツ)_/¯
* [x] Bind alert styles in a function so i don't have to keep repeating things
* [x] Combine multiple functions into one menubar app
  * [x] Display res /

* [ ] Make specific system functions into modal hotkeys
  * Some ideas:
    * [ ] DND on/off
    * [ ] Bluetooth on/off
    * [ ] Bluetooth connect specific headphones
    * [ ] VPN on/off
    * [ ] Nightshift/flux on/off
    * [x] Sleep timer (possibly need to break this out to own module)
* [ ] Make a display (similar to hs.hints) for these system hotkeys
  * [ ] Or maybe something similar to cheatsheets?