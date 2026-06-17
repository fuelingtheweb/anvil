local obj = {}
obj.__index = obj

log = hs.logger.new('ftw-log', 'debug')

-- Keep Awake: periodically fakes activity so chat apps don't show "away". It
-- only fires after a stretch of genuine inactivity, and while it briefly borrows
-- focus it swallows real keystrokes so nothing you type lands in the editor.
local KEEP_AWAKE_INTERVAL = 60 -- base seconds between cycles (~1 min)
local KEEP_AWAKE_JITTER = 20    -- +/- random seconds, so the cadence isn't robotic
local ACTIVE_WITHIN = 60        -- skip a cycle if you've touched the machine this recently
local GUARD_TIMEOUT = 1.5       -- failsafe cap (s) on the keystroke guard
local KA_MARKER = 0x6B61        -- tag marking our own synthetic key events ('ka')

math.randomseed(os.time())

local keepAwakeEnabled = false
local keepAwakeTimer = nil
local guardActive = false
local guardWatchdog = nil

-- While the routine borrows focus, drop *real* keystrokes so stray characters
-- never land in the editor. Our synthetic keys carry KA_MARKER and pass through.
local keyGuard = hs.eventtap.new(
    {hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp},
    function(event)
        if not guardActive then return false end
        if event:getProperty(hs.eventtap.event.properties.eventSourceUserData) == KA_MARKER then
            return false
        end
        return true -- swallow the real keystroke
    end
)

local function stopGuard()
    guardActive = false
    keyGuard:stop()
    if guardWatchdog then
        guardWatchdog:stop()
        guardWatchdog = nil
    end
end

local function startGuard()
    guardActive = true
    keyGuard:start()
    if guardWatchdog then guardWatchdog:stop() end
    -- Never leave the guard on if the doAfter chain breaks mid-flight.
    guardWatchdog = hs.timer.doAfter(GUARD_TIMEOUT, stopGuard)
end

-- Post a tagged key press/release so the guard recognises it as ours.
local function tappedKey(key)
    for _, isDown in ipairs({true, false}) do
        local event = hs.eventtap.event.newKeyEvent({}, key, isDown)
        event:setProperty(hs.eventtap.event.properties.eventSourceUserData, KA_MARKER)
        event:post()
    end
end

local function runKeepAwake()
    -- You're clearly present if you've used the machine recently; skip this cycle.
    if hs.host.idleTime() < ACTIVE_WITHIN then return end

    local originalPos = hs.mouse.absolutePosition()
    local previousApp = hs.application.frontmostApplication()

    -- Nudge the cursor a single pixel and restore it.
    hs.mouse.absolutePosition({x = originalPos.x + 1, y = originalPos.y})
    hs.timer.usleep(50000) -- 50ms so the movement registers
    hs.mouse.absolutePosition(originalPos)

    -- Activate the editor and tap a no-op key (down then up) to register activity.
    local editor = hs.application.get(fn.app.getDefaultEditorBundle())
    if not editor then return end

    startGuard()
    editor:activate()
    hs.timer.doAfter(0.2, function()
        tappedKey('down')
        hs.timer.doAfter(0.1, function()
            tappedKey('up')
            hs.timer.doAfter(0.1, function()
                if previousApp then previousApp:activate() end
                stopGuard()
            end)
        end)
    end)
end

local function scheduleNext()
    local interval = KEEP_AWAKE_INTERVAL + math.random(-KEEP_AWAKE_JITTER, KEEP_AWAKE_JITTER)
    keepAwakeTimer = hs.timer.doAfter(interval, function()
        runKeepAwake()
        if keepAwakeEnabled then scheduleNext() end
    end)
end

-- Discreet menubar dot: filled teal when on, hollow when off. Click to toggle.
-- The autosave name lets macOS remember where you ⌘-drag it across reloads.
local keepAwakeMenu = hs.menubar.new(true, 'keepAwake')

local function updateKeepAwakeMenu()
    if not keepAwakeMenu then return end
    if keepAwakeEnabled then
        keepAwakeMenu:setTitle(hs.styledtext.new('●', {color = {hex = '#367f71'}}))
    else
        keepAwakeMenu:setTitle('○')
    end
    keepAwakeMenu:setTooltip('Keep Awake: ' .. (keepAwakeEnabled and 'on' or 'off'))
end

local function toggleKeepAwake()
    if keepAwakeEnabled then
        keepAwakeEnabled = false
        if keepAwakeTimer then
            keepAwakeTimer:stop()
            keepAwakeTimer = nil
        end
        stopGuard()
    else
        keepAwakeEnabled = true
        scheduleNext()
    end
    updateKeepAwakeMenu()
end

hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'j', toggleKeepAwake)

if keepAwakeMenu then
    keepAwakeMenu:setClickCallback(toggleKeepAwake)
    updateKeepAwakeMenu()
end

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
