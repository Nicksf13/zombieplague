ZPClass.Name = "HumanSuicidalClassName"
ZPClass.Description = "HumanSuicidalClassDescription"
ZPClass.MaxHealth = 50
ZPClass.PModel = "models/player/guerilla.mdl"
ZPClass.Speed = 180
ZPClass.RunSpeed = 220
ZPClass.CrouchSpeed = 0.5
ZPClass.Gravity = 0.9
ZPClass.Breath = 50

local ActivationAction = function(ply)
	ply:SetArmor(ply:Armor() + 100)
	ply:SetWalkSpeed(290)
	ply:SetRunSpeed(290)

	local TimerNameWithSteamID64 = ply:SteamID64() .. "SuicideExplode"
	timer.Create(TimerNameWithSteamID64, 0.5, 12, function()
		local RepsLeft = timer.RepsLeft(TimerNameWithSteamID64)
		if RepsLeft == 0 then
			ply:Kill()
			local explosion = ents.Create("env_explosion") -- https://facepunch.com/showthread.php?t=1021105 / Brandan
			explosion:SetKeyValue("spawnflags", 144)
			explosion:SetKeyValue("iMagnitude", 2000)
			explosion:SetKeyValue("iRadiusOverride", 256)
			explosion:SetOwner(ply)
			explosion:SetPos(ply:GetPos())
			explosion:Spawn()
			explosion:Activate()
			explosion:Fire("explode","",0)
		elseif RepsLeft < 5 then
			ply:EmitSound("weapons/grenade/tick1.wav")
		elseif RepsLeft % 2 == 1 then
			ply:EmitSound("weapons/grenade/tick1.wav")
		end
	end)

	local EventName = "ZPResetAbilityEvent" .. ply:SteamID64()
	hook.Add(EventName, TimerNameWithSteamID64, function()
		timer.Destroy(TimerNameWithSteamID64)
		hook.Remove(EventName, TimerNameWithSteamID64)
	end)
end
ZPClass.Ability = ClassManager:CreateClassAbility(true, ActivationAction)
ZPClass.Ability.CanUseAbility = function()
	return RoundManager:GetRoundState() == ROUND_PLAYING && RoundManager:CountZombiesAlive() > 0
end

if(ZPClass:ShouldBeEnabled()) then
	ClassManager:AddZPClass("SuicideHuman", ZPClass, TEAM_HUMANS)
end