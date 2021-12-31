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
	return self.Nemesis
end
function PLAYER:SetSurvivor(Survivor)
	self.Survivor = Survivor
end
function PLAYER:IsSurvivor()
	return self.Survivor
end
function PLAYER:IsZombie()
	return self:Team() == TEAM_ZOMBIES
end
function PLAYER:IsHuman()
	return self:Team() == TEAM_HUMANS
end
function PLAYER:GetZPClass()
	if self:IsNemesis() then
		return Dictionary:GetPhrase("Nemesis")
	end
	if self:IsSurvivor() then
		return Dictionary:GetPhrase("Survivor")
	end
	if self:Team() == TEAM_ZOMBIES then
		return Dictionary:GetPhrase(self:GetZombieClass())
	end
	if self:Team() == TEAM_HUMANS then
		return Dictionary:GetPhrase(self:GetHumanClass())
	end
	return ""
end
local Nightvision = false
function SetNightvision(TNightvision)
	Nightvision = TNightvision
end
function IsNightvisionOn()
	return Nightvision
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
function PLAYER:SetFootstep(Footstep)
	self.Footstep = Footstep
end
function PLAYER:GetFootstep()
	return self.Footstep
end

function PLAYER:SetAbilityPower(AbilityPower)
	self.AbilityPower = AbilityPower
end
function PLAYER:GetAbilityPower()
	return self.AbilityPower or -1
end

function PLAYER:SetMaxAbilityPower(MaxAbilityPower)
	self.MaxAbilityPower = MaxAbilityPower
end
function PLAYER:GetMaxAbilityPower()
	return self.MaxAbilityPower or -1
end

function PLAYER:SetBreath(Breath)
	self.Breath = Breath
end
function PLAYER:GetBreath()
	return self.Breath or 100
end

function PLAYER:SetMaxBreath(MaxBreath)
	self.MaxBreath = MaxBreath
end
function PLAYER:GetMaxBreath()
	return self.MaxBreath or 100
end

function PLAYER:SetScreenFilter(ScreenFilter)
	self.ScreenFilter = ScreenFilter
end
function PLAYER:GetScreenFilter()
	return self.ScreenFilter
end

function PLAYER:SetPoints(Points)
	self.Points = Points
end
function PLAYER:GetPoints()
	return self.Points or 0
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
	local ply = PlayerManager:DiscoverPlayerByTextID(net.ReadString())
	if IsValid(ply) then
		ply:SetAmmoPacks(net.ReadInt(32))
	end
end)
net.Receive("SendBatteryCharge", function()
	local ply = PlayerManager:DiscoverPlayerByTextID(net.ReadString())
	if IsValid(ply) then
		ply:SetBattery(net.ReadFloat())
	end
end)
net.Receive("SendMaxBatteryCharge", function()
	local ply = PlayerManager:DiscoverPlayerByTextID(net.ReadString())
	if IsValid(ply) then
		ply:SetMaxBatteryCharge(net.ReadFloat())
	end
end)
net.Receive("SendZombieClass", function()
	local ply = PlayerManager:DiscoverPlayerByTextID(net.ReadString())
	if IsValid(ply) then
		ply:SetZombieClass(net.ReadString())
	end
end)
net.Receive("SendHumanClass", function()
	local ply = PlayerManager:DiscoverPlayerByTextID(net.ReadString())
	if IsValid(ply) then
		ply:SetHumanClass(net.ReadString())
	end
end)
net.Receive("SendNemesis", function()
	local ply = PlayerManager:DiscoverPlayerByTextID(net.ReadString())
	if IsValid(ply) then
		ply:SetNemesis(net.ReadBool())
	end
end)
net.Receive("SendSurvivor", function()
	local ply = PlayerManager:DiscoverPlayerByTextID(net.ReadString())
	if IsValid(ply) then
		ply:SetSurvivor(net.ReadBool())
	end
end)
net.Receive("SendFoostep", function()
	local ply = PlayerManager:DiscoverPlayerByTextID(net.ReadString())
	if IsValid(ply) then
		ply:SetFootstep(net.ReadBool())
	end
end)
net.Receive("SendNightvision", function()
	SetNightvision(net.ReadBool())
end)
net.Receive("SendLight", function()
	local ply = PlayerManager:DiscoverPlayerByTextID(net.ReadString())
	if IsValid(ply) then
		if net.ReadBool() then
			ply:SetLight(net.ReadColor())
		else
			ply:SetLight(nil)
		end
	end
end)
net.Receive("SendAbilityPower", function()
	local ply = PlayerManager:DiscoverPlayerByTextID(net.ReadString())
	if IsValid(ply) then
		ply:SetAbilityPower(net.ReadInt(16))
	end
end)
net.Receive("SendMaxAbilityPower", function()
	local ply = PlayerManager:DiscoverPlayerByTextID(net.ReadString())
	if IsValid(ply) then
		ply:SetMaxAbilityPower(net.ReadInt(16))
	end
end)
net.Receive("SendBreath", function()
	local ply = PlayerManager:DiscoverPlayerByTextID(net.ReadString())
	if IsValid(ply) then
		ply:SetBreath(net.ReadFloat())
	end
end)
net.Receive("SendMaxBreath", function()
	local ply = PlayerManager:DiscoverPlayerByTextID(net.ReadString())
	if IsValid(ply) then
		ply:SetMaxBreath(net.ReadFloat())
	end
end)
net.Receive("SendScreenFilter", function()
	local ply = PlayerManager:DiscoverPlayerByTextID(net.ReadString())
	if IsValid(ply) then
		if net.ReadBool() then
			ply:SetScreenFilter(net.ReadColor())
		else
			ply:SetScreenFilter(nil)
		end
	end
end)
net.Receive("SendPoints", function()
	local ply = PlayerManager:DiscoverPlayerByTextID(net.ReadString())
	if IsValid(ply) then
		ply:SetPoints(net.ReadInt(32))
	end
end)