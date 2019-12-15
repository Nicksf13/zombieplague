ZPClass.Name = "HumanCamouflageClassName"
ZPClass.Description = "HumanCamouflageClassDescription"
ZPClass.MaxHealth = 50
ZPClass.PModel = "models/player/riot.mdl"
ZPClass.Speed = 220
ZPClass.RunSpeed = 240
ZPClass.CrouchSpeed = 0.4
ZPClass.Gravity = 1
ZPClass.Breath = 50
ZPClass.AbilityRecharge = 60
function ZPClass:Ability(ply)
	local AuxClass = table.Random(RoundManager:GetAliveZombies()):GetZombieClass()
	ply:SetHealth(AuxClass.MaxHealth)
	ply:SetWalkSpeed(AuxClass.Speed)
	ply:SetRunSpeed(AuxClass.RunSpeed)
	ply:SetCrouchedWalkSpeed(AuxClass.CrouchSpeed)
	ply:SetModel(AuxClass.PModel)
	ply:SetAuxGravity(AuxClass.Gravity)
	ply:Give(ZOMBIE_KNIFE)
	timer.Create("Camouflage" .. ply:SteamID64(), 30, 1, function()
		if IsValid(ply) && ply:IsHuman() then
			local ZPClass = ply:GetHumanClass()
			ply:SetHealth(ZPClass.MaxHealth)
			ply:SetWalkSpeed(ZPClass.Speed)
			ply:SetRunSpeed(ZPClass.RunSpeed)
			ply:SetCrouchedWalkSpeed(ZPClass.CrouchSpeed)
			ply:SetModel(ZPClass.PModel)
			ply:SetAuxGravity(ZPClass.Gravity)
		end
	end)
end

if(ZPClass:ShouldBeEnabled()) then
	ClassManager:AddZPClass("CamouflageHuman", ZPClass, TEAM_HUMANS)
end