local App = {}
App.__index = App

-- Default code editor: "cursor" or "vscode"
App.defaultEditor = "vscode"

-- Every app and group by name, from Anvil's config/apps.yml (`kb` builds
-- config/apps.lua): the same names simlayers.yml uses. Edit apps.yml.
App.bundles = require('config.apps')

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
    return App.includes({vscode, cursor, tinkerwell, windsurf})
end

function App.getDefaultEditorBundle()
    return App.bundles[App.defaultEditor]
end

function App.getDefaultEditorCli()
    if App.defaultEditor == "vscode" then
        return 'code'
    else
        return 'cursor'
    end
end

function App.getFallbackEditorBundle()
    if App.defaultEditor == "cursor" then
        return App.bundles.vscode
    else
        return App.bundles.cursor
    end
end

function App.getFallbackEditorCli()
    if App.defaultEditor == "cursor" then
        return 'code'
    else
        return 'cursor'
    end
end

function App.is(bundle)
    return hs.application.frontmostApplication():bundleID() == bundle
end

function App.includes(bundles)
    return fn.table.has(bundles, hs.application.frontmostApplication():bundleID())
end

function App.loadBundleVariables()
    -- Private apps (e.g. pw) are defined in config/custom, outside the public repo.
    fn.each(fn.custom.bundles or {}, function(bundle, key)
        App.bundles[key] = bundle
    end)

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
