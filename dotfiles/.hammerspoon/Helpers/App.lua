local App = {}
App.__index = App

App.bundles = {
    anybox = 'cc.anybox.Anybox',
    calendar = 'com.busymac.busycal-setapp',
    chrome = 'com.google.Chrome',
    dash = 'com.kapeli.dashdoc',
    discord = 'com.hnc.Discord',
    finder = 'com.apple.finder',
    linear = 'com.linear',
    mailspring = 'com.mailspring.mailspring',
    mimestream = 'com.mimestream.Mimestream',
    obsidian = 'md.obsidian',
    postman = 'com.postmanlabs.mac',
    preview = 'com.apple.Preview',
    rayapp = 'be.spatie.ray',
    sideNotes = 'com.apptorium.SideNotes-setapp',
    slack = 'com.tinyspeck.slackmacgap',
    spotify = 'com.spotify.client',
    tableplus = 'com.tinyapp.TablePlus-setapp',
    tinkerwell = 'de.beyondco.tinkerwell',
    transmit = 'com.panic.Transmit',
    vivaldi = 'com.vivaldi.Vivaldi',
    vscode = 'com.microsoft.VSCode',
    warp = 'dev.warp.Warp-Stable',
    windsurf = 'com.exafunction.windsurf',
    youtubeMusic = 'com.google.Chrome.app.cinhimbnkkaeohfgghhklpknlkffjgod',
    zoom = 'us.zoom.xos',
    teams = 'com.microsoft.teams2',
    outlook = 'com.microsoft.Outlook',
    mail = {
        'mailspring',
        'outlook',
        'mimestream',
    },
    browsers = {
        'chrome',
        'vivaldi',
    },
    tasks = {
        'linear',
    },
    teamMessaging = {
        'teams',
    },
}

App.fromAlias = function(alias)
    local bundles = alias

    if is.String(alias) then
        bundles = App.bundles[alias]
    end

    bundles = hs.fnutils.map(bundles, function(bundle)
        return App.bundles[bundle] or bundle
    end)

    return hs.fnutils.filter(bundles, function(bundle)
        return hs.application.nameForBundleID(bundle) ~= nil
    end)
end

function App.codeEditor()
    return App.includes({vscode, tinkerwell, windsurf})
end

function App.is(bundle)
    return hs.application.frontmostApplication():bundleID() == bundle
end

function App.includes(bundles)
    return fn.table.has(bundles, hs.application.frontmostApplication():bundleID())
end

function App.loadBundleVariables()
    fn.each(App.bundles, function(bundle, key)
        _G[key] = bundle
    end)
end

function App.hasWindows(app)
    return App.windowCount(app) > 0
end

function App.multipleWindows(app)
    return App.windowCount(app) > 1
end

function App.windowCount(app)
    if app == nil then return 0 end

    local count = 0

    for k, v in pairs(app:visibleWindows()) do
        if (is.In(preview) or is.finder()) and v:title() == '' then
        else
            count = count + 1
        end
    end

    return count
end

return App
