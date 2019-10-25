ClassManager:AddHumanClass(ClassManager:NewHumanClass())

local ZPClass = ClassManager:NewHumanClass()
ZPClass.Name = "Heavy Human"
ZPClass.Description = "Stay safe from zombies with his armor."
ZPClass.MaxHealth = 150
ZPClass.Armor = 100
ZPClass.PModel = HumanClass.PModel or "models/player/combine_super_soldier.mdl"
ZPClass.Speed = 190
ZPClass.RunSpeed = 200
ZPClass.CrouchSpeed = 0.3
ZPClass.Gravity = 1.2
ZPClass.Battery = 200
ZPClass.Breath = 150
ClassManager:AddHumanClass(ZPClass)

ZPClass = ClassManager:NewHumanClass()
ZPClass.Name = "Fast Human"
ZPClass.Description = "Have more speed"
ZPClass.MaxHealth = 50
ZPClass.PModel = "models/player/riot.mdl"
ZPClass.Speed = 270
ZPClass.RunSpeed = 290
ZPClass.CrouchSpeed = 0.4
ZPClass.Gravity = 1
ZPClass.Battery = 50
ZPClass.Breath = 150
ClassManager:AddHumanClass(ZPClass)

ZPClass = ClassManager:NewHumanClass()
ZPClass.Name = "Crouch Human"
ZPClass.Description = "Can walk faster when crouched."
ZPClass.MaxHealth = 50
ZPClass.PModel = "models/player/swat.mdl"
ZPClass.Speed = 210
ZPClass.RunSpeed = 230
ZPClass.CrouchSpeed = 1.5
ClassManager:AddHumanClass(ZPClass)

ZPClass = ClassManager:NewHumanClass()
ZPClass.Name = "Light Human"
ZPClass.Description = "Low gravity and no fall damage."
ZPClass.MaxHealth = 100
ZPClass.PModel = "models/player/urban.mdl"
ZPClass.Gravity = 0.5
ZPClass.Battery = 50
ZPClass.Breath = 50
ZPClass.FallFunction = function()return false end
ClassManager:AddHumanClass(ZPClass)

-------------------------------------------Zombies-------------------------------------------
ClassManager:AddHumanClass(ClassManager:NewZombieClass())

ZPClass = ClassManager:NewZombieClass()
ZPClass.Name = "Heavy Zombie"
ZPClass.Description = "A walking wall."
ZPClass.MaxHealth = 4000
ZPClass.PModel = "models/player/zombie_soldier.mdl"
ZPClass.Speed = 200
ZPClass.RunSpeed = 220
ZPClass.CrouchSpeed = 0.6
ZPClass.Gravity = 1.2
ZPClass.Breath = 200
ZPClass.FallFunction = function()return true end
ClassManager:AddZombieClass(ZPClass)

ZPClass = ClassManager:NewZombieClass()
ZPClass.Name = "Fast Zombie"
ZPClass.Description = "Run to seek humans."
ZPClass.MaxHealth = 500
ZPClass.PModel = "models/player/zombie_fast.mdl"
ZPClass.Speed = 270
ZPClass.RunSpeed = 290
ZPClass.CrouchSpeed = 0.5
ZPClass.Gravity = 0.9
ZPClass.Breath = 250
ClassManager:AddZombieClass(ZPClass)

ZPClass = ClassManager:NewZombieClass()
ZPClass.Name = "Crouch Zombie",
ZPClass.Description = "Can walk faster when crouched."
ZPClass.MaxHealth = 350
ZPClass.PModel = "models/player/corpse1.mdl"
ZPClass.Speed = 200
ZPClass.RunSpeed = 220
ZPClass.CrouchSpeed = 1.5
ZPClass.Gravity = 1
ZPClass.Breath = 50
ClassManager:AddZombieClass(ZPClass)

ZPClass = ClassManager:NewZombieClass()
ZPClass.Name = "Light Zombie"
ZPClass.Description = "Low gravity and no fall damage."
ZPClass.MaxHealth = 1000
ZPClass.PModel = "models/player/charple.mdl"
ZPClass.Speed = 220
ZPClass.RunSpeed = 230
ZPClass.CrouchSpeed = 0.4
ZPClass.Gravity = 0.5
ZPClass.Breath = 50
ClassManager:AddZombieClass(ZPClass)

ZPClass = ClassManager:NewZombieClass()
ZPClass.HPReward = 250
ZPClass.Name = "Leech Zombie"
ZPClass.Description = "Earn " .. ZPClass.HPReward .. " HP for every human infected."
ZPClass.MaxHealth = 500
ZPClass.PModel = "models/player/soldier_stripped.mdl"
ZPClass.CrouchSpeed = 0.5
function ZPClass:InfectionFunction(Attacker)
	Attacker:SetHealth(Attacker:Health() + self.HPReward)
end
ClassManager:AddZombieClass(ZPClass)