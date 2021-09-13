# a hammerspoon config [![Codacy Badge](https://app.codacy.com/project/badge/Grade/4a20bdc0897f4991a8697d4b4a467da5)](https://www.codacy.com/gh/nonissue/hammerspoon/dashboard?utm_source=github.com&utm_medium=referral&utm_content=nonissue/hammerspoon&utm_campaign=Badge_Grade)

![stars](https://img.shields.io/github/stars/nonissue/hammerspoon?style=for-the-badge) ![license](https://img.shields.io/github/license/nonissue/hammerspoon?style=for-the-badge)

## Custom Spoons

My custom spoons can be found in the `_Spoons` directory. They aren't really designed to be plug and play, there is often some manually configuration required, but the code is generally documented / relatively simple. Let me know if you have issues / questions / wish for me to officially publish any of them.

### Clippy.spoon

This is only useful if you want to have screenshots both saved to disk and copied to your clipboard automatically. My default, macOS only does one or the other. To use `Clippy.spoon` configure macOS to save screenshots to disk and set the path to the screenshots (by default, `~/Desktop`) in `Clippy.spoon`. It then watches this directory for screenshots, and when new ones are added, automatically copies them to the clipboard.

### Context.spoon

Kind of skunkworks at the moment, you can safely ignore it.

### CTRLESC.spoon

Rebinds caps lock to `ESC` when pressed alone, and when pressed in combination with other keys, acts as `CTRL` modifier. Eg. `CapsLock + C` sends `CTRL + C`.

### EasyTOTP.spoon

Adds menubar icon that with a click types a TOTP token and copies it to clipboard.

### Fenestra.spoon

My window management solution. Features `undo`!

### Resolute.spoon

Utility for changing resolution scaling on MBP retina displays. Only tested on my 15" MBP.

### ZZZ.spoon

macOS menubar sleep timer. Puts mac to sleep after `XXm`. Shows countdown in menubar, and you can `snooze` using menubar icon.
