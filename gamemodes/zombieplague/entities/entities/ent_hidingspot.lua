AddCSLuaFile()

ENT.Base = "base_nextbot"
ENT.Type = "nextbot"

function ENT:Initialize()
	if CLIENT then return end

	self:SetSolid(SOLID_NONE)
	self:SetNoDraw(true)
end

function ENT:Health()
	return nil
end
function ENT:OnKilled()
	return false
end
function ENT:OnInjured()
	return false
end
function ENT:IsNPC()
	return false
end