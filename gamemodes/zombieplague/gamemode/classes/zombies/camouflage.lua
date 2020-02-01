ZPClass.Name = "ZombieCamouflageClassName"
ZPClass.Description = "ZombieCamouflageClassDescription"
ZPClass.MaxHealth = 500
ZPClass.PModel = "models/player/zombie_classic.mdl"
ZPClass.Speed = 260
ZPClass.RunSpeed = 260
ZPClass.CrouchSpeed = 0.4
ZPClass.Gravity = 0.8
ZPClass.Breath = 50

local ActivationAction = function(ply)
	local AuxClass = table.Random(RoundManager:GetAliveHumans()):GetHumanClass()
	ply.CamouflageZombieWeapon = table.Random(WeaponManager:GetWeaponsTableByWeaponType(WEAPON_MELEE)).WeaponID
	ply:SetHealth(AuxClass.MaxHealth)
	ply:SetWalkSpeed(AuxClass.Speed)
	ply:SetRunSpeed(AuxClass.RunSpeed)
	ply:SetCrouchedWalkSpeed(AuxClass.CrouchSpeed)
	ply:SetModel(AuxClass.PModel)
	ply:SetupHands()
	ply:SetAuxGravity(AuxClass.Gravity)
	ply:GiveZombieAllowedWeapon(ply.CamouflageZombieWeapon)
end
local ResetAction = function(ply)
	local ZPClass = ply:GetZombieClass()
	ply:SetHealth(ZPClass.MaxHealth)
	ply:SetWalkSpeed(ZPClass.Speed)
	ply:SetRunSpeed(ZPClass.RunSpeed)
	ply:SetCrouchedWalkSpeed(ZPClass.CrouchSpeed)
	ply:SetModel(ZPClass.PModel)
	ply:SetupHands()
	ply:SetAuxGravity(ZPClass.Gravity)
	ply:RemoveZombieAllowedWeapon(ply.CamouflageZombieWeapon)
	ply.CamouflageZombieWeapon = nil
end
ZPClass.Ability = ClassManager:CreateClassAbility(true, ActivationAction, ResetAction, 30)
ZPClass.Ability.Drain = 45
ZPClass.Ability.MaxAbilityPower = 45
ZPClass.Ability.CanUseAbility = function()
	return RoundManager:GetRoundState() == ROUND_PLAYING && RoundManager:CountHumansAlive() > 0
end

if(ZPClass:ShouldBeEnabled()) then
	ClassManager:AddZPClass("CamouflageZombie", ZPClass, TEAM_ZOMBIES)
end