local TablePlus = {}
TablePlus.__index = TablePlus

-- Transitional: databases now open in Tables (Apps/Tables.lua); this only
-- keeps in-app TablePlus shortcuts working until it's dropped entirely.

function TablePlus.closeWindow()
    hs.osascript.applescript([[
        tell application "System Events"
            tell process "TablePlus"
                click menu item "Close" of menu "File" of menu bar 1
            end tell
        end tell
    ]])
end

return TablePlus
