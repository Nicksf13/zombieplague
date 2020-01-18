ZPClass.Name = "ZombieTankClassName"
ZPClass.Description = "ZombieTankClassDescription"
ZPClass.MaxHealth = 4000
ZPClass.PModel = "models/player/zombie_classic.mdl"
ZPClass.Speed = 170
ZPClass.RunSpeed = 170
ZPClass.CrouchSpeed = 0.4
ZPClass.Gravity = 1.5
ZPClass.Breath = 50
ZPClass.AbilityRecharge = 45
function ZPClass:Ability(ply)
	ply:ZombieMadness()
end

if(ZPClass:ShouldBeEnabled()) then
	ClassManager:AddZPClass("TankZombie", ZPClass, TEAM_ZOMBIES)
end