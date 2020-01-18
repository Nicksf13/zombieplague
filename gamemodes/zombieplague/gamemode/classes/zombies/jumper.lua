ZPClass.Name = "ZombieJumperClassName"
ZPClass.Description = "ZombieJumperClassDescription"
ZPClass.MaxHealth = 150
ZPClass.PModel = "models/player/zombie_classic.mdl"
ZPClass.Speed = 240
ZPClass.RunSpeed = 260
ZPClass.CrouchSpeed = 0.5
ZPClass.Gravity = 1
ZPClass.Breath = 50
ZPClass.AbilityRecharge = 30
function ZPClass:Ability(ply)
	local OldJumpPower = ply:GetJumpPower()
	ply:SetJumpPower(400)
	
	local TimerName = "JumpPower" .. ply:SteamID64()
	timer.Create(TimerName, 10, 1, function()
		ply:SetJumpPower(OldJumpPower)
	end)

	local EventName = "ZPResetAbilityEvent" .. ply:SteamID64()
	hook.Add(EventName, TimerName, function()
		ply:SetNextAbilityUse(0)

		timer.Destroy(TimerName)
		hook.Remove(EventName, TimerName)
	end)
end

if(ZPClass:ShouldBeEnabled()) then
	ClassManager:AddZPClass("JumperZombie", ZPClass, TEAM_ZOMBIES)
end