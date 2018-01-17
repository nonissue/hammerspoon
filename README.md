# Hammerspoon .dotfiles

This is super messy, intend to clean it up and improve commenting soon
Comments/questions can be sent to hammerspoon [at] nonissue.org

## Functions:

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

## Todo

### 17/12/21

* This is cool: 
  https://github.com/ashfinal/awesome-hammerspoon#search-something---g

* [ ] Tests?
  * https://github.com/heptal/dotfiles/blob/master/roles/hammerspoon/files/hsluatests.lua
* [x] Laptop resolution changing
* [x] Battery alerts on laptop *kind* *of* see burnrate plugin
* [x] Change settings based on location (wifi ssid?)
* [ ] Better display of resolution options (ala hs.hints)
  * Don't really use this functionality anymore, so can probably
    safely delete this item
* [ ] grab active url from safari, send to clipboard?
  * Done-ish. Currently mails to self.
  * [ ] site-specific search from current url
* [ ] move other modules from init to plugins
  * [ ] window management
  * [ ] safari stuff
  * [ ] application management?
* [x] KIRBY SHRUG ¯\_(ツ)_/¯
* [ ] !!
* [ ] Connect to airpods?
* [ ] Disconnect from airpods?
* [ ] Bind alert styles in a function so i don't have to keep repeating things
* [ ] Combine multiple functions into one menubar app
  * [ ] Display res / 

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
