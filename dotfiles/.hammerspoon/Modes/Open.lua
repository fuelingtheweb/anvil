local Open = {}
Open.__index = Open

Modal.loadCustom('Frequent')
Modal.loadCustom('Bookmarks.Index')
Modal.load('OpenIn')

Open.lookup = {
    tab = 'Ray.app',
    r = 'cursor',
    w = 'openInModal',
    e = 'mail',
    q = 'tinkerwell',
    t = 'warp',
    caps_lock = 'vscode',
    a = 'openAppModal',
    s = 'teamMessaging',
    d = 'discord',
    f = 'openFrequentModal',
    g = 'vivaldi',
    left_shift = 'tasks',
    z = 'zoom',
    x = 'finder',
    c = 'calendar',
    v = 'tableplus',
    -- b = 'openBookmarksModal',
    b = 'outlook',
    spacebar = 'miniCalendar',
}

Modal.add({
    key = 'OpenApp',
    title = 'Open App',
    items = {
        -- qwer
        t = {name = 'Transmit', app = 'Transmit.app'},
        -- yu
        i = {name = 'Invoker', app = 'invoker'},
        -- o
        p = {name = 'System Preferences', app = 'System Preferences.app'},
        a = {name = 'Alfred Preferences', app = 'alfredPreferences'},
        s = {name = 'Spotify', app = 'spotify'},
        d = {name = 'Dash', app = 'Dash.app'},
        -- fg
        h = {name = 'Helo', app = 'de.beyondco.helo'},
        -- j
        k = {name = 'Kaleidoscope', app = 'Kaleidoscope.app'},
        -- lzxcvbn
        b = {name = 'Anybox', app = 'Anybox.app'},
        m = {name = 'reMarkable', app = 'reMarkable.app'},
    },
    callback = function(item)
        Modal.exit()
        Open.fallback(item.app)
    end,
})

-- hs.hints.titleMaxSize = 20
hs.hints.showTitleThresh = 20
hs.hints.fontSize = 20
hs.hints.iconAlpha = 1
hs.hints.style = nil

function Open.windowHintsForCurrentApplication()
    hs.hints.style = nil
    hs.hints.windowHints(
        hs.window.focusedWindow():application():allWindows(),
        function(window)
            cm.Window.centerMouseOnScreen(window:screen())
        end
    )
end

function Open.windowHints()
    hs.hints.style = 'vimperator'
    hs.hints.windowHints()
end

function Open.miniCalendar()
    ks.ctrlCmd('b')
end

function Open.alfredPreferences()
    hs.application.open('com.runningwithcrayons.Alfred-Preferences')
end

function Open.quit()
    md.Command.quit()
end

function Open.closeAllWindow()
    md.Command.closeAllWindow()
end

function Open.open()
    md.Hyper.open()
end

function Open.bringAllWindowsToFront()
    hs.application.frontmostApplication():activate(true)
end

function Open.fallback(value, key)
    if Open[value] then
        Open[value]()
    elseif str.contains('.app', value) then
        hs.execute("open -a '" .. value .. "'")
    else
        Open.launchApp(value)
    end

    cm.Window.centerMouseOnScreen(cm.Window.current():screen())
end

function Open.launchApp(id)
    local bundle = fn.app.bundles[id]

    if not bundle then
        bundle = id
        -- return hs.application.open(id)
    end

    local app = hs.application.frontmostApplication()

    if is.Table(bundle) then
        local isActive = false
        local opened = false
        local bundles = fn.app.fromAlias(bundle)

        fn.each(bundles, function(b)
            if isActive then
                opened = true

                return Open.launchApp(b)
            elseif app:bundleID() == b then
                isActive = true
            end
        end)

        if not opened then
            Open.launchApp(bundles[1])
        end

        return
    end

    local isActive = app:bundleID() == bundle

    if not isActive then
        local app = hs.application.get(bundle)

        if not fn.app.hasWindows(app) then
            app = hs.application.open(bundle)

            if app then
                app:activate()
            end
        else
            if fn.app.multipleWindows(app) then
                cm.Window.focusFirst(
                    cm.Window.filtered(cm.Window.currentScreen(), app),
                    app
                )
            else
                app:activate()

                if id == 'finder' and not fn.app.multipleWindows(app) then
                    hs.application.open(bundle)
                end
            end
        end
    elseif fn.app.multipleWindows(app) or isActive then
        Open.windowHintsForCurrentApplication()
    elseif not fn.app.hasWindows(app) then
        hs.application.open(bundle)
    end

    currentWindow = cm.Window.current()

    if (currentWindow) then
        cm.Window.centerMouseOnScreen(currentWindow:screen())
    end
end

function Open.music()
    Open.youtubeMusic()
end

function Open.youtubeMusic()
    local app = hs.application.get(youtubeMusic)

    if not fn.app.hasWindows(app) then
        hs.application.open(youtubeMusic)
    else
        app:activate()
    end

    cm.Window.centerMouseOnScreen(cm.Window.current():screen())
end

function Open.spotify()
    if is.In(spotify) then
        return cm.Window.next()
    end

    app = hs.application.get(spotify)

    if app and app:isRunning() then
        app:activate()
    else
        hs.execute('open -a "Spotify.app" https://open.spotify.com/playlist/40NEwyReWKPx4QaMNmZ6HS?si=ee74d9e6ccfd44dd')
    end

    cm.Window.centerMouseOnScreen(cm.Window.current():screen())
end

function Open.openAppModal()
    Modal.enter('OpenApp')
end

function Open.openFrequentModal()
    Modal.enter('OpenFrequent')
end

function Open.openBookmarksModal()
    Modal.enter('OpenBookmarks')
end

function Open.openInModal()
    Modal.enter('OpenIn')
end

return Open
