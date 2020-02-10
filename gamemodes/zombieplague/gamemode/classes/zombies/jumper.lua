ZPClass.Name = "ZombieJumperClassName"
ZPClass.Description = "ZombieJumperClassDescription"
ZPClass.MaxHealth = 150
ZPClass.PModel = "models/player/zombie_classic.mdl"
ZPClass.Speed = 240
ZPClass.RunSpeed = 260
ZPClass.CrouchSpeed = 0.5
ZPClass.Gravity = 1
ZPClass.Breath = 50

local ActivationAction = function(ply)
	ply.OldJumpPower = ply:GetJumpPower()
	ply:SetJumpPower(400)
end
local ResetAction = function(ply)
	ply:SetJumpPower(ply.OldJumpPower)
	ply.OldJumpPower = nil
end
ZPClass.Ability = ClassManager:CreateClassAbility(true, ActivationAction, ResetAction, 10)
ZPClass.Ability.Drain = 30
ZPClass.Ability.MaxAbilityPower = 30

if(ZPClass:ShouldBeEnabled()) then
	ClassManager:AddZPClass("JumperZombie", ZPClass, TEAM_ZOMBIES)
end