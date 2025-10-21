local Media = {}
Media.__index = Media

function Media.toggleAudio()
    if is.In(teams) then
        ks.shiftCmd('m')
    else
        ks.shiftCmd('a')
    end
end

function Media.toggleScreenShare()
    if is.In(teams) then
        ks.shiftCmd('v')
    else
        ks.shiftCmd('s')
    end
end

function Media.toggleVideo()
    if is.In(teams) then
        ks.shiftCmd('o')
    else
        ks.shiftCmd('v')
    end
end

function Media.toggleAudioAndVideo()
    Media.toggleAudio()
    Media.toggleVideo()
end

return Media
