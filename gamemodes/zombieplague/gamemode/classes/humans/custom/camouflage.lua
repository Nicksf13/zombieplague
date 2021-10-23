ZPClass.Name = "HumanCamouflageClassName"
ZPClass.Description = "HumanCamouflageClassDescription"
ZPClass.MaxHealth = 50
ZPClass.PModel = "models/player/riot.mdl"
ZPClass.Speed = 210
ZPClass.RunSpeed = 100
ZPClass.CrouchSpeed = 0.4
ZPClass.Gravity = 1
ZPClass.Breath = 50

local ActivationAction = function(ply)
	local AuxClass = table.Random(RoundManager:GetAliveZombies()):GetZombieClass()
	ply:SetWalkSpeed(AuxClass.Speed)
	ply:SetRunSpeed(AuxClass.RunSpeed)
	ply:SetCrouchedWalkSpeed(AuxClass.CrouchSpeed)
	ply:SetModel(AuxClass.PModel)
	ply:SetupHands()
	ply:SetAuxGravity(AuxClass.Gravity)
	ply:Give(ZOMBIE_KNIFE)
end
local ResetAction = function(ply)
	local ZPClass = ply:GetHumanClass()
	ply:SetHealth(ZPClass.MaxHealth)
	ply:SetWalkSpeed(ZPClass.Speed)
	ply:SetRunSpeed(ZPClass.RunSpeed)
	ply:SetCrouchedWalkSpeed(ZPClass.CrouchSpeed)
	ply:SetModel(ZPClass.PModel)
	ply:SetupHands()
	ply:SetAuxGravity(ZPClass.Gravity)
end
ZPClass.Ability = ClassManager:CreateClassAbility(true, ActivationAction, ResetAction, 30)
ZPClass.Ability.CanUseAbility = function()
	return RoundManager:GetRoundState() == ROUND_PLAYING && RoundManager:CountZombiesAlive() > 0
end

if(ZPClass:ShouldBeEnabled()) then
	ClassManager:AddZPClass("CamouflageHuman", ZPClass, TEAM_HUMANS)
end