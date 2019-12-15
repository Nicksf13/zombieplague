ZPClass.Name = "ZombieBomberClassName"
ZPClass.Description = "ZombieBomberClassDescription"
ZPClass.MaxHealth = 50
ZPClass.PModel = "models/player/zombie_classic.mdl"
ZPClass.Speed = 240
ZPClass.RunSpeed = 250
ZPClass.CrouchSpeed = 0.4
ZPClass.Gravity = 0.85
ZPClass.Breath = 50
function ZPClass:WeaponGive(ply)
	ply:Give(ZOMBIE_KNIFE)
	ply:Give(INFECTION_BOMB)
end

if(ZPClass:ShouldBeEnabled()) then
	ClassManager:AddZPClass("BomberZombie", ZPClass, TEAM_ZOMBIES)
end