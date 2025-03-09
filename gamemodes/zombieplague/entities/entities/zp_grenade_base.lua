AddCSLuaFile()
 
EXPLODE_ON_HIT_MODE = 0
ARM_ON_HIT_MODE = 1
TIME_MODE = 2

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Zombie Plague Base Grenade"
ENT.Author = "The Fire Fuchs"
ENT.Category = "Zombie Plague"
ENT.Mode = EXPLODE_ON_HIT_MODE

function ENT:Initialize()
    local Self = self
    self:SetModel("models/Items/grenadeAmmo.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetExplosionDelay(0)
end
function ENT:PhysicsCollide(Data, Phys)
    if self.Mode == EXPLODE_ON_HIT_MODE then
        self:Explode()
    elseif self.Mode == ARM_ON_HIT_MODE then
        self:OnHit()
        self:Arm()
    end
end
function ENT:SetMode(Mode)
    self.Mode = Mode
end
function ENT:SetExplosionDelay(ExplosionDelay)
    self.ExplosionDelay = ExplosionDelay
end
function ENT:OnHit()
end
function ENT:GetExplosionDelay()
    return self.ExplosionDelay
end
function ENT:Explode()
    self:Remove()
end
function ENT:Arm()
    self.Armed = true
    local Timer = "ZPGrenade" .. self.PrintName .. CurTime()
    if !self.Timer then
        timer.Create(Timer, 2, 1, function()
                self:Explode()
        end)
    end

    self.Timer = Timer
end

if SERVER then
    function ENT:Think()
       if not self.FirstThink then
          self:PhysWake()
          self.FirstThink = true
          self.Think = nil
       end
    end
end