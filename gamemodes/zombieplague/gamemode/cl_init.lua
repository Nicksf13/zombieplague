include("shared.lua")

include("cl_roundmanager.lua")
include("cl_message.lua")
include("cl_player.lua")
include("cl_hud.lua")
include("cl_language.lua")
include("cl_menu.lua")
include("cl_keymanager.lua")
include("cl_derma.lua")

function GM:PlayerFootstep(ply)
	return !ply:GetFootstep() -- Since true = no footsteps, false = footsteps
end
net.Receive("SendServerStatus", function()
	local Info = net.ReadTable()
	RoundManager:SetTimer(Info.Timer)
	RoundManager:SetRoundState(Info.RoundState)
	RoundManager:SetRound(Info.Round)
	for k, TempPly in pairs(Info.Players) do
		local ply = player.GetBySteamID(TempPly.SteamID)
		if IsValid(ply) then
			ply:SetMaxBatteryCharge(TempPly.Battery)
			ply:SetAmmoPacks(TempPly.AmmoPacks)
			ply:SetZombieClass(TempPly.ZombieClass)
			ply:SetHumanClass(TempPly.HumanClass)
			ply:SetLight(TempPly.Light)
			ply:SetFootstep(TempPly.Footstep)
			ply:SetAbilityPower(TempPly.AbilityPower)
			ply:SetMaxAbilityPower(TempPly.MaxAbilityPower)
		end
	end
end)
hook.Add("InitPostEntity", "PlayerRdy", function()
	if !file.Exists("zombieplague", "DATA") then
		file.CreateDir("zombieplague")
	end

	Dictionary:Start()
	CreateMenu()
	net.Start("RequestServerStatus")
		net.WriteString(Dictionary.LanguageID)
	net.SendToServer()
end)
concommand.Add("zp_ability", function( ply, cmd, args )
	net.Start("RequestAbility")
	net.SendToServer()
end)