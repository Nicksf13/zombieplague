SoundManager = {
    Sounds = {}
}

function SoundManager:EmitLoopSound(SoundId, SoundPath, SoundDuration)
    local TimerName = SoundId .. "Timer"

    SoundManager:PlaySound(SoundId, SoundPath, SoundDuration)
    timer.Create(TimerName, SoundDuration, 0, function()
        SoundManager:PlaySound(SoundId, SoundPath, SoundDuration)
    end)
end
function SoundManager:PlaySound(SoundId, SoundPath, SoundDuration)
    local SoundData = SoundManager.Sounds[SoundId]

    if SoundData then
        SoundData.LoopSound:Stop()
    end

    local LoopSound = CreateSound(LocalPlayer(), SoundPath)

    LoopSound:SetSoundLevel(0)
    LoopSound:Play()

    local SoundData = {
        LoopSound = LoopSound,
        TimerName = TimerName
    }

    SoundManager.Sounds[SoundId] = SoundData
end
function SoundManager:StopLoopSound(SoundId)
    local SoundData = SoundManager.Sounds[SoundId]

    if SoundData then
        local LoopSound = SoundData.LoopSound
        local TimerName = SoundData.TimerName

        LoopSound:Stop()
        timer.Remove(TimerName)

        SoundManager.Sounds[SoundId] = nil
    end
end

net.Receive("EmitLoopSound", function()
    local SoundId = net.ReadString()
    local SoundPath = net.ReadString()
    local SoundDuration = net.ReadInt(32)

    SoundManager:EmitLoopSound(SoundId, SoundPath, SoundDuration)
end)

net.Receive("StopLoopSound", function()
    local SoundId = net.ReadString()
end)