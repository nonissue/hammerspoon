# Miscellaneous Notes on Hammerspoon and this configuration for Hammerspoon

## Hammerspoon Quirks

### hs.osascript + Reminders.app + Permissions

In order to allow AppleScript via Hammerspoon to access Apple Reminders/Contacts/Calendar, we need to perform a work around.

Doing something like the following:

```lua
local _, _, test = hs.osascript._osascript(
                    'tell application "Reminders" to return properties of lists',
                    "AppleScript")
print_r(test)
```

Will just return 'false' and `nil`. The first time you try to access Reminder's data in this fashion, a prompt does appear that seemingly allows you to grant Hammerspoon the requisite access via macOS. However, the above script continues to fail and Hammerspoon is not listed in the Reminders panel of Security & Privacy's Privacy tab.

The fix is to run the following (at least once):

```lua
hs.execute('osascript -e \'tell application "Reminders" to return default account\'')
```

It's strange because Hammerspoon is _still_ not listed in the Reminders panel in Security and _Privacy. However_, it is listed in Automation. The Hammerspoon object now has two listed permissions: System Events.app and Reminders.app. Weird.

Repeat as needed for each app.
