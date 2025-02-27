# Paywall Buster

Uses hacky workarounds to view paywalled articles and content online.
Add the `PaywallBuster.spoon` folder to your `.hammerspoon/Spoons` directory and 
add the following code to your Hammerspoon `init.lua` file:

```lua
hs.loadSpoon("PaywallBuster")
hs.hotkey.bind(
    mash,
    "B",
    function()
        spoon.PaywallBuster:show()
    end
)
```