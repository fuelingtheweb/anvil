local obj = {}
obj.__index = obj

log = hs.logger.new('ftw-log', 'debug')

hs.urlevent.bind('misc-optionPressedOnce', function()
    if is.In(spotify) then
        cm.Window.next()
    else
        fn.misc.moveMouse()
    end
end)

hs.urlevent.bind('misc-optionPressedTwice', function()
    app = hs.application.get(spotify)

    if app and app:isRunning() then
        app:activate()
    end
end)

-- UrlDispatcher = hs.loadSpoon('vendor/URLDispatcher')
-- UrlDispatcher.default_handler = vivaldi
-- UrlDispatcher.url_patterns = require('config.custom.routing')
-- UrlDispatcher:start()

Shortcuts = hs.loadSpoon('Shortcuts')
Shortcuts:addFromConfig()

ProjectManager = hs.loadSpoon('ProjectManager')
ProjectManager:addFromConfig()
ProjectManager:setAlfredJson()

AlfredCommands = hs.loadSpoon('AlfredCommands')
AlfredCommands:addFromConfig()
AlfredCommands:listen()
AlfredCommands:setAlfredJson()

spoon.MouseCircle = hs.loadSpoon('vendor/MouseCircle')
spoon.MouseCircle.color = {hex = '#367f71'}

-- spoon.ReloadConfiguration = hs.loadSpoon('vendor/ReloadConfiguration')
-- spoon.ReloadConfiguration.watch_paths = {
--     hs.configdir,
--     hs.configdir .. '/Spoons/Custom.spoon',
--     hs.configdir .. '/config/custom',
-- }
-- spoon.ReloadConfiguration:start()
hs.notify.new({title = 'Hammerspoon', informativeText = 'Config loaded'}):send()

hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'b', function()
    local app = hs.application.frontmostApplication()
    local bundle = app:bundleID()

    fn.clipboard.set(bundle)
    hs.notify.new({title = 'App Bundle Copied', informativeText = bundle}):send()
end)

hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'space', function()
    local title = fn.window.title()

    hs.alert.show(title)
    fn.clipboard.set(title)
end)

function openAnybox()
    local app = hs.application.get(anybox)

    if not app then
        fn.each(hs.application.open(anybox, 2, true):allWindows(), function(window)
            window:close()
        end)
    end
end

-- openAnybox()

local espansoSnippets = {
    gm = 'Good morning',
    lgtm = 'Looks good to me',
    nm = 'Nevermind',
    np = 'No problem',
    sg = 'Sounds good',
    st = 'Sure thing',
    th = 'Thanks',
    ty = 'Thank you',
    yw = 'You\'re welcome',
    hb = 'Happy Birthday',
}

local generatedAbbreviations = 'matches:'

fn.each(espansoSnippets, function (snippet, trigger)
    generatedAbbreviations = generatedAbbreviations .. "\n" .. '  - trigger: ",' .. trigger .. '"' .. "\n" .. '    replace: "' .. snippet .. '"'

    fn.each({'!', '?', '.'}, function (punctuation)
        generatedAbbreviations = generatedAbbreviations .. "\n" .. '  - trigger: "' .. punctuation .. ' ,' .. trigger .. '"' .. "\n" .. '    replace: "' .. punctuation .. ' ' .. snippet .. '"'
    end)

    generatedAbbreviations = generatedAbbreviations .. "\n" .. '  - trigger: " ,' .. trigger .. '"' .. "\n" .. '    replace: " ' .. string.lower(snippet) .. '"'
end)

local filePath = home_path .. '/Dev/Anvil/custom/espanso/match/generated-abbreviations.yml'
local file, err = io.open(filePath, 'w')
if file then
    file:write(generatedAbbreviations)
    file:close()
else
    log.e('Failed to open ' .. filePath .. ': ' .. (err or 'unknown error'))
end

return obj
