local Code = {}
Code.__index = Code

Code.windowsWithSnippetsInitialized = {}

function Code.run(name)
    Code.listCommands(name)
    hs.timer.doAfter(0.3, ks.enter)
end

function Code.openFile(file)
    ks.slow().cmd('t').type(file)
    hs.timer.doAfter(0.3, ks.enter)
end

function Code.open(path)
    local defaultBundle = App.getDefaultEditorBundle()
    local app = hs.application.find(defaultBundle)

    if not app then
        Code.openAndMaximize(path)
    else
        local window = nil

        fn.each(hs.window.filter.new(app:name()):getWindows(), function(w)
            if not window and str.contains(path, w:title()) then
                window = w
            end
        end)

        if window then
            window:focus()
        else
            Code.openAndMaximize(path)
        end
    end
end

function Code.openAndMaximize(path)
    local defaultBundle = App.getDefaultEditorBundle()
    local fallbackBundle = App.getFallbackEditorBundle()
    local defaultCli = App.getDefaultEditorCli()
    local fallbackCli = App.getFallbackEditorCli()

    local defaultApp = hs.application.find(defaultBundle)
    local fallbackApp = hs.application.find(fallbackBundle)

    if defaultApp then
        hs.execute(defaultCli .. ' "' .. path .. '"')
    elseif fallbackApp then
        hs.execute(fallbackCli .. ' "' .. path .. '"')
    else
        -- Try default first, fallback to secondary
        local result = hs.execute(defaultCli .. ' "' .. path .. '" 2>&1')
        if result:match('command not found') or result:match('No such file') then
            hs.execute(fallbackCli .. ' "' .. path .. '"')
        end
    end
    cm.Window.maximizeAfterDelay()
end

function Code.ensureInitializedSnippets(callback)
    local window = hs.window.focusedWindow()

    if not is.vscode()
        or hs.fnutils.contains(Code.windowsWithSnippetsInitialized, window:id()) then
        return callback()
    end

    ks.ctrlCmd('s')

    hs.timer.doAfter(0.1, function()
        ks.escape()

        callback()

        table.insert(Code.windowsWithSnippetsInitialized, window:id())
    end)
end

function Code.new()
    local defaultBundle = App.getDefaultEditorBundle()
    local fallbackBundle = App.getFallbackEditorBundle()

    local app = hs.application.find(defaultBundle) or hs.application.find(fallbackBundle)
    if app then
        app:activate()
    else
        if not hs.application.launchOrFocusByBundleID(defaultBundle) then
            hs.application.launchOrFocusByBundleID(fallbackBundle)
        end
    end

    hs.timer.doAfter(0.2, function()
        -- cm.Tab.new()
    end)
end

function Code.listCommands(name)
    ks.slow().shiftCmd('p').type(name)
end

return Code
