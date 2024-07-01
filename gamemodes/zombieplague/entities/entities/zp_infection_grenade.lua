AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "zp_grenade_base"
ENT.PrintName = "Zombie Plague Infection Grenade"
ENT.Author = "The Fire Fuchs"
ENT.Category = "Zombie Plague"
ENT.Mode = EXPLODE_ON_HIT_MODE

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	self:SetModel("models/weapons/w_bugbait.mdl")
end
function ENT:Explode()
	local Ply = self:GetOwner()

	self:EmitSound("weapons/bugbait/bugbait_impact1.wav")
	ParticleEffectManager:EmitExplosion(50, Color(0, 130, 0), self:GetPos())

	for Key, AliveHuman in pairs(RoundManager:GetAliveHumans()) do
		if self:Visible(AliveHuman) && self:GetPos():DistToSqr(AliveHuman:GetPos()) <= 20000 and !AliveHuman:IsSurvivor() then
			if !RoundManager:LastHuman() && !RoundManager:IsSpecialRound() then
				InfectionManager:Infect(AliveHuman, Ply)
			else
				AliveHuman:TakeDamage(10000, Ply, self)
			end
		end
	end

	self:Remove()
end

function ENT:OnHit()
	if !self.Armed then
		self:EmitSound("weapons/bugbait/bugbait_impact3.wav")
	end
end