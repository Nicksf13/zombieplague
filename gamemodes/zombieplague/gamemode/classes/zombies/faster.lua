ZPClass.Name = "ZombieFasterClassName"
ZPClass.Description = "ZombieFasterClassDescription"
ZPClass.MaxHealth = 500
ZPClass.PModel = "models/player/skeleton.mdl"
ZPClass.Speed = 200
ZPClass.RunSpeed = 250
ZPClass.CrouchSpeed = 0.6
ZPClass.Gravity = 1
ZPClass.Breath = 50
ZPClass.AbilityRecharge = 60
function ZPClass:Ability(ply)
	local OldHealth = ply:Health()
	local OldMaxHealth = ply:GetMaxHealth()
	local OldSpeed = ply:GetWalkSpeed()
	local OldRunSpeed = ply:GetRunSpeed()
	ply:SetHealth(50)
	ply:SetMaxHealth(50)
	ply:SetWalkSpeed(500)
	ply:SetRunSpeed(600)
	local TimerName = "Faster" .. ply:SteamID64()
	timer.Create(TimerName, 30, 1, function()
		ply:SetHealth(OldHealth)
		ply:SetMaxHealth(OldMaxHealth)
		ply:SetWalkSpeed(OldSpeed)
		ply:SetRunSpeed(OldRunSpeed)
	end)

	local EventName = "ZPResetAbilityEvent" .. ply:SteamID64()
	hook.Add(EventName, TimerName, function()
		ply:SetNextAbilityUse(0)

		timer.Destroy(TimerName)
		hook.Remove(EventName, TimerName)
	end)
end

if(ZPClass:ShouldBeEnabled()) then
	ClassManager:AddZPClass("FasterZombie", ZPClass, TEAM_ZOMBIES)
end