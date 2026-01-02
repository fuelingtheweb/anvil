local SelectUntil = {}
SelectUntil.__index = SelectUntil

SelectUntil.lookup = {
    tab = 'untilBackward',
    q = nil,
    w = 'nextWord',
    e = 'endOfWord',
    r = 'untilForward',
    t = 'previousBlock',
    caps_lock = ToBracket.selectBackward,
    a = 'endOfLine',
    s = 'singleQuote',
    d = 'doubleQuote',
    f = 'parenthesis',
    g = 'beginningOfLine',
    left_shift = ToBracket.selectSecondary,
    z = 'backTick',
    x = nil,
    c = 'braces',
    v = 'nextBlock',
    b = 'brackets',
    spacebar = nil,
}

function SelectUntil.endOfWord()
    if is.vimMode() then
        ks.escape().sequence({'v', 'e'})
    else
        ks.shiftAlt('right')
    end
end

function SelectUntil.nextWord()
    if is.vimMode() then
        ks.escape().sequence({'v', 'w'})
    else
        ks.shiftAlt('right').shiftAlt('right')
    end
end

function SelectUntil.singleQuote()
    ToBracket.selectForward()
    ToBracket.actions.singleQuote()
end

function SelectUntil.doubleQuote()
    ToBracket.selectForward()
    ToBracket.actions.doubleQuote()
end

function SelectUntil.backTick()
    ToBracket.selectForward()
    ToBracket.actions.backTick()
end

function SelectUntil.parenthesis()
    ToBracket.selectForward()
    ToBracket.actions.parenthesis()
end

function SelectUntil.braces()
    ToBracket.selectForward()
    ToBracket.actions.braces(true)
end

function SelectUntil.brackets()
    ToBracket.selectForward()
    ToBracket.actions.brackets()
end

function SelectUntil.endOfLine()
    if is.vimMode() then
        ks.escape().shiftCmd('right')
    else
        ks.shiftCmd('right')
    end
end

function SelectUntil.beginningOfLine()
    if is.vimMode() then
        ks.escape()

        if is.vscode() then
            ks.key('v').shift('6')
        else
            ks.right().shiftCmd('left')
        end
    else
        ks.shiftCmd('left')
    end
end

function SelectUntil.previousBlock()
    if is.vimMode() then
        ks.shift('v').shift('[')
    else
        ks.shiftCmd('left')
    end
end

function SelectUntil.nextBlock()
    if is.vimMode() then
        ks.shift('v').shift(']')
    else
        ks.shiftCmd('right')
    end
end

function SelectUntil.untilForward()
    ks.escape().sequence({'v', 't'})
end

function SelectUntil.untilBackward()
    ks.escape().key('v').shift('t')
end

return SelectUntil
