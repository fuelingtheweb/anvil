local Window = {}
Window.__index = Window

Modal.load('Window')
Modal.load('Amethyst')

Window.scrolling = false
Window.HalfsAndThirds = hs.loadSpoon('vendor/WindowHalfsAndThirds')

hs.grid.setGrid('12x4')
hs.grid.setMargins({x = 0, y = 0})
hs.window.animationDuration = 0

hs.grid.ui.textSize = 100
hs.grid.ui.showExtraKeys = false

function Window.missionControl()
    ks.fire({'fn', 'ctrl'}, 'up')
end

function Window.moveTotopRightSmall()
    hs.grid.set(hs.window.focusedWindow(), '9,0 3x1')
end

function Window.moveToMiddle()
    hs.grid.set(hs.window.focusedWindow(), '2,0 8x4')
end

function Window.moveToCenter()
    Window.HalfsAndThirds.center()
end

function Window.moveToNextDisplay()
    local window = Window.current()

    hs.grid.set(window, '0,0 12x4')
    window:moveToScreen(Window.nextScreen())

    Window.centerMouseOnScreen(window:screen())
end

function Window.reset()
    Window.HalfsAndThirds.undo()
end

function Window.next()
    local windows = hs.fnutils.filter(
        hs.window.filter.default:getWindows(hs.window.filter.sortByFocusedLast),
        function(window)
            return window:title()
        end
    )

    local nextWin = windows[2]

    if not nextWin or nextWin:title() == fn.window.title() then
        nextWin = windows[1]
    end

    if not nextWin then
        return
    end

    if nextWin:isMinimized() then
        nextWin:unminimize()
    else
        nextWin:focus()
    end
end

function Window.nextScreen()
    return Window.currentScreen():next()
end

function Window.currentScreen()
    return hs.mouse.getCurrentScreen()
end

function Window.currentApp()
    return hs.application.frontmostApplication()
end

function Window.current()
    return hs.window.focusedWindow()
end

function Window.filtered(screen, app, exceptWindow)
    return hs.fnutils.filter(
        hs.window.orderedWindows(),
        function(window)
            if screen and window:screen():id() ~= screen:id() then
                return false;
            end

            if app and window:application() ~= app then
                return false;
            end

            if exceptWindow and window:id() == exceptWindow:id() then
                return false;
            end

            return true
        end
    )
end

function Window.centerMouseOnScreen(screen)
    if screen then
        hs.mouse.absolutePosition(
            hs.geometry.rectMidPoint(
                screen:fullFrame()
            )
        )
    end
end

function Window.focusFirst(windows, app)
    local fallbackWindow = app and app:mainWindow() or nil
    local window = #windows > 0 and windows[1] or fallbackWindow

    if window then
        window:becomeMain()
        window:application():activate()

        if hs.mouse.getCurrentScreen():id() ~= window:screen():id() then
            Window.centerMouseOnScreen(window:screen())
        end
    end

    if app then
        app:activate()
    end
end

function Window.nextInCurrentApp()
    Window.focusFirst(
        Window.filtered(Window.currentScreen(), Window.currentApp(), Window.current())
    )
end

function Window.settings()
    ks.cmd(',')
end

function Window.moveMouseToOtherScreen()
    Window.focusFirst(
        Window.filtered(Window.nextScreen())
    )
end

function Window.toggleSidebar()
    if is.finder() then
        ks.altCmd('s')
    elseif is.In(mimestream) then
        ks.ctrlCmd('s')
    elseif is.In(anybox) then
        ks.ctrlCmd('s')
    elseif is.In(slack) then
        ks.shiftCmd('d')
    elseif is.In(tableplus) then
        ks.cmd('0')
    else
        ks.cmd('\\')
    end
end

function Window.scrollScreenWithCursorAtEnd()
    if is.codeEditor() then
        md.Hyper.forceEscape()
        ks.sequence({'z', 'b'})
    end
end

function Window.scrollScreenWithCursorAtCenter()
    if is.codeEditor() then
        md.Hyper.forceEscape()
        ks.sequence({'z', 'z'})
    end
end

function Window.scrollScreenWithCursorAtTop()
    if is.codeEditor() then
        md.Hyper.forceEscape()
        ks.sequence({'z', 't'})
    end
end

function Window.toggleCodeFocus()
    ks.shiftAltCmd('z')
end

function Window.focusSidebarFileExplorer()
    ks.shiftAltCmd('b').shiftAltCmd('x')
end

function Window.focusSidebarTodo()
    ks.shiftAltCmd('b').shiftAltCmd('t')
end

function Window.focusSidebarSourceControl()
    ks.shiftAltCmd('b').shiftAltCmd('c')
end

function Window.focusActiveEditor()
    ks.shiftAltCmd('b').shiftAltCmd('r')
end

function Window.focusSidebar()
    ks.cmd('0')
end

function Window.destroy()
    if is.In(chrome, vivaldi) then
        ks.shiftCmd('w')

        hs.timer.doAfter(1, function()
            app = hs.application.frontmostApplication()

            if next(app:visibleWindows()) == nil then
                app:hide()
            end
        end)
    elseif is.In({
        discord,
        tinkerwell,
        invoker,
        youtubeMusic,
        'com.apple.ActivityMonitor',
        'md.obsidian',
    }) then
        Window.quitApplication()
    elseif is.codeEditor() then
        ks.shiftCmd('w')
    elseif is.In(tableplus) then
        fn.TablePlus.closeWindow()
    else
        ks.close()
    end
end

function Window.quitApplication()
    ks.cmd('q')
end

function Window.maximizeAfterDelay(delay)
    hs.timer.doAfter(delay or 0.5, Window.maximize)
end

function Window.maximize()
    Window.moveTo('maximize')
end

function Window.topLeft()
    Window.moveTo('topLeft')
end

function Window.topRight()
    Window.moveTo('topRight')
end

function Window.leftHalf()
    Window.moveTo('leftHalf')
end

function Window.bottomHalf()
    Window.moveTo('bottomHalf')
end

function Window.topHalf()
    Window.moveTo('topHalf')
end

function Window.rightHalf()
    Window.moveTo('rightHalf')
end

function Window.bottomLeft()
    Window.moveTo('bottomLeft')
end

function Window.bottomRight()
    Window.moveTo('bottomRight')
end

function Window.moveTo(position)
    Window.HalfsAndThirds[position]()
end

function Window.jumpTo()
    -- if is.vscode() then
    -- ks.shiftEnter()
    -- ks.ctrl('space')
    -- else
        -- Vimac
        -- ks.ctrl('space')
    -- end
    -- Homerow
    ks.shiftCmd('space')
end

function Window.enableScrolling()
    -- if Window.scrolling then
    --     Modal.exit()
    -- else
    --     Modal.enter('Scrolling')
    -- end

    -- Vimac: Scrolling
    ks.super('s')
end

function Window.windowModal()
    Modal.enter('Window')
end

function Window.amethystModal()
    Modal.enter('Amethyst')
end

function Window.new()
    ks.shiftCmd('n')
end

function Window.focusActivePullRequest()
    ks.shiftCtrlCmd('r').shiftCtrlCmd('a')
end

function Window.focusAllPullRequests()
    ks.shiftCtrlCmd('r').shiftCtrlCmd('r')
end

return Window
