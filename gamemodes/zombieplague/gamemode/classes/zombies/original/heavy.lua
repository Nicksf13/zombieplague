ZPClass.Name = "ZombieHeavyClassName"
ZPClass.Description = "ZombieHeavyClassDescription"
ZPClass.MaxHealth = 4000
ZPClass.PModel = "models/player/zombie_soldier.mdl"
ZPClass.Speed = 230
ZPClass.RunSpeed = 250
ZPClass.CrouchSpeed = 0.6
ZPClass.Gravity = 0.9
ZPClass.Breath = 200
ZPClass.Scale = 1.1
ZPClass.FallFunction = function()return true end
ClassManager:AddZPClass("HeavyZombie", ZPClass, TEAM_ZOMBIES)