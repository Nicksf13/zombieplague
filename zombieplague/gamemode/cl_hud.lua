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
		if ply != nil then
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
			dlight.Size = 500
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
				dlight.Size = 256
				dlight.DieTime = CurTime() + 0.1
			end
		end
	end
end)
/*hook.Add("PosInitEnt", "CreateScoreboard", function()
	local Width = 700
	local Heigth = 400
	local Margin = 4
	local DScoreboard = vgui.Create("DFrame")
	DScoreboard:SetTitle("")
	DScoreboard:ShowCloseButton(false)
	DScoreboard:SetSize(Width, Heigth)
	DScoreboard:Center()
	DScoreboard:SetVisible(false)
	function DScoreboard:Paint()
		draw.RoundedBox(2, 0, 0, Width, Heigth, Color(255, 0, 0))
		draw.RoundedBox(2, 2, 2, Width - (Margin * 2), Heigth - (Margin * 2), Color(0, 0, 0))
	end
end)
function GM:ScoreboardShow()
	DScoreboard:Show()
	timer.Create("ScoreboardUpdater", 1, 0, function()
	end)
end
function GM:ScoreboardHide()
	timer.Destroy("ScoreboardUpdater")
end*/