ZPClass.Name = "Bomber Zombie"
ZPClass.Description = "Spawn with an infection bomb."
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