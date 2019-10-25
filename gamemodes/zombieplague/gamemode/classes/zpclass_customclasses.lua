ClassManager:AddZombieClass({Name = "Crouch Zombie",
		MaxHealth = 500,
		PModel = "models/player/zombie_classic.mdl",
		Speed = 210,
		RunSpeed = 230,
		CrouchSpeed = 1.4,
		Gravity = 1,
		Breath = 50,
	})
ClassManager:AddZombieClass({Name = "Jumper Zombie",
		MaxHealth = 500,
		PModel = "models/player/zombie_classic.mdl",
		Speed = 250,
		RunSpeed = 260,
		CrouchSpeed = 1,
		Gravity = 1,
		JumpPower = 400,
		Breath = 50,
	})
local CamouflageZombie = {Name = "Camouflage Zombie",
		MaxHealth = 100,
		PModel = "models/player/barney.mdl",
		Speed = 240,
		RunSpeed = 250,
		CrouchSpeed = 0.4,
		Gravity = 1,
		Breath = 100,
	}
function CamouflageZombie:WeaponGive(ply)
	timer.Create("Teste", 1, 1, function() ply:GiveZombieAllowedWeapon(HUMAN_KNIFE) end)
end
ClassManager:AddZombieClass(CamouflageZombie)