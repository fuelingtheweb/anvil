info 'Confirm Tap to Click is working.'
open -a 'System Preferences.app'
info '- Trackpad -> Point & Click: Enable Tap to click'
pause

info '- Add Google Internet account.'
info '- Remove iCloud syncing.'
pause

info 'Install and setup Setapp.'
pause

info 'Install Mac Apps.'
info 'Sign into the app store to attempt automatic install.'
open -a 'App Store.app'
pause

info 'Attempting to install apps from the Mac App Store.'
source $src/mas.sh
mas list

copyLicense 'alfred'
open -a 'Alfred 4.app'
info 'Register Alfred and sync settings. License copied.'
info 'Manually set additional settings if required:'
info '- General -> Alfred Hotkey: Option+Z'
info '- Features -> Default Results -> Search Scope: Uncheck both options and empty folder list.'
info '- Features -> Web Bookmarks: Google Chrome Bookmarks'
info '- Features -> Clipboard History: Keep Plain Text, Images, and File Lists'
info '- Features -> Snippets: Automatically expand snippets by keyword'
info '- Appearance: Select FTW Material Dark'
pause

source $custom/step-three-apps.sh

success 'Running Mackup Restore.'
mackup restore

success 'Linking custom dotfiles.'
ln -sf $ANVIL/custom/gitconfig $HOME/.gitconfig

info 'Open Cursorcerer'
open $HOME/Library/PreferencePanes/Cursorcerer.prefPane
pause

info 'Open Code.'
open -a 'Visual Studio Code.app'
pause

info 'Install Homerow: https://homerow.app/'
open https://homerow.com/
pause

info 'Open Homerow'
open -a 'Homerow.app'
pause

info 'Update Preferences: System.'
open -a 'System Preferences.app'
info '- Trackpad -> Scroll & Zoom: Disable Scroll direction: Natural'
info '- Trackpad -> Point & Click: Enable Tap to click'
info '- Trackpad -> Point & Click: Increase Tracking speed to 70%%'
info '- Accessibility -> Pointer Control -> Mouse & Trackpad -> Trackpad Options...: Enable Dragging'
info '- Accessibility -> Display: Reduce transparency'
info '- Keyboard -> Input Sources: Disable show input menu in menu bar'
info '- Keyboard -> Touch Bar shows: Expanded Control Strip'
info '- Keyboard: Remove Siri from touch bar'
info '- Displays: Disable show mirroring options in menu bar when available'
info '- Desktop & Screen Saver: Select wallpaper'
info '- Users & Groups -> Login Items: Add Vimac'
info '- Users & Groups -> Login Items: Add EnableMouseKeys'
info '- Dock & Menu Bar -> Battery: Show Percentage'
info '- Dock & Menu Bar -> Clock: Disable Show the day of the week'
info '- Dock & Menu Bar -> Clock: Disable Show date'
info '- Remove widgets.'
info '- Sound -> Sound Effects: Disable Play sound on startup'
info '- Sound -> Sound Effects: Disable Play user interface sound effects'
info '- Update Finder Settings: Sidebar, View options, Toolbar'
pause

info 'Open Bartender'
open -a 'Bartender 4.app'
info '- Always show: Wi-Fi, Battery, Clock, Busycal'
info '- Show: Location Menu'
info '- Always hide: Notification Center, Spotlight'
info '- Hide: Time Machine, Homerow, Dropbox'
pause

copyLicense 'tinkerwell'
open -a 'Tinkerwell.app'
info 'Register Tinkerwell. License copied.'
pause

copyLicense 'ray'
open -a 'Ray.app'
info 'Register Ray. License copied.'
pause

info 'Add other licenses.'
pause

info 'Open Vivaldi and update settings.'
pause
