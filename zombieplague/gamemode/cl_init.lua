include("shared.lua")

include("cl_roundmanager.lua")
include("cl_message.lua")
include("cl_player.lua")
include("cl_hud.lua")
include("cl_language.lua")
include("cl_menu.lua")

hook.Add("InitPostEntity", "PlayerRdy", function()
	net.Start("RequestServerStatus")
	net.SendToServer()
	Dictionary:Start()
	CreateMenu()
end)

net.Receive("SendServerStatus", function()
	local Info = net.ReadTable()
	RoundManager:SetTimer(Info.Timer)
	RoundManager:SetRoundState(Info.RoundState)
	RoundManager:SetRound(Info.Round)
	for k, TempPly in pairs(Info.Players) do
		local ply = player.GetBySteamID(TempPly.SteamID)
		ply:SetMaxBatteryCharge(TempPly.Battery)
		ply:SetAmmoPacks(TempPly.AmmoPacks)
		ply:SetZombieClass(TempPly.ZombieClass)
		ply:SetHumanClass(TempPly.HumanClass)
		ply:SetLight(TempPly.Light)
	end
end)

