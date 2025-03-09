ZPClass.Name = "HumanLightClassName"
ZPClass.Description = "HumanLightClassDescription"
ZPClass.MaxHealth = 50
ZPClass.Armor = 0
ZPClass.PModel = "models/player/urban.mdl"
ZPClass.Speed = 220
ZPClass.RunSpeed = 100
ZPClass.CrouchSpeed = 0.5
ZPClass.Gravity = 0.7
ZPClass.JumpPower = 220
ZPClass.Battery = 50
ZPClass.Breath = 50
ZPClass.FallFunction = function()return false end
ClassManager:AddZPClass("LightHuman", ZPClass, TEAM_HUMANS)