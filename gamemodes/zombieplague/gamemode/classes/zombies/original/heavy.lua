ZPClass.Name = "ZombieHeavyClassName"
ZPClass.Description = "ZombieHeavyClassDescription"
ZPClass.MaxHealth = 4000
ZPClass.PModel = "models/player/zombie_soldier.mdl"
ZPClass.Speed = 250
ZPClass.RunSpeed = 100
ZPClass.CrouchSpeed = 0.6
ZPClass.Gravity = 0.9
ZPClass.Breath = 200
ZPClass.Scale = 1
ZPClass.FallFunction = function()return true end
ClassManager:AddZPClass("HeavyZombie", ZPClass, TEAM_ZOMBIES)