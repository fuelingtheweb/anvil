local KarabinerHandler = {}
KarabinerHandler.__index = KarabinerHandler

md = {}

KarabinerHandler.lookup = {
    q = 'Pane',
    t = {
        warp = 'Terminal',
        obsidian = 'Test',
        vscode = 'Test',
    },
    y = {warp = 'Yarn', default = 'Yank'},
    u = 'AppShortcut',
    i = 'Make',
    o = 'Open',
    p = 'Paste',
    open_bracket = 'Secondary',
    caps_lock = 'Hyper',
    a = {
        warp = 'Artisan',
        default = 'ChangeCase',
    },
    s = {
        warp = 'TerminalSnippets',
        slack = 'SlackSnippets',
        vscode = 'CodeSnippets',
        tinkerwell = 'CodeSnippets',
        tables = 'DatabaseSnippets',
        tableplus = 'DatabaseSnippets',
        default = 'DefaultSnippets',
    },
    semicolon = 'Command',
    quote = 'ExtendedCommand',
    z = 'CaseDialog',
    x = 'Execute',
    c = 'Code',
    n = 'Change',
    m = 'Destroy',
    comma = 'SelectInside',
    period = 'SelectUntil',
    slash = 'JumpTo',
    spacebar = 'Window',
}

function KarabinerHandler.loadModes(modes)
    fn.each(modes, function(mode, modifier)
        if not mode then
            return
        end

        if is.Table(mode) then
            return KarabinerHandler.loadModes(mode)
        end

        if not md[mode] then
            md[mode] = require('Modes.' .. mode)

            KarabinerHandler.setupMode(md[mode])
        end
    end)
end

function KarabinerHandler.setupMode(mode)
    fn.each(mode.lookup or {}, function(callable, key)
        if not is.Table(callable) then
            return
        end

        mode.lookup[key] = hs.fnutils.map(callable, function(item)
            if mode[item] then
                return function() mode[item](key) end
            elseif mode.fallback then
                return function() mode.fallback(item, key) end
            end
        end)
    end)
end

function KarabinerHandler.handle(mode, key)
    -- if TextManipulation.vimEnabled and not cm.Window.scrolling then
    --     Modal.exit()
    -- end

    local Mode = md[mode]

    if Mode.guard and not Mode.guard() then
        return
    end

    if Mode.before then
        Mode.before()
    end

    if Mode[key] then
        return Mode[key]()
    elseif Mode.handle then
        Mode.handle(key)
    elseif Mode.lookup and Mode.lookup[key] then
        local callable = Mode.lookup[key]

        if is.Table(callable) then
            Pending.run(callable)
        elseif is.Function(callable) then
            callable(key)
        elseif callable then
            if Mode[callable] then
                Mode[callable](key)
            elseif Mode.fallback then
                Mode.fallback(callable, key)
            end
        end
    end
end

hs.urlevent.bind('handle-karabiner', function(eventName, params)
    KarabinerHandler.handle(params.mode, params.key)
end)

-- URL events (hammerspoon://Tab.previous) by name; init.lua fills it in.
KarabinerHandler.events = {}

function KarabinerHandler.handleEvent(name)
    local handler = KarabinerHandler.events[name] or KarabinerHandler.events[name:lower()]

    if handler then
        handler(name, {})
    end
end

-- Keys (com.tidypoint.Keys, Karabiner's replacement) sends the same
-- requests over a message port instead of opening a URL per key:
-- message 1 is "mode<tab>key", message 2 a URL event's name.
KarabinerHandler.keysPort = require('hs.ipc').localPort('com.tidypoint.Keys.hammerspoon', function(_, msgID, data)
    if msgID == 1 then
        local mode, key = data:match('^(.-)\t(.*)$')

        if mode then
            KarabinerHandler.handle(mode, key)
        end
    elseif msgID == 2 then
        KarabinerHandler.handleEvent(data)
    end
end)

KarabinerHandler.loadModes(KarabinerHandler.lookup)

return KarabinerHandler
