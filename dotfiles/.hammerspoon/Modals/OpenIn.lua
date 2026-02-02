local OpenIn = {}
OpenIn.__index = OpenIn

Modal.add({
    key = 'OpenIn',
    title = 'Open In',
    items = {
        r = {name = 'VS Code', method = 'inCode'},
        c = {name = 'Git Gui', method = 'inGitGui'},
        g = {name = 'Chrome', method = 'inChrome'},
        v = {name = 'TablePlus', method = 'inTablePlus'},
        x = {name = 'Finder', method = 'inFinder'},
        w = {name = 'Tinkerwell', method = 'inTinkerwell'},
    },
    callback = function(item)
        Modal.exit()

        OpenIn[item.method]()

        cm.Window.maximizeAfterDelay(0.5)

        hs.timer.doAfter(1, function()
            cm.Window.centerMouseOnScreen(cm.Window.current():screen())
        end)
    end,
})

function OpenIn.inGitGui()
    if is.terminal() then
        ks.typeAndEnter('gitfox .')
    else
        local path = fn.window.path()

        if path == '~/.hammerspoon' then
            path = '~/Dev/Anvil'
        end

        if path then
            hs.execute('/usr/local/bin/gitfox "' .. path .. '"')
        end
    end

    hs.timer.doAfter(0.5, function()
        hs.application.open(gitfox)
    end)
end

function OpenIn.inCode()
    if is.terminal() then
        ks.typeAndEnter(fn.app.getDefaultEditorCli() .. ' .')
    else
        local path = fn.window.path()

        if not path then
            return
        end

        fn.Code.open(path)
    end
end

function OpenIn.inChrome()
    local text = str.selected()

    if text then
        fn.Chrome.searchGoogle(text)
    elseif is.chrome() then
        fn.Chrome.copyUrl()
        fn.Chrome.open(fn.clipboard.get())
    else
        ProjectManager.openUrlForCurrent()
    end
end

function OpenIn.inTablePlus()
    if not ProjectManager:openDatabaseForCurrent() then
        fn.Alfred.run('tableplus', 'com.chrisrenga.tableplus')
    end

    hs.timer.doAfter(0.5, function() md.Hyper.open() end)
end

function OpenIn.inFinder()
    if is.terminal() then
        ks.typeAndEnter('o.')
    else
        local path = fn.window.path()

        if not path then
            return
        end

        hs.execute('open -R ' .. path)
    end
end

function OpenIn.inTinkerwell()
    if is.terminal() then
        return ks.typeAndEnter('tinkerwell .')
    end

    local path = fn.window.path()

    if path then
        fn.misc.executeFromAnvil('tinkerwell "' .. path .. '"')
    end
end

return OpenIn
