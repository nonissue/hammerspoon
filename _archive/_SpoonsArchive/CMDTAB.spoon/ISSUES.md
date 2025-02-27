# ISSUES

- [ ] Code/Logic is pure spaghetti. Fix it.
- [ ] Very quickly command-tabbing to an app doesn't open a new window, there seems to be a delay some how.
  - [ ] Looks like because some of our logic is monitoring KEY UP events, which causes the delay
  - [ ] Changing this handler to watch KEY DOWN events resolves the initial problem, but I'm not sure if it introduces any others
