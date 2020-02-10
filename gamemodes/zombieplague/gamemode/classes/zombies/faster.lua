ZPClass.Name = "ZombieFasterClassName"
ZPClass.Description = "ZombieFasterClassDescription"
ZPClass.MaxHealth = 500
ZPClass.PModel = "models/player/skeleton.mdl"
ZPClass.Speed = 200
ZPClass.RunSpeed = 250
ZPClass.CrouchSpeed = 0.6
ZPClass.Gravity = 1
ZPClass.Breath = 50

local ActivationAction = function(ply)
	ply.OldHealth = ply:Health()
	ply.OldMaxHealth = ply:GetMaxHealth()
	ply.OldSpeed = ply:GetWalkSpeed()
	ply.OldRunSpeed = ply:GetRunSpeed()
	ply:SetHealth(50)
	ply:SetMaxHealth(50)
	ply:SetWalkSpeed(500)
	ply:SetRunSpeed(600)
end
local ResetAction = function(ply)
	ply:SetHealth(ply.OldHealth)
	ply:SetMaxHealth(ply.OldMaxHealth)
	ply:SetWalkSpeed(ply.OldSpeed)
	ply:SetRunSpeed(ply.OldRunSpeed)

	ply.OldHealth = nil
	ply.OldMaxHealth = nil
	ply.OldSpeed = nil
	ply.OldRunSpeed = nil
end
ZPClass.Ability = ClassManager:CreateClassAbility(true, ActivationAction, ResetAction, 30)

if(ZPClass:ShouldBeEnabled()) then
	ClassManager:AddZPClass("FasterZombie", ZPClass, TEAM_ZOMBIES)
end