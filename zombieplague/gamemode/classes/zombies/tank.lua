ZPClass.Name = "Tank Zombie"
ZPClass.Description = "Can enable god mode to protect himself."
ZPClass.MaxHealth = 4000
ZPClass.PModel = "models/player/zombie_classic.mdl"
ZPClass.Speed = 170
ZPClass.RunSpeed = 170
ZPClass.CrouchSpeed = 0.4
ZPClass.Gravity = 1.5
ZPClass.Breath = 50
ZPClass.AbilityRecharge = 45
function ZPClass:Ability(ply)
	print("Usando habilidade")
	ply:GodEnable()
	timer.Create("GodMode" .. ply:SteamID64(), 10, 1, function()
		if IsValid(ply) then
			ply:GodDisable()
		end
	end)
end