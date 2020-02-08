HUD_TOP = 1
HUD_CENTER = 2
HUD_BOTTOM = 3
HUD_LEFT = 4
HUD_RIGHT = 5

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
		if IsValid(ply) then
			local StringHUD = Dictionary:GetPhrase("ClassClass") .. " " .. ply:GetZPClass() .. " - " .. Dictionary:GetPhrase("ClassHealth") .. " " .. ply:Health() 
			if ply:IsHuman() then	
				StringHUD = StringHUD .. " - " .. Dictionary:GetPhrase("ClassArmor") .. " " .. ply:Armor() .. " - " .. Dictionary:GetPhrase("ClassBattery") .. " " .. string.format("%.2f", (ply:GetBattery() / ply:GetMaxBatteryCharge()) * 100) .. "%"
			end
			if ply:GetMaxAbilityPower() > 0 then
				StringHUD = StringHUD .. " - " .. Dictionary:GetPhrase("ClassAbilityPower") .. " " .. string.format("%.2f", (ply:GetAbilityPower() / ply:GetMaxAbilityPower()) * 100) .. "%"
			end
			StringHUD = StringHUD .. " - " .. Dictionary:GetPhrase("AP") .. " " .. ply:GetAmmoPacks()
			local StatusConfig = HudManager:GetComponentConfig("Status")
			local HUDProperties = {
				Text = StringHUD,
				TextFont = StatusConfig.Font,
				TextColor = StatusConfig.Text,
				TextMargin = 6
			}
			HudManager:CreateTextDisplayBox(HUDProperties, 1, 10, StatusConfig.Border, StatusConfig.Body, StatusConfig.XPos, StatusConfig.YPos)
		end
	end

	local TimerConfig = HudManager:GetComponentConfig("Timer")
	local TimerProperties = {
		Text = string.FormattedTime(RoundManager:GetTimer(), "%02i:%02i" ),
		TextFont = TimerConfig.Font,
		TextColor = TimerConfig.Text,
		TextMargin = 6
	}

	HudManager:CreateTextDisplayBox(TimerProperties, 1, 10, TimerConfig.Border, TimerConfig.Body, TimerConfig.XPos, TimerConfig.YPos)
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

HudManager = {HUDConfig = {}, SaveFileName = "zombieplague/hudconfig.json"}

function HudManager:CreateTextDisplayBox(TextProperties, BorderSize, CornerRadius, BorderColor, BodyColor, XPosEnum, YPosEnum)
	local Text = TextProperties.Text
	local TextFont = TextProperties.TextFont
	local TextColor = TextProperties.TextColor
	local TextMargin = TextProperties.TextMargin or 0
	surface.SetFont(TextFont)

	local Width, Height = surface.GetTextSize(Text)
	local XPosition, YPosition = self:CalculatePos(XPosEnum, YPosEnum, Width, Height, 20, 20)
	local DrawXPosition = (XPosition or (ScrW() / 2  - (Width / 2) - TextMargin))
	local DrawYPosition = (YPosition or (ScrH() / 2 - (Height / 2) - TextMargin))
	local ExtraMarginSize = TextMargin * 2
	
	HudManager:CreateBox(BorderSize, CornerRadius, BorderColor, BodyColor, DrawXPosition, DrawYPosition, Width + ExtraMarginSize, Height + ExtraMarginSize)

	draw.DrawText(Text, TextFont, DrawXPosition + TextMargin, DrawYPosition + TextMargin, TextColor, TEXT_ALIGN_LEFT)
end

function HudManager:CreateBox(BorderSize, CornerRadius, BorderColor, BodyColor, XPosition, YPosition, Width, Height)
	if BorderSize > 0 && BorderColor.a > 0 then
		draw.RoundedBox(CornerRadius, XPosition, YPosition, Width, Height, BorderColor)

		Width = Width - (BorderSize * 2)
		Height = Height - (BorderSize * 2)
		XPosition = XPosition + BorderSize
		YPosition = YPosition + BorderSize
	end

	if BodyColor.a > 0 then
		draw.RoundedBox(CornerRadius, XPosition, YPosition, Width, Height, BodyColor)
	end
end

function HudManager:CalculatePos(XPosENum, YPosEnum, Width, Height, BorderX, BorderY)
	local BorderX = BorderX or 0
	local BorderY = BorderY or 0

	local XPos = BorderX
	local YPos = BorderY

	if XPosENum == HUD_CENTER then
		XPos = (ScrW() / 2) - (Width / 2)
	elseif XPosENum == HUD_RIGHT then
		XPos = ScrW() - Width - BorderX
	end

	if YPosEnum == HUD_CENTER then
		YPos = (ScrH() / 2) - (Height / 2)
	elseif YPosEnum == HUD_BOTTOM then
		YPos = ScrH() - Height - BorderY
	end

	return XPos, YPos
end

function HudManager:GetConfig(Component, Name)
	return self.HUDConfig[Component][Name]
end
function HudManager:GetComponentConfig(Component)
	return self.HUDConfig[Component]
end

function HudManager:LoadHudInformation()
	if file.Exists(self.SaveFileName, "DATA") then
		self.HUDConfig = util.JSONToTable(file.Read(self.SaveFileName, "DATA"))
	else
		self.HUDConfig.Menu = self:CreateHudComponentInfo(HUD_LEFT, HUD_CENTER)
		self.HUDConfig.Status = self:CreateHudComponentInfo(HUD_LEFT, HUD_BOTTOM)
		self.HUDConfig.Timer = self:CreateHudComponentInfo(HUD_CENTER, HUD_BOTTOM)

		self:Save()
	end
end

function HudManager:Save()
	file.Write(self.SaveFileName, util.TableToJSON(self.HUDConfig, true))
end

function HudManager:CreateHudComponentInfo(XPos, YPos)
	return {
		Border = Color(255, 255, 255, 0),
		Body = Color(255, 255, 255, 0),
		Text = Color(255, 255, 255, 255),
		Font = "Trebuchet18",
		XPos = XPos,
		YPos = YPos
	}
end

HudManager:LoadHudInformation()

--hook.Add("PosInitEnt", "CreateScoreboard", function()
--	local Width = 700
--	local Height = 400
--	local Margin = 4
--	local PlayerLenght = 34
--	DScoreboard = vgui.Create("DFrame")
--	DScoreboard:SetTitle("")
--	DScoreboard:ShowCloseButton(false)
--	DScoreboard:SetVisible(false)
--	function DScoreboard:Paint()
--		draw.RoundedBox(2, 0, 0, Width, Height, Color(255, 0, 0, 125))
--	end
--	local i = 1
--	for k, ply in pairs(team.GetPlayers(TEAM_HUMANS)) do
--		DrawPlayer(ply, i, Width, PlayerLenght, Margin, ply:Alive() and team.GetColor(TEAM_HUMANS) or Color(120, 120, 120))
--		i = i + 1
--	end
--	i = i + 2
--	for k, ply in pairs(team.GetPlayers(TEAM_ZOMBIES)) do
--		DrawPlayer(ply, i, Width, PlayerLenght, Margin, ply:Alive() and team.GetColor(TEAM_ZOMBIES) or Color(120, 120, 120))
--		i = i + 1
--	end
--	DScoreboard:SetSize(Width, i * PlayerLenght)
--	DScoreboard:Center()
--end)
--function DrawPlayer(ply, i, Width, Height, Margin, Clr)
--	local Y = i * Height
--	Height = Height - 10
--	local BtPlayer = vgui.Create("DButton", DScrollBoard)
--	BtPlayer:SetText("")
--	BtPlayer:
--	draw.RoundedBox(4, Margin, Y, Width - (2 * Margin), Height, Clr)
--	draw.DrawText(ply:Name(), "DermaDefault", Margin + 2, Y + 2, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
--	draw.DrawText(ply:Ping(), "DermaDefault", Width - (Margin * 2) - 30, Y + 2, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT) 
--end
--function GM:ScoreboardShow()
--	DScoreboard:Show()
--end
--function GM:ScoreboardHide()
--	DScoreboard:Hide()
--end