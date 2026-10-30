local Search = {}
Search.__index = Search

function Search.symbol()
    ks.cmd('r')
end

-- Files and folders by name, in Spark.
function Search.files()
    fn.Spark.files()
end

function Search.google()
    fn.Spark.search('g ')
    -- fn.Alfred.run('google', 'com.akikoz.alfred.websearchsuggest')
end

function Search.amazon()
    fn.Spark.search('amz ')
end

-- Spark with its web searches listed (Alfred's `search:` was here).
function Search.searches()
    fn.Spark.search('search ')
end

function Search.default()
    if is.codeEditor() then
        ks.key('/')
    end
end

function Search.windowsInCurrentApp()
    windows = hs.window.filter
        .new({hs.application.frontmostApplication():name()})
        :getWindows(hs.window.filter.sortByFocusedLast)

    Search.loadWindowsInAlfred(windows, 2)
end

function Search.loadWindowsInAlfred(windows, minimum)
    if not windows or fn.table.count(windows) < minimum then
        return
    end

    local items = {}
    fn.each(windows, function(window)
        local app = window:application()
        local iconPath = home_path .. '/Dev/Anvil/custom/' .. app:name() .. '.png'
        hs.image.imageFromAppBundle(app:bundleID()):saveToFile(iconPath)
        table.insert(items, {
            uid = window:id(),
            title = window:title(),
            match = app:name() .. ' ' .. window:title(),
            arg = window:id(),
            icon = {path = iconPath},
        })
    end)

    hs.json.write({items = items}, home_path .. '/Dev/Anvil/custom/windows.json', false, true)

    fn.Alfred.run('windows', 'com.fuelingtheweb.commands')
end

function Search.allWindows()
    -- Spark's Switch Windows: ⌥Tab again moves down the list.
    ks.alt('tab')
    -- local windows = hs.window.filter.default:getWindows(hs.window.filter.sortByFocusedLast)

    -- Search.loadWindowsInAlfred(windows, 1)
end

function Search.window()
    if is.codeEditor() then
        ks.shiftCmd('f')
    else
        ks.cmd('f')
    end
end

function Search.tabs()
    if is.codeEditor() then
        ks.shiftAltCmd('tab')
    end
end

hs.urlevent.bind('window-focus', function(eventName, params)
    hs.window(tonumber(params.id)):focus()
end)

return Search
