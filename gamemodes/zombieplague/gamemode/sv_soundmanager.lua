SoundManager = {}

function SoundManager:EmitLoopSound(SoundId, Sound)
    print(Sound.Path)
    print(Sound.Duration)
    net.Start("EmitLoopSound")
        net.WriteString(SoundId)
        net.WriteString(Sound.Path)
        net.WriteInt(Sound.Duration, 32)
    net.Broadcast()
end
function SoundManager:StopLoopSound(SoundId)
    net.Start("StopLoopSound")
        net.WriteString(SoundId)
    net.Broadcast()
end

util.AddNetworkString("EmitLoopSound")
util.AddNetworkString("StopLoopSound")