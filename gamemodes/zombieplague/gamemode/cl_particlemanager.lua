ParticleEffectManager = {}
 
function ParticleEffectManager:EmitParticleEffect(ParticleEffectInformation)
    local Emitter = ParticleEmitter(ParticleEffectInformation.Pos)
    local ParticleInformations = ParticleEffectInformation.ParticleInformations

    for Key, Info in pairs(ParticleInformations) do
        local EffectColor = Info.Color
        local Particle = Emitter:Add(Info.File, ParticleEffectInformation.Pos)
        Particle:SetVelocity(Info.Velocity)
        Particle:SetDieTime(Info.DieTime)
        Particle:SetStartAlpha(Info.StartAlpha)
        Particle:SetEndAlpha(Info.EndAlpha)
        Particle:SetStartSize(Info.StartSize)
        Particle:SetEndSize(Info.EndSize)
        Particle:SetColor(EffectColor.r, EffectColor.g, EffectColor.b) 
        Particle:SetAirResistance(100) 
        Particle:SetCollide(true)
    end

    Emitter:Finish()
end

net.Receive("SendParticleEffectInformation", function()
    local ParticleEffectInformation = net.ReadTable()

    ParticleEffectManager:EmitParticleEffect(ParticleEffectInformation)
end)