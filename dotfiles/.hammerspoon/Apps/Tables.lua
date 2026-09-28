local Tables = {}
Tables.__index = Tables

-- Opens a connection link (mysql://root@127.0.0.1/app?name=App) in Tables
-- (com.tidypoint.Tables) via tables://open?url=…: it reuses the saved
-- connection to that server and switches to the link's database. With no
-- link, just brings Tables forward.
function Tables.open(url)
    if not url then
        hs.application.launchOrFocusByBundleID(tables)
        return
    end

    local encoded = url:gsub('[^%w%-%._~]', function(char)
        return string.format('%%%02X', string.byte(char))
    end)
    hs.execute('open "tables://open?url=' .. encoded .. '"')
end

return Tables
