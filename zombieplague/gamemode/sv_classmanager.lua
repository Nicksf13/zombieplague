ClassManager = {
	ZombieClasses = {},
	HumanClasses = {}
}
function ClassManager:SearchClasses()
	ClassManager:AddZombieClass({})
	ClassManager:AddHumanClass({})
	local Files = file.Find("zombieplague/gamemode/classes/*.lua", "LUA")
	if Files != nil then
		for k, File in pairs(Files) do
			include("zombieplague/gamemode/classes/" .. File)
		end
	end
end
function ClassManager:GetZombieClasses()
	return ClassManager.ZombieClasses or {}
end
function ClassManager:GetHumanClasses()
	return ClassManager.HumanClasses or {}
end
function ClassManager:AddZombieClass(ZombieClass)
	local ZombieClassAux = {Name = ZombieClass.Name or "Zombie",
		MaxHealth = ZombieClass.MaxHealth or 2000,
		PModel = ZombieClass.PModel or "models/player/zombie_classic.mdl",
		Speed = ZombieClass.Speed or 250,
		RunSpeed = ZombieClass.RunSpeed or 260,
		CrouchSpeed = ZombieClass.CrouchSpeed or 0.4,
		Gravity = ZombieClass.Gravity or 1,
		Breath = ZombieClass.Breath or 100,
		Footstep = ZombieClass.Footstep or false,
		JumpPower = ZombieClass.JumpPower or 170,
		InfectionFunction = ZombieClass.InfectionFunction,
		FallFunction = ZombieClass.FallFunction or function()return false end
	}
	function ZombieClassAux:WeaponGive(ply)
		ply:GiveZombieAllowedWeapon(ZOMBIE_KNIFE)
	end
	resource.AddFile(ZombieClassAux.PModel)
	table.insert(ClassManager.ZombieClasses, ZombieClassAux)
end
function ClassManager:GetZombieClass(ID)
	return ClassManager:GetZombieClasses()[ID]
end
function ClassManager:AddHumanClass(HumanClass)
	local HumanClassAux = {Name = HumanClass.Name or "Human",
		MaxHealth = HumanClass.MaxHealth or 100,
		Armor = HumanClass.Armor,
		PModel = HumanClass.PModel or "models/player/barney.mdl",
		Speed = HumanClass.Speed or 240,
		RunSpeed = HumanClass.RunSpeed or 250,
		CrouchSpeed = HumanClass.CrouchSpeed or 0.4,
		Gravity = HumanClass.Gravity or 1,
		Battery = HumanClass.Battery or 100,
		Breath = HumanClass.Breath or 100,
		JumpPower = HumanClass.JumpPower or 170,
		Footstep = HumanClass.Footstep or true,
		FallFunction = HumanClass.FallFunction or function()return true end
	}
	resource.AddFile(HumanClassAux.PModel)
	table.insert(ClassManager.HumanClasses, HumanClassAux)
end
function ClassManager:GetHumanClass(ID)
	return ClassManager:GetHumanClasses()[ID]
end
function ClassManager:SetUserZombieClass(ply, ID)
		ply:SetZombieClass(ClassManager:GetZombieClass(ID))
end
function ClassManager:SetUserHumanClass(ply, ID)
		ply:SetHumanClass(ClassManager:GetHumanClass(ID))
end
function ClassManager:OpenHumanMenu(ply)
	local Pretty = {}
	for k, HClass in pairs(ClassManager:GetHumanClasses()) do
		table.insert(Pretty, HClass.Name)
	end
	
	net.Start("OpenBackMenu")
		net.WriteString("SendHumanClass")
		net.WriteTable(Pretty)
	net.Send(ply)
end
function ClassManager:OpenZombieMenu(ply)
	local Pretty = {}
	for k, HClass in pairs(ClassManager:GetZombieClasses()) do
		table.insert(Pretty, HClass.Name)
	end
	
	net.Start("OpenBackMenu")
		net.WriteString("SendZombieClass")
		net.WriteTable(Pretty)
	net.Send(ply)
end

net.Receive("SendHumanClass", function(len, ply)
	ply:SetNextHumanClass(net.ReadInt(16))
end)
net.Receive("SendZombieClass", function(len, ply)
	ply:SetNextZombieClass(net.ReadInt(16))
end)

hook.Add("PlayerSay", "ZPClasses", function(ply, txt)
	if txt == "/zombies" then
		ClassManager:OpenZombieMenu(ply)
	elseif txt == "/humans" then
		ClassManager:OpenHumanMenu(ply)
	end
end)

net.Receive("RequestZombieMenu", function(len, ply)
	ClassManager:OpenZombieMenu(ply)
end)
net.Receive("RequestHumanMenu", function(len, ply)
	ClassManager:OpenHumanMenu(ply)
end)

util.AddNetworkString("RequestZombieMenu")
util.AddNetworkString("RequestHumanMenu")
util.AddNetworkString("SendHumanClass")
util.AddNetworkString("SendZombieClass")