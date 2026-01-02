local DismissNotifications = {}
DismissNotifications.__index = DismissNotifications

function DismissNotifications.run()
    hs.osascript.applescript([[
        tell application "System Events"
            tell process "NotificationCenter"
                if not (exists window "Notification Center") then return
                tell window "Notification Center"
                    set elems to entire contents

                    -- First try: Clear All on stack
                    repeat with e in elems
                        try
                            if (role of e) is "AXGroup" and (subrole of e) is "AXNotificationCenterAlertStack" then
                                set axactions to name of every action of e
                                repeat with aName in axactions
                                    set aNameStr to aName as text
                                    if aNameStr starts with "Name:Clear All" then
                                        perform (first action of e whose name is aNameStr)
                                        return
                                    end if
                                end repeat
                            end if
                        end try
                    end repeat

                    -- Fallback: Close on single alert
                    repeat with e in elems
                        try
                            if (role of e) is "AXGroup" and (subrole of e) is "AXNotificationCenterAlert" then
                                set axactions to name of every action of e
                                repeat with aName in axactions
                                    set aNameStr to aName as text
                                    if aNameStr starts with "Name:Close" then
                                        perform (first action of e whose name is aNameStr)
                                        return
                                    end if
                                end repeat
                            end if
                        end try
                    end repeat

                end tell
            end tell
        end tell
    ]])
end

return DismissNotifications
