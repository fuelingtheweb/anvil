local Secondary = {}
Secondary.__index = Secondary

Secondary.lookup = {
    tab = cm.Search.tabs,
    q = 'toggleAppKeybindWindow',
    w = nil,
    e = 'espansoSearch',
    r = 'reloadSecondary',
    t = nil,
    caps_lock = nil,
    a = nil,
    s = 'spotifyMini',
    -- d = 'dash',
    d = 'toggleDockVisibility',
    f = nil,
    g = nil,
    left_shift = 'dismissAppNotifications',
    z = fn.Alfred.sleep,
    x = fn.Alfred.emptyTrash,
    c = nil,
    v = 'searchBartender',
    b = 'showBartender',
    spacebar = nil,
}

function Secondary.spotifyMini()
    fn.Alfred.run('spot_mini', 'com.vdesabou.spotify.mini.player')
end

function Secondary.dismissAppNotifications()
    ks.alt('w')
end

function Secondary.showBartender()
    ks.shiftCtrlAlt('b')
end

function Secondary.searchBartender()
    ks.shiftCtrlAlt('v')
end

function Secondary.toggleDockVisibility()
    ks.altCmd('d')
end

function Secondary.reloadSecondary()
    if is.chrome() then
        -- Hard refresh
        ks.shiftCmd('r')
    elseif is.terminal() then
        -- Reload running command
        ks.ctrl('c').up().enter()
    end
end

function Secondary.espansoSearch()
    ks.shiftAlt('space')
end

function Secondary.toggleAppKeybindWindow()
    if is.chrome() then
        ks.shift('/')
    elseif is.vscode() then
        -- Preferences: Open Keyboard Shortcuts
        ks.cmd('k').cmd('s')
    elseif is.chat() then
        ks.cmd('/')
    end
end

function Secondary.dash()
    hs.application.launchOrFocusByBundleID(dash)
end

return Secondary
