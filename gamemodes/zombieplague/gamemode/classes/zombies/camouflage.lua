ZPClass.Name = "ZombieCamouflageClassName"
ZPClass.Description = "ZombieCamouflageClassDescription"
ZPClass.MaxHealth = 500
ZPClass.PModel = "models/player/zombie_classic.mdl"
ZPClass.Speed = 260
ZPClass.RunSpeed = 260
ZPClass.CrouchSpeed = 0.4
ZPClass.Gravity = 0.8
ZPClass.Breath = 50
ZPClass.AbilityRecharge = 45
function ZPClass:Ability(ply)
	local MeleeWeapon = table.Random(WeaponManager:GetWeaponsTableByWeaponType(WEAPON_MELEE)).WeaponID
	local AuxClass = table.Random(RoundManager:GetAliveHumans()):GetHumanClass()
	ply:SetHealth(AuxClass.MaxHealth)
	ply:SetWalkSpeed(AuxClass.Speed)
	ply:SetRunSpeed(AuxClass.RunSpeed)
	ply:SetCrouchedWalkSpeed(AuxClass.CrouchSpeed)
	ply:SetModel(AuxClass.PModel)
	ply:SetupHands()
	ply:SetAuxGravity(AuxClass.Gravity)
	ply:GiveZombieAllowedWeapon(MeleeWeapon)
	local TimerName = "Camouflage" .. ply:SteamID64()
	timer.Create(TimerName, 30, 1, function()
		local ZPClass = ply:GetZombieClass()
		ply:SetHealth(ZPClass.MaxHealth)
		ply:SetWalkSpeed(ZPClass.Speed)
		ply:SetRunSpeed(ZPClass.RunSpeed)
		ply:SetCrouchedWalkSpeed(ZPClass.CrouchSpeed)
		ply:SetModel(ZPClass.PModel)
		ply:SetupHands()
		ply:SetAuxGravity(ZPClass.Gravity)
		ply:RemoveZombieAllowedWeapon(MeleeWeapon)
		ply:Give(ZOMBIE_KNIFE)
	end)

	local EventName = "ZPResetAbilityEvent" .. ply:SteamID64()
	hook.Add(EventName, TimerName, function()
		ply:SetNextAbilityUse(0)

		timer.Destroy(TimerName)
		hook.Remove(EventName, TimerName)
	end)
end
function ZPClass:CanUseAbility()
	return RoundManager:GetRoundState() == ROUND_PLAYING && RoundManager:CountHumansAlive() > 0
end

if(ZPClass:ShouldBeEnabled()) then
	ClassManager:AddZPClass("CamouflageZombie", ZPClass, TEAM_ZOMBIES)
end