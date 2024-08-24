AddCSLuaFile()

ENT.Type = "point"

function ENT:Initialize()
	if CLIENT then return end

	self:SetSolid(SOLID_NONE)
	self:SetNoDraw(true)
	self:SetModel("models/player.mdl")
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