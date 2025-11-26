local Command = {}
Command.__index = Command

Modal.load('Scrolling')

Command.lastApp = nil

Command.lookup = {
    w = cm.Window.enableScrolling,
    e = 'edit',
    t = 'newTask',

    d = function ()
        local text = str.selected()

        if text then
            if is.codeEditor() then
                ks.super('d')
            else
                ks.right().type(text)
            end
        elseif is.finder() then
            ks.cmd('d')
        elseif is.chrome() then
            -- Vimium
            ks.escape().type('yt')
        elseif is.codeEditor() then
            ks.shiftAltCmd('d')
        end
    end,

    f = 'finish',
    g = cm.Window.jumpTo,
    c = 'renameFile',

    v = function ()
        if is.codeEditor() then
            ks.shiftCmd('d')
        elseif is.googleSheet() then
            ks.shift('space').shift('space').slow().copy().left()
            md.Vi.moveToFirstCharacterOfLine()
            md.Make.lineAfter()
            ks.escape().slow().paste().left()
            md.Vi.moveToFirstCharacterOfLine()
        else
            md.Yank.line()
            ks.enter().paste()
        end
    end,
}

function Command.edit()
    Command.lastApp = hs.application.frontmostApplication()

    if is.vscode() then
        local site = ProjectManager.current()

        fn.misc.executeFromAnvil('tinkerwell "' .. site.attributes.path .. '"')

        return
    end

    if is.gmail() then
        md.Yank.toTopOfPage()
    else
        md.Yank.all()
    end

    fn.Code.new()

    hs.timer.doAfter(0.5, function()
        ks.paste()
        md.Vi.moveToTopOfPage()
        ks.escape()
    end)
end

function Command.finish()
    if is.vscode() then
        if is.todo() or is.markdown() then
            ks.alt('d').slow().save()
        elseif fn.window.titleContains('.git/COMMIT_EDITMSG') or fn.window.titleContains('.git/MERGE_MSG') then
            ks.slow().save().slow().close()
            hs.application.launchOrFocusByBundleID(warp)
        elseif fn.window.titleContains('Untitled-') then
            md.Yank.all()

            hs.timer.doAfter(0.2, function()
                ks.super('w')
                Command.lastApp:activate()

                hs.timer.doAfter(0.2, function()
                    Command.lastApp = nil
                    md.Paste.all()
                    ks.delete()

                    if is.In(slack) then
                        ks.shiftCmd('f')
                    end
                end)
            end)
        end
    elseif is.In(transmit) then
        -- Disconnect from server
        ks.cmd('e')
    elseif is.In(tinkerwell) then
        ks.cmd('r')
    elseif is.googleSheet() then
        ks.enter().up()
    elseif is.terminal() then
        if fn.window.titleContains('git.checkout') or fn.window.titleContains('git.branch.delete') then
            ks.escape()
        elseif
            fn.window.title() == 'git'
            or fn.window.title() == 'g'
            or fn.window.title() == 'gd'
            or fn.window.title() == 'gds'
            or fn.window.title() == 'gl'
            or fn.window.title() == 'man'
            or fn.window.titleContains('git.')
            or fn.window.titleContains('. git ')
        then
            ks.key('q')
        else
            ks.ctrl('c')
        end
    elseif is.chat() then
        ks.enter()
    else
        ks.cmd('return')
    end
end

function Command.newTask()
    if is.markdown() then
        ks.alt('return')
    elseif is.In(obsidian) then
        ks.shiftCmd('t')
    else
        ks.cmd('return')
    end
end

function Command.renameFile()
    if is.vscode() then
        fn.Code.run('File Utils: Rename')
    end
end

return Command
