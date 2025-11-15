local Hyper = {}
Hyper.__index = Hyper

Hyper.lookup = {
    y = function ()
        fn.clipboard.clear()
        md.Yank.normal()
        local text = fn.clipboard.get()

        if is.In(spotify) then
            hs.osascript.applescript([[
                tell application "Spotify"
                    set theTrack to name of the current track
                    set theArtist to artist of the current track
                    set theAlbum to album of the current track
                    set track_id to id of current track
                end tell

                set AppleScript's text item delimiters to ":"
                set track_id to third text item of track_id
                set AppleScript's text item delimiters to {""}
                set realurl to ("https://open.spotify.com/track/" & track_id)

                set theString to theTrack & " by " & theArtist & ": " & realurl
                set the clipboard to theString
            ]])
        elseif text then
            fn.clipboard.set(text)
        elseif is.chrome() then
            fn.Chrome.copyUrl()
        elseif is.vivaldi() then
            fn.Vivaldi.copyUrl()
        elseif is.codeEditor() then
            md.Yank.relativeFilePath()
        end
    end,

    u = function ()
        if is.quickFind() then
            ks.cmd('1')
        else
            fn.Raycast.open()
        end
    end,

    i = function ()
        if is.quickFind() then
            ks.cmd('2')
        elseif is.terminal() then
            ks.type('cd ')
        elseif is.vivaldi() then
            ks.cmd('e')
        else
            cm.Search.symbol()
        end
    end,

    o = function ()
        if is.quickFind() then
            ks.cmd('3')
        else
            Hyper.open()
        end
    end,

    j = function ()
        if is.quickFind() then
            ks.cmd('4')
        else
            cm.Tab.previous()
        end
    end,

    k = function ()
        if is.quickFind() then
            ks.cmd('5')
        elseif is.In(dash) then
            ks.alt('up')
        else
            cm.Tab.next()
        end
    end,

    l = function ()
        if is.quickFind() then
            ks.cmd('6')
        elseif is.In(spotify) then
            ks.altCmd('right')
        elseif is.warp() then
            -- Autocomplete to the end of the line
            ks.ctrl('f')
        else
            ks.cmd(']')
        end
    end,

    semicolon = cm.Window.nextInCurrentApp,

    quote = function ()
        if fn.Raycast.visible() then
            ks.cmd('k')
        else
            cm.Window.next()
        end
    end,

    m = function ()
        if is.quickFind() then
            ks.cmd('7')
        else
            cm.Window.destroy()
        end
    end,

    comma = function ()
        if is.quickFind() then
            ks.cmd('8')
        else
            ks.undo()
        end
    end,

    period = function ()
        if is.quickFind() then
            ks.cmd('9')
        else
            ks.redo()
        end
    end,

    spacebar = 'forceEscape',
}

function Hyper.open()
    if is.In(vscode, tableplus, invoker) then
        ks.cmd('p')
    elseif is.In(mimestream) then
        ks.shiftCmd('o')
    elseif is.In(anybox) then
        ks.cmd('p')
    elseif is.In(discord, slack) then
        ks.cmd('k')
    elseif is.In(spotify) then
        fn.Alfred.run('spot_mini', 'com.vdesabou.spotify.mini.player')
    elseif is.vivaldi() or is.In(teams) then
        ks.cmd('e')
    elseif is.vivaldi() then
        if fn.Vivaldi.urlContains('github.com')
            or fn.Vivaldi.urlContains('tailwindcss.com/docs')
            or fn.Vivaldi.urlContains('laravel.com/docs')
        then
            ks.cmd('k')
        elseif fn.Vivaldi.urlContains('laravel-livewire.com/docs') then
            ks.key('/')
        else
            ks.cmd('l')
        end
    elseif is.terminal() then
        ks.type('wd ')
    else
        ks.cmd('o')
    end
end

function Hyper.forceEscape()
    if is.In(warp) then
        ks.ctrl('r')
    elseif fn.Raycast.visible() then
        ks.close()
    elseif cm.Window.scrolling then
        ks.escape()

        hs.timer.doAfter(0.2, function()
            md.Test.hideOutput()
            ks.escape().escape()
        end)
    else
        md.Test.hideOutput()
        ks.escape().escape()
    end
end

return Hyper
