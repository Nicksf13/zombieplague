ZPClass.Name = "ZombieLeechClassName"
ZPClass.Description = "ZombieLeechClassDescription"
ZPClass.MaxHealth = 1500
ZPClass.PModel = "models/player/soldier_stripped.mdl"
ZPClass.Speed = 280
ZPClass.RunSpeed = 100
ZPClass.CrouchSpeed = 0.5
ZPClass.Gravity = 0.7
ZPClass.InfectionFunction = function(Attacker, Infected)
	Attacker:SetHealth(Attacker:Health() + 500)
	--Attacker:AddPoints(3)
end
ClassManager:AddZPClass("LeechZombie", ZPClass, TEAM_ZOMBIES)