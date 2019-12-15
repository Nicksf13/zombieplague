ZPClass.Name = "HumanSuicideClassName"
ZPClass.Description = "HumanSuicideClassDescription"
ZPClass.MaxHealth = 50
ZPClass.PModel = "models/player/guerilla.mdl"
ZPClass.Speed = 230
ZPClass.RunSpeed = 240
ZPClass.CrouchSpeed = 0.4
ZPClass.Breath = 50
ZPClass.AbilityRecharge = 60
function ZPClass:Ability(ply)
	ply:Kill()
	local explosion = ents.Create("env_explosion") -- https://facepunch.com/showthread.php?t=1021105 / Brandan
	explosion:SetKeyValue("spawnflags", 144)
	explosion:SetKeyValue("iMagnitude", 15)
	explosion:SetKeyValue("iRadiusOverride", 256)
	explosion:SetPos(ply:GetPos())
	explosion:Spawn()
	explosion:Activate()
	explosion:Fire("explode","",0)
end

if(ZPClass:ShouldBeEnabled()) then
	ClassManager:AddZPClass("SuicideHuman", ZPClass, TEAM_HUMANS)
end