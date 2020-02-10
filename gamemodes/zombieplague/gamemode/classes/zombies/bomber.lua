ZPClass.Name = "ZombieBomberClassName"
ZPClass.Description = "ZombieBomberClassDescription"
ZPClass.MaxHealth = 500
ZPClass.PModel = "models/player/zombie_classic.mdl"
ZPClass.Speed = 260
ZPClass.RunSpeed = 260
ZPClass.CrouchSpeed = 0.4
ZPClass.Gravity = 0.7
ZPClass.Breath = 50
function ZPClass:WeaponGive(ply)
	ply:Give(ZOMBIE_KNIFE)
end

ZPClass.Ability = ClassManager:CreateClassAbility(true, function(ply)
	local Weap = ply:GetWeapon("weapon_frag")
	if IsValid(Weap) then
		ply:GiveAmmo(1, Weap:GetPrimaryAmmoType(), true) 
	else
		ply:Give("weapon_frag")
	end
end)
ZPClass.Ability.Drain = 120
ZPClass.Ability.MaxAbilityPower = 120

if(ZPClass:ShouldBeEnabled()) then
	ClassManager:AddZPClass("BomberZombie", ZPClass, TEAM_ZOMBIES)
end