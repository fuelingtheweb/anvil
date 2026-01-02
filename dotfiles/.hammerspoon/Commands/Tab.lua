local Tab = {}
Tab.__index = Tab

function Tab.previous()
    if is.In(tableplus) then
        ks.cmd('[')
    elseif is.In(discord) then
        -- Move to next conversation / channel
        ks.alt('down')
    elseif is.In(tinkerwell) then
        ks.altCmd('left')
    elseif is.vivaldi() then
        ks.shiftCmd(']')
    else
        ks.shiftCmd('[')
    end
end

function Tab.next()
    if is.In(tableplus) then
        ks.cmd(']')
    elseif is.In(discord) then
        -- Move to previous conversation / channel
        ks.alt('up')
    elseif is.In(tinkerwell) then
        ks.altCmd('right')
    elseif is.vivaldi() then
        ks.shiftCmd('[')
    else
        ks.shiftCmd(']')
    end
end

function Tab.closeCurrent()
    ks.close()

    if is.chrome() then
        hs.timer.doAfter(1, function()
            app = hs.application.frontmostApplication()

            if next(app:visibleWindows()) == nil then
                app:hide()
            end
        end)
    end
end

function Tab.closePrevious()
    Tab.previous()
    Tab.closeCurrent()

    if is.notIn(vscode) then
        Tab.next()
    end
end

function Tab.closeNext()
    Tab.next()
    Tab.closeCurrent()

    if is.vscode() or is.chrome() then
        Tab.previous()
    end
end

return Tab
