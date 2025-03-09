ParticleEffectManager = {}
 
function ParticleEffectManager:EmitExplosion(ParticleAmount, Color, Pos)
    local Explosion = {
        Pos = Pos,
        ParticleInformations = {}
    }

    for i = 1, ParticleAmount do
        table.insert(Explosion.ParticleInformations, self:CreateExplosionParticleEffect(Color))
    end

    self:EmitParticleEffect(Explosion)
end
function ParticleEffectManager:CreateExplosionParticleEffect(Color)
    local RandomX = math.random(-250, 250)
    local RandomY = math.random(-250, 250)
    local ParticleInformation = {
        File =  "particle/smokesprites_000" .. math.random(1, 9),
        Gravity =  Vector(0, 0, -250),
        Velocity = Vector(RandomX, RandomY, 0),
        DieTime = math.Rand(5, 10),
        StartAlpha = 40,
        EndAlpha = 0,
        StartSize = 100,
        EndSize = 20,
        Color = Color
    }

    return ParticleInformation
end

function ParticleEffectManager:EmitParticleEffect(ParticleInformation)
    net.Start("SendParticleEffectInformation")
        net.WriteTable(ParticleInformation)
    net.Broadcast()
end

util.AddNetworkString("SendParticleEffectInformation")