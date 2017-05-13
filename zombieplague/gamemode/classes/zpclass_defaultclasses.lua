ClassManager:AddHumanClass({Name = "Heavy Human",
		MaxHealth = 150,
		Armor = 50,
		PModel = "models/player/barney.mdl",
		Speed = 190,
		RunSpeed = 210,
		CrouchSpeed = 0.3,
		Gravity = 1.1,
		Battery = 200,
		Breath = 150,
	}
)
ClassManager:AddHumanClass({Name = "Fast Human",
		MaxHealth = 50,
		PModel = "models/player/alyx.mdl",
		Speed = 260,
		RunSpeed = 290,
		CrouchSpeed = 0.4,
		Gravity = 1,
		Battery = 50,
		Breath = 150,
	}
)
ClassManager:AddHumanClass({Name = "Crouch Human",
		MaxHealth = 50,
		PModel = "models/player/alyx.mdl",
		Speed = 210,
		RunSpeed = 230,
		CrouchSpeed = 1.2,
		Gravity = 1,
		Battery = 100,
		Breath = 100,
	}
)
ClassManager:AddHumanClass({Name = "Light Human",
		MaxHealth = 100,
		PModel = "models/player/p2_chell.mdl",
		Speed = 240,
		RunSpeed = 250,
		CrouchSpeed = 0.4,
		Gravity = 0.5,
		Battery = 50,
		Breath = 50,
		FallFunction = function()return false end
	}
)


-------------------------------------------Zombies-------------------------------------------
ClassManager:AddZombieClass({Name = "Heavy Zombie",
		MaxHealth = 4000,
		PModel = "models/player/zombie_soldier.mdl",
		Speed = 210,
		RunSpeed = 230,
		CrouchSpeed = 0.5,
		Gravity = 1.1,
		Breath = 150,
	}
)
ClassManager:AddZombieClass({Name = "Fast Zombie",
		MaxHealth = 500,
		PModel = "models/player/zombie_fast.mdl",
		Speed = 270,
		RunSpeed = 290,
		CrouchSpeed = 0.5,
		Gravity = 1,
		Breath = 150,
	}
)
ClassManager:AddZombieClass({Name = "Faster Zombie",
		MaxHealth = 100,
		PModel = "models/player/skeleton.mdl",
		Speed = 450,
		RunSpeed = 500,
		CrouchSpeed = 0.4,
		Gravity = 1,
		Breath = 50,
	}
)
ClassManager:AddZombieClass({Name = "Crouch Zombie",
		MaxHealth = 500,
		PModel = "models/player/corpse1.mdl",
		Speed = 210,
		RunSpeed = 230,
		CrouchSpeed = 1.2,
		Gravity = 1,
		Breath = 50,
	}
)
ClassManager:AddZombieClass({Name = "Light Zombie",
		MaxHealth = 1000,
		PModel = "models/player/charple.mdl",
		Speed = 230,
		RunSpeed = 240,
		CrouchSpeed = 0.4,
		Gravity = 0.5,
		Breath = 50,
		FallFunction = function()return false end
	}
)
ClassManager:AddZombieClass({Name = "Leech Zombie",
		MaxHealth = 500,
		PModel = "models/player/soldier_stripped.mdl",
		Speed = 240,
		RunSpeed = 260,
		CrouchSpeed = 0.5,
		Gravity = 1,
		Breath = 100,
		InfectionFunction = function(Attacker)
			Attacker:SetHealth(Attacker:Health() + 250)
		end
	}
)