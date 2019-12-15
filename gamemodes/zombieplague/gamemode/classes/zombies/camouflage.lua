ZPClass.Name = "ZombieCamouflageClassName"
ZPClass.Description = "ZombieCamouflageClassDescription"
ZPClass.MaxHealth = 300
ZPClass.PModel = "models/player/zombie_classic.mdl"
ZPClass.Speed = 230
ZPClass.RunSpeed = 250
ZPClass.CrouchSpeed = 0.4
ZPClass.Gravity = 1
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
	ply:SetAuxGravity(AuxClass.Gravity)
	ply:GiveZombieAllowedWeapon(MeleeWeapon)
	timer.Create("Camouflage" .. ply:SteamID64(), 30, 1, function()
		if IsValid(ply) && ply:IsZombie() then
			local ZPClass = ply:GetZombieClass()
			ply:SetHealth(ZPClass.MaxHealth)
			ply:SetWalkSpeed(ZPClass.Speed)
			ply:SetRunSpeed(ZPClass.RunSpeed)
			ply:SetCrouchedWalkSpeed(ZPClass.CrouchSpeed)
			ply:SetModel(ZPClass.PModel)
			ply:SetAuxGravity(ZPClass.Gravity)
			ply:RemoveZombieAllowedWeapon(MeleeWeapon)
			ply:Give(ZOMBIE_KNIFE)
		end
	end)
end

if(ZPClass:ShouldBeEnabled()) then
	ClassManager:AddZPClass("CamouflageZombie", ZPClass, TEAM_ZOMBIES)
end