local Keystroke = {}
Keystroke.__index = Keystroke

ks = Keystroke

function Keystroke.escape()
    return Keystroke.key('escape')
end

function Keystroke.enter()
    return Keystroke.key('return')
end

function Keystroke.shiftEnter()
    return Keystroke.shift('return')
end

function Keystroke.tab()
    return Keystroke.key('tab')
end

function Keystroke.delete()
    return Keystroke.key('delete')
end

function Keystroke.up()
    return Keystroke.key('up')
end

function Keystroke.down()
    return Keystroke.key('down')
end

function Keystroke.left()
    return Keystroke.key('left')
end

function Keystroke.leftAfter(delay)
    if delay then
        hs.timer.doAfter(delay, function()
            Keystroke.key('left')
        end)
    else
        return Keystroke.key('left')
    end
end

function Keystroke.right()
    return Keystroke.key('right')
end

function Keystroke.copy()
    return Keystroke.cmd('c')
end

function Keystroke.paste()
    Keystroke.cmd('v')

    if is.In(slack) then
        hs.timer.doAfter(0.1, function()
            Keystroke.shiftCmd('f')
        end)
    end

    return Keystroke
end

function Keystroke.undo()
    return Keystroke.cmd('z')
end

function Keystroke.redo()
    return Keystroke.shiftCmd('z')
end

function Keystroke.save()
    return Keystroke.cmd('s')
end

function Keystroke.refresh()
    return Keystroke.cmd('r')
end

function Keystroke.close()
    return Keystroke.cmd('w')
end

function Keystroke.shift(key)
    return Keystroke.fire({'shift'}, key)
end

function Keystroke.shiftCtrl(key)
    return Keystroke.fire({'shift', 'ctrl'}, key)
end

function Keystroke.shiftCtrlAlt(key)
    return Keystroke.fire({'shift', 'ctrl', 'alt'}, key)
end

-- Used for Karabiner
function Keystroke.shiftCtrlCmd(key)
    return Keystroke.fire({'shift', 'ctrl', 'cmd'}, key)
end

function Keystroke.shiftAlt(key)
    return Keystroke.fire({'shift', 'alt'}, key)
end

function Keystroke.shiftAltCmd(key)
    return Keystroke.fire({'shift', 'alt', 'cmd'}, key)
end

function Keystroke.shiftCmd(key)
    return Keystroke.fire({'shift', 'cmd'}, key)
end

function Keystroke.ctrl(key)
    return Keystroke.fire({'ctrl'}, key)
end

function Keystroke.ctrlAlt(key)
    return Keystroke.fire({'ctrl', 'alt'}, key)
end

function Keystroke.ctrlCmd(key)
    return Keystroke.fire({'ctrl', 'cmd'}, key)
end

function Keystroke.super(key)
    return Keystroke.fire({'ctrl', 'alt', 'cmd'}, key)
end

function Keystroke.alt(key)
    return Keystroke.fire({'alt'}, key)
end

function Keystroke.altCmd(key)
    return Keystroke.fire({'alt', 'cmd'}, key)
end

function Keystroke.cmd(key)
    return Keystroke.fire({'cmd'}, key)
end

function Keystroke.key(key)
    return Keystroke.fire({}, key)
end

function Keystroke.sequence(keys)
    fn.each(keys, Keystroke.key)

    return Keystroke
end

function Keystroke.fire(modifiers, key)
    if type(modifiers) == 'string' then
        key = modifiers
        modifiers = {}
    end

    hs.eventtap.keyStroke(modifiers, key, Keystroke.delay)

    Keystroke.reset()

    return Keystroke
end

function Keystroke.type(text)
    -- if is.codeEditor() then
    --     fn.clipboard.pasteTransient(text)
    -- else
        hs.eventtap.keyStrokes(text)
    -- end

    return Keystroke
end

function Keystroke.typeAndEnter(text)
    Keystroke.type(text)

    hs.timer.doAfter(0.1, function()
        ks.enter()
    end)

    return Keystroke
end

function Keystroke.slow(delay)
    Keystroke.delay = delay or nil

    return Keystroke
end

function Keystroke.reset()
    Keystroke.delay = 0
end

function Keystroke.build(callable, value)
    return function()
        Keystroke[callable](value)
    end
end

Keystroke.reset()

return Keystroke
