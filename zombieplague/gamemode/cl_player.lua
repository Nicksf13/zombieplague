local PLAYER = FindMetaTable("Player")

function PLAYER:SetAmmoPacks(AmmoPacks)
	self.AmmoPacks = AmmoPacks
end
function PLAYER:GetAmmoPacks()
	return self.AmmoPacks or 0
end
function PLAYER:SetBattery(Battery)
	self.Battery = Battery
end
function PLAYER:GetBattery()
	return self.Battery or self:GetMaxBatteryCharge()
end
function PLAYER:SetMaxBatteryCharge(MaxCharge)
	self.MaxCharge = MaxCharge
end
function PLAYER:GetMaxBatteryCharge()
	return self.MaxCharge or 100
end
function PLAYER:SetZombieClass(ZombieClass)
	self.ZombieClass = ZombieClass
end
function PLAYER:GetZombieClass()
	return self.ZombieClass or ""
end
function PLAYER:SetHumanClass(HumanClass)
	self.HumanClass = HumanClass
end
function PLAYER:GetHumanClass()
	return self.HumanClass or ""
end
function PLAYER:SetNemesis(Nemesis)
	self.Nemesis = Nemesis
end
function PLAYER:IsNemesis()
	return self.Nemesis or false
end
function PLAYER:SetSurvivor(Survivor)
	self.Survivor = Survivor
end
function PLAYER:IsSurvivor()
	return self.Survivor or false
end
function PLAYER:IsZombie()
	return self:Team() == TEAM_ZOMBIES
end
function PLAYER:IsHuman()
	return self:Team() == TEAM_HUMANS
end
function PLAYER:GetZPClass()
	if self:IsNemesis() then
		return "Nemesis"
	end
	if self:IsSurvivor() then
		return "Survivor"
	end
	if self:Team() == TEAM_ZOMBIES then
		return self:GetZombieClass()
	end
	if self:Team() == TEAM_HUMANS then
		return self:GetHumanClass()
	end
	return ""
end
local Nightvision = false
function SetNightvision(TNightvision)
	Nightvision = TNightvision
end
function IsNightvisionOn()
	return Nightvision or false
end
function PLAYER:GetNightvisionColor()
	if self:IsNemesis() then
		return Color(255, 0, 0)
	end
	if self:IsSurvivor() then
		return Color(0, 0, 255)
	end
	return NIGHTVISION_COLOR
end
function PLAYER:SetLight(Light)
	self.Light = Light
end
function PLAYER:GetLight()
	return self.Light
end
hook.Add("PlayerStartVoice", "ZPStartTalking", function(ply)
	if ply == LocalPlayer() then
		net.Start("SendVoice")
			net.WriteBool(true)
		net.SendToServer()
	end
end)
hook.Add("PlayerEndVoice", "ZPStartTalking", function(ply)
	if ply == LocalPlayer() then
		net.Start("SendVoice")
			net.WriteBool(false)
		net.SendToServer()
	end
end)

net.Receive("SendAmmoPacks", function()
	player.GetBySteamID(net.ReadString()):SetAmmoPacks(net.ReadInt(32)) 
end)
net.Receive("SendBatteryCharge", function()
	player.GetBySteamID(net.ReadString()):SetBattery(net.ReadFloat())
end)
net.Receive("SendMaxBatteryCharge", function()
	player.GetBySteamID(net.ReadString()):SetMaxBatteryCharge(net.ReadFloat())
end)
net.Receive("SendZombieClass", function()
	player.GetBySteamID(net.ReadString()):SetZombieClass(net.ReadString())
end)
net.Receive("SendHumanClass", function()
	player.GetBySteamID(net.ReadString()):SetHumanClass(net.ReadString())
end)
net.Receive("SendNemesis", function()
	player.GetBySteamID(net.ReadString()):SetNemesis(net.ReadBool())
end)
net.Receive("SendSurvivor", function()
	player.GetBySteamID(net.ReadString()):SetSurvivor(net.ReadBool())
end)
net.Receive("SendNightvision", function()
	SetNightvision(net.ReadBool())
end)
net.Receive("SendLight", function()
	local ply = player.GetBySteamID(net.ReadString())
	if net.ReadBool() then
		ply:SetLight(net.ReadColor())
	else
		ply:SetLight(nil)
	end
end)