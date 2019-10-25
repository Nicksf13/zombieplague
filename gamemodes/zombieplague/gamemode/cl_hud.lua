local hide = {
	CHudHealth = true,
	CHudBattery = true,
}
hook.Add("HUDShouldDraw", "HideHUD", function(name)
	if (hide[name]) then return false end
end)
hook.Add("HUDPaint", "HUDZombiePlague", function()
	if LocalPlayer():GetObserverMode() != OBS_MODE_ROAMING then
		local ply = LocalPlayer()
		if !ply:Alive() then
			ply = LocalPlayer():GetObserverTarget() 
		end
		if ply then
			local StringHUD = ""
			if ply:IsZombie() then	
				StringHUD = Dictionary:GetPhrase("ClassClass") .. " " .. ply:GetZPClass() .. " - " .. Dictionary:GetPhrase("ClassHealth") .. " " .. ply:Health() .. " - " .. Dictionary:GetPhrase("AP") .. " " .. ply:GetAmmoPacks()
			else
				StringHUD = Dictionary:GetPhrase("ClassClass") .. " " .. ply:GetZPClass() .. " - " .. Dictionary:GetPhrase("ClassHealth") .. " " .. ply:Health() .. " - " .. Dictionary:GetPhrase("ClassArmor") .. " " .. ply:Armor() .. " - " .. Dictionary:GetPhrase("AP") .. " " .. ply:GetAmmoPacks() .. " - " .. Dictionary:GetPhrase("ClassBattery") .. " " .. string.format("%.2f", (ply:GetBattery() / ply:GetMaxBatteryCharge()) * 100) .. "%"
			end
			draw.DrawText(StringHUD, Trebuchet18, 20, ScrH() - 30, Color(255, 255, 255), TEXT_ALIGN_LEFT)
			StringHUD = nil
		end
	end
	draw.DrawText(string.FormattedTime(RoundManager:GetTimer(), "%02i:%02i" ), "Trebuchet24", ScrW() / 2, ScrH() - 40, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER) 
end)
hook.Add("Think", "ZPSpecialLights", function()
	if IsNightvisionOn() then
		local dlight = DynamicLight(LocalPlayer():EntIndex())
		if dlight then
			dlight.pos = LocalPlayer():GetShootPos()
			local NColor = LocalPlayer():GetNightvisionColor()
			dlight.r = NColor.r
			dlight.g = NColor.g
			dlight.b = NColor.b
			dlight.brightness = 2
			dlight.Decay = 1000
			dlight.Size = 750
			dlight.DieTime = CurTime() + 1
		end
	end
	
	for k, ply in pairs(player.GetAll()) do
		local NColor = ply:GetLight()
		if NColor then
			local dlight = DynamicLight(ply:EntIndex())
			if dlight then
				dlight.pos = ply:GetPos()
				dlight.r = NColor.r
				dlight.g = NColor.g
				dlight.b = NColor.b
				dlight.brightness = 2
				dlight.Decay = 1000
				dlight.Size = 250
				dlight.DieTime = CurTime() + 0.5
			end
		end
	end
end)
/*hook.Add("PosInitEnt", "CreateScoreboard", function()
	local Width = 700
	local Height = 400
	local Margin = 4
	local PlayerLenght = 34
	DScoreboard = vgui.Create("DFrame")
	DScoreboard:SetTitle("")
	DScoreboard:ShowCloseButton(false)
	DScoreboard:SetVisible(false)
	function DScoreboard:Paint()
		draw.RoundedBox(2, 0, 0, Width, Height, Color(255, 0, 0, 125))
	end
	local i = 1
	for k, ply in pairs(team.GetPlayers(TEAM_HUMANS)) do
		DrawPlayer(ply, i, Width, PlayerLenght, Margin, ply:Alive() and team.GetColor(TEAM_HUMANS) or Color(120, 120, 120))
		i = i + 1
	end
	i = i + 2
	for k, ply in pairs(team.GetPlayers(TEAM_ZOMBIES)) do
		DrawPlayer(ply, i, Width, PlayerLenght, Margin, ply:Alive() and team.GetColor(TEAM_ZOMBIES) or Color(120, 120, 120))
		i = i + 1
	end
	DScoreboard:SetSize(Width, i * PlayerLenght)
	DScoreboard:Center()
end)
function DrawPlayer(ply, i, Width, Height, Margin, Clr)
	local Y = i * Height
	Height = Height - 10
	local BtPlayer = vgui.Create("DButton", DScrollBoard)
	BtPlayer:SetText("")
	BtPlayer:
	draw.RoundedBox(4, Margin, Y, Width - (2 * Margin), Height, Clr)
	draw.DrawText(ply:Name(), "DermaDefault", Margin + 2, Y + 2, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
	draw.DrawText(ply:Ping(), "DermaDefault", Width - (Margin * 2) - 30, Y + 2, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT) 
end
function GM:ScoreboardShow()
	DScoreboard:Show()
end
function GM:ScoreboardHide()
	DScoreboard:Hide()
end*/