ZPClass.Name = "ZombieTankClassName"
ZPClass.Description = "ZombieTankClassDescription"
ZPClass.MaxHealth = 3000
ZPClass.PModel = "models/player/zombie_classic.mdl"
ZPClass.Speed = 230
ZPClass.RunSpeed = 230
ZPClass.CrouchSpeed = 0.4
ZPClass.Gravity = 1.1
ZPClass.Breath = 50

ZPClass.Ability = ClassManager:CreateClassAbility(true, function(ply)
	ply:ZombieMadness()
end)
ZPClass.Ability.Drain = 45
ZPClass.Ability.MaxAbilityPower = 45

if(ZPClass:ShouldBeEnabled()) then
	ClassManager:AddZPClass("TankZombie", ZPClass, TEAM_ZOMBIES)
end