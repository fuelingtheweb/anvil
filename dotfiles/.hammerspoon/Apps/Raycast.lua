local Raycast = {}
Raycast.__index = Raycast

function Raycast.open()
    ks.alt('space')
end

function Raycast.clipboard()
    ks.shiftAltCmd('p')
end

function Raycast.commands()
    Raycast.run('commands', 'com.fuelingtheweb.commands')
end

function Raycast.actionFile()
    ks.altCmd('\\')
end

function Raycast.sleep()
    Raycast.search('cmd:sleep')
    ks.enter()
end

function Raycast.emptyTrash()
    Raycast.search('cmd:emptytrash')
    ks.enter()
end

function Raycast.search(search)
    hs.osascript.applescript('tell application id "com.runningwithcrayons.Raycast" to search "' .. search .. '"')
end

function Raycast.run(trigger, workflow, argument)
    spoon.KarabinerHandler.modifier = nil

    local script = 'tell application id "com.runningwithcrayons.Raycast" to run trigger "' .. trigger .. '" in workflow "' .. workflow .. '"'

    if argument then
        script = script .. ' with argument "' .. argument .. '"'
    end

    hs.osascript.applescript(script)
end

function Raycast.visible()
    local app = hs.application.find('com.raycast.macos')

    return app and app:isFrontmost()
end

return Raycast
