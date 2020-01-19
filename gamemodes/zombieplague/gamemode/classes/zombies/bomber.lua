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
	ply:GiveZombieAllowedWeapon(INFECTION_BOMB)
end

if(ZPClass:ShouldBeEnabled()) then
	ClassManager:AddZPClass("BomberZombie", ZPClass, TEAM_ZOMBIES)
end