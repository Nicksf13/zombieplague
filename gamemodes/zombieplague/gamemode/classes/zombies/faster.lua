ZPClass.Name = "ZombieFasterClassName"
ZPClass.Description = "ZombieFasterClassDescription"
ZPClass.MaxHealth = 500
ZPClass.PModel = "models/player/skeleton.mdl"
ZPClass.Speed = 260
ZPClass.RunSpeed = 260
ZPClass.CrouchSpeed = 0.6
ZPClass.Gravity = 0.7
ZPClass.Breath = 50
ZPClass.AbilityRecharge = 60
function ZPClass:Ability(ply)
	local OldHealth = ply:Health()
	local OldMaxHealth = ply:GetMaxHealth()
	local OldSpeed = ply:GetWalkSpeed()
	local OldRunSpeed = ply:GetRunSpeed()
	ply:SetHealth(150)
	ply:SetMaxHealth(150)
	ply:SetWalkSpeed(600)
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
