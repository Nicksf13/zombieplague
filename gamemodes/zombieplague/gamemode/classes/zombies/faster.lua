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
	ply.OldHealth = ply:Health()
	ply.OldSpeed = ply:GetWalkSpeed()
	ply.OldRunSpeed = ply:GetRunSpeed()
	ply:SetHealth(50)
	ply:SetWalkSpeed(500)
	ply:SetRunSpeed(600)
	timer.Create("Faster" .. ply:SteamID64(), 30, 1, function()
		if IsValid(ply) && ply:IsZombie() then
			ply:SetHealth(ply.OldHealth)
			ply:SetWalkSpeed(ply.OldSpeed)
			ply:SetRunSpeed(ply.OldRunSpeed)
		end
	end)
end