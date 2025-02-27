# TO FUTURE ME

Screenshots have to be in `.png` format for this to work.
The path the Spoon monitors is also hardcoded in the Spoon. It should be moved to a global HS var.
The Spoon monitors files that have names starting with "apw". This is hardcoded in the Spoon and means the devices hostname must be changed manually.


## TODO

- [ ] implement some kind of context variables
  - [ ] a UI for configuring them would be A++
  - [ ] Could use the UI in a ton of my spoons.
  - [ ] Variables:
    - Screenshot prefix
    - Screenshot file type
    - Screenshot dir
    - Screenshot disable preview
- [ ] Verify somehow that appropriate macOS `defaults` have been applied? 
  - [ ] `hs.host` exists so we can check the hostname