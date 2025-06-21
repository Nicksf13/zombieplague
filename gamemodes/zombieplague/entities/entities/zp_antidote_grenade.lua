AddCSLuaFile()
 
ENT.Type = "anim"
ENT.Base = "zp_grenade_base"
ENT.PrintName = "Zombie Plague Antidote Grenade"
ENT.Author = "The Fire Fuchs"
ENT.Category = "Zombie Plague"
ENT.Mode = EXPLODE_ON_HIT_MODE

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	self:SetModel("models/Items/battery.mdl")
end

function ENT:Explode()
	local Ply = self:GetOwner()

	self:EmitSound("items/medshot4.wav")
	ParticleEffectManager:EmitExplosion(50, HUMANS_COLOR, self:GetPos())

	if !RoundManager:IsSpecialRound() && !RoundManager:LastZombie() then
		for Key, AliveZombie in pairs(RoundManager:GetAliveZombies()) do
			if self:Visible(AliveZombie) && self:GetPos():DistToSqr(AliveZombie:GetPos()) <= 20000 and !AliveZombie:IsNemesis() then
				InfectionManager:Cure(AliveZombie, Ply)
				Ply:GiveAmmoPacks(cvars.Number("zp_ap_cure_zombie", 3))
			end
		end
	end

	self:Remove()
end

function ENT:OnHit()
	if !self.Armed then
		self:EmitSound("weapons/shotgun/shotgun_empty.wav")
	end
end