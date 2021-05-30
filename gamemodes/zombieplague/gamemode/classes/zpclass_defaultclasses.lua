local ZPClass = ClassManager:NewHumanClass()
ZPClass.Order = 0
ClassManager:AddZPClass("DefaultHuman", ZPClass, TEAM_HUMANS)

ZPClass = ClassManager:NewHumanClass()
ZPClass.Name = "HumanHeavyClassName"
ZPClass.Description = "HumanHeavyClassDescription"
ZPClass.MaxHealth = 150
ZPClass.Armor = 100
ZPClass.PModel = "models/player/combine_super_soldier.mdl"
ZPClass.Speed = 210
ZPClass.RunSpeed = 100
ZPClass.CrouchSpeed = 0.3
ZPClass.Gravity = 1.2
ZPClass.Battery = 200
ZPClass.Breath = 150
ClassManager:AddZPClass("HeavyHuman", ZPClass, TEAM_HUMANS)

ZPClass = ClassManager:NewHumanClass()
ZPClass.Name = "HumanSpeedClassName"
ZPClass.Description = "HumanSpeedClassDescription"
ZPClass.MaxHealth = 50
ZPClass.Armor = 0
ZPClass.PModel = "models/player/riot.mdl"
ZPClass.Speed = 270
ZPClass.RunSpeed = 100
ZPClass.CrouchSpeed = 0.4
ZPClass.Gravity = 1
ZPClass.Battery = 50
ZPClass.Breath = 150
ClassManager:AddZPClass("SpeedHuman", ZPClass, TEAM_HUMANS)

ZPClass = ClassManager:NewHumanClass()
ZPClass.Name = "HumanCrouchClassName"
ZPClass.Description = "HumanCrouchClassDescription"
ZPClass.MaxHealth = 50
ZPClass.Armor = 0
ZPClass.PModel = "models/player/swat.mdl"
ZPClass.Speed = 220
ZPClass.RunSpeed = 100
ZPClass.CrouchSpeed = 1.5
ZPClass.Gravity = 0.8
ClassManager:AddZPClass("CrouchHuman", ZPClass, TEAM_HUMANS)

ZPClass = ClassManager:NewHumanClass()
ZPClass.Name = "HumanLightClassName"
ZPClass.Description = "HumanLightClassDescription"
ZPClass.MaxHealth = 50
ZPClass.Armor = 0
ZPClass.PModel = "models/player/urban.mdl"
ZPClass.Speed = 220
ZPClass.RunSpeed = 100
ZPClass.CrouchSpeed = 0.5
ZPClass.Gravity = 0.5
ZPClass.Battery = 50
ZPClass.Breath = 50
ZPClass.FallFunction = function()return false end
ClassManager:AddZPClass("LightHuman", ZPClass, TEAM_HUMANS)

-------------------------------------------Zombies-------------------------------------------
ZPClass = ClassManager:NewZombieClass()
ZPClass.Order = 0
ClassManager:AddZPClass("DefaultZombie", ZPClass, TEAM_ZOMBIES)

ZPClass = ClassManager:NewZombieClass()
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

ZPClass = ClassManager:NewZombieClass()
ZPClass.Name = "ZombieSpeedClassName"
ZPClass.Description = "ZombieSpeedClassDescription"
ZPClass.MaxHealth = 500
ZPClass.PModel = "models/player/zombie_fast.mdl"
ZPClass.Speed = 320
ZPClass.RunSpeed = 340
ZPClass.CrouchSpeed = 0.5
ZPClass.Gravity = 0.7
ZPClass.Breath = 250
ClassManager:AddZPClass("SpeedZombie", ZPClass, TEAM_ZOMBIES)

ZPClass = ClassManager:NewZombieClass()
ZPClass.Name = "ZombieCrouchClassName"
ZPClass.Description = "ZombieCrouchClassDescription"
ZPClass.MaxHealth = 500
ZPClass.PModel = "models/player/corpse1.mdl"
ZPClass.Speed = 260
ZPClass.RunSpeed = 280
ZPClass.CrouchSpeed = 1.7
ZPClass.Gravity = 0.7
ZPClass.Breath = 50
ClassManager:AddZPClass("CrouchZombie", ZPClass, TEAM_ZOMBIES)

ZPClass = ClassManager:NewZombieClass()
ZPClass.Name = "ZombieLightClassName"
ZPClass.Description = "ZombieLightClassDescription"
ZPClass.MaxHealth = 1000
ZPClass.PModel = "models/player/charple.mdl"
ZPClass.Speed = 270
ZPClass.RunSpeed = 290
ZPClass.CrouchSpeed = 0.4
ZPClass.Gravity = 0.3
ZPClass.Breath = 50
ClassManager:AddZPClass("LightZombie", ZPClass, TEAM_ZOMBIES)

ZPClass = ClassManager:NewZombieClass()
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