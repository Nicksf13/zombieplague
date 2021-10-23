ZPClass.Name = "ZombieLeechClassName"
ZPClass.Description = "ZombieLeechClassDescription"
ZPClass.MaxHealth = 1000
ZPClass.PModel = "models/player/soldier_stripped.mdl"
ZPClass.Speed = 260
ZPClass.RunSpeed = 280
ZPClass.CrouchSpeed = 0.5
ZPClass.Gravity = 0.7
ZPClass.InfectionFunction = function(Attacker, Infected)
	Attacker:SetHealth(Attacker:Health() + 500)
end
ClassManager:AddZPClass("LeechZombie", ZPClass, TEAM_ZOMBIES)