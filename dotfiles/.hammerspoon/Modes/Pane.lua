local Pane = {}
Pane.__index = Pane

Pane.lookup = {
    y = nil,
    u = nil,
    i = nil,
    o = nil,
    p = nil,
    open_bracket = nil,
    close_bracket = nil,
    h = nil,
    j = 'focusPrevious',
    k = 'focusNext',
    l = 'splitRight',
    semicolon = 'toggleZoom',
    quote = 'focusOtherSide',
    return_or_enter = nil,
    n = nil,
    m = 'destroy',
    comma = nil,
    period = nil,
    slash = nil,
    right_shift = nil,
    spacebar = nil,
}

function Pane.destroy()
    if is.vscode() then
        ks.super('p').super('d')
    elseif is.terminal() then
        ks.close()
    end
end

function Pane.splitRight()
    if is.vscode() then
        ks.super('p').super('l')
    elseif is.terminal() then
        ks.cmd('d')
    end
end

function Pane.toggleZoom()
end

function Pane.focusPrevious()
    if is.googleSheet() then
        ks.alt('up')
    elseif is.vscode() then
        ks.super('p').super('k')
    elseif is.In(transmit) then
        ks.altCmd('left')
    elseif is.In(tables) then
        -- No panes to move between (and ⌘[ there is Back).
    elseif is.In(tableplus) then
        ks.altCmd('[')
    else
        ks.cmd('[')
    end
end

function Pane.focusNext()
    if is.googleSheet() then
        ks.alt('down')
    elseif is.vscode() then
        ks.super('p').super('j')
    elseif is.In(transmit) then
        ks.altCmd('right')
    elseif is.In(tables) then
        -- No panes to move between (and ⌘] would be taken as navigation).
    elseif is.In(tableplus) then
        ks.altCmd(']')
    else
        ks.cmd(']')
    end
end

function Pane.focusOtherSide()
    if is.vscode() then
        ks.super('p').super(';')
    end
end

return Pane
