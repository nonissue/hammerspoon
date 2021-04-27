# screenWatcher (Just a collection of code comments)

Cinema Display Name: "Cinema HD" Cinema Display ID: 69489838

Issues: affinity designer triggers screen change? gets called multiple times as sometimes add multiple displays if called multiple times, our conditional logic is broken? figure out how to batch the updates?

display contexts: @desk: _cinema display detected_ wifi: home _display count: 1-3_ actions: _entry: moveDockDown() audioOn() applyLayouts?_ exit:

```
@duet:
    * display count: 2
    * wifi: any
    * ipad display detected?
    * actions:spo
@else:
    * display count: 1
    * wifi: any
```

settings to apply based on context: screen lock time volume dock position default app layouts

--------------------------------------------------------------------------------

## Location based functions to change system settings

functions for different locations configure things like drive mounts, display sleep (for security), etc. sets displaysleep to 90 minutes if at home should be called based on ssid not the most secure since someone could fake ssid I guess might want some other level of verification-- makes new window from current tab in safari could maybe send it to next monitor immediately if there is one? differentiate between settings for laptop vs desktop Mostly lifted from: <https://github.com/cmsj/hammerspoon-config/blob/master/init.lua>

--------------------------------------------------------------------------------

Don't love the logic of how this is implemented If computer is in between networks (say, woken from sleep in new location) Then desired settings like volume mute are not applied until after a delay Maybe implement a default setting that is applied when computer is 'in limbo' Move to env variable / .env?

--[[

=========================================================== SystemContexts Spoon

--------------------------------------------------------------------------------

Set and manage system defaults. Handle and manage config options as user env changes. e.g. _Sleep settings at school vs home_ When using multiple monitors, diff res choices * Autoconfig layout for mobile vs at desk. Things like dock position, display arrangement, etc.

--------------------------------------------------------------------------------

todo:

- make this whole thing a proper state machine!

- invoke do not disturb on when not at home

- store state in an object?

  - eg:

    - state.location

      - vals: home, school, other

    - state.docked

  Outline of:

  - Properties to init
  - How it's computed
  - Effect of properties

  - Docked: Bool

    - Computed from:

      - number of screens
      - names of displays
      - name of SSID

    - Effect:

      - dock position
      - provide correct 'changeres' options
      - set window layout?

  - Location

]]
