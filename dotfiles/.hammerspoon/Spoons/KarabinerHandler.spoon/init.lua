local KarabinerHandler = {}
KarabinerHandler.__index = KarabinerHandler

md = {}

KarabinerHandler.lookup = {
    tab = 'Tab',
    q = 'Pane',
    w = nil,
    e = nil,
    t = {
        iterm = 'Terminal',
        warp = 'Terminal',
        obsidian = 'Test',
        vscode = 'Test',
    },
    y = {iterm = 'Yarn', warp = 'Yarn', default = 'Yank'},
    u = 'AppShortcut',
    i = 'Make',
    o = 'Open',
    p = 'Paste',
    open_bracket = 'Secondary',
    close_bracket = 'Tertiary',
    caps_lock = 'Hyper',
    a = {
        iterm = 'Artisan',
        warp = 'Artisan',
        default = 'ChangeCase',
    },
    s = {
        iterm = 'TerminalSnippets',
        warp = 'TerminalSnippets',
        slack = 'SlackSnippets',
        vscode = 'CodeSnippets',
        tinkerwell = 'CodeSnippets',
        tableplus = 'DatabaseSnippets',
        default = 'DefaultSnippets',
    },
    d = 'Vi',
    semicolon = 'Command',
    quote = 'ExtendedCommand',
    return_or_enter = nil,
    z = 'CaseDialog',
    x = 'Execute',
    c = 'Code',
    v = 'ViVisual',
    b = nil,
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

KarabinerHandler.loadModes(KarabinerHandler.lookup)

return KarabinerHandler
