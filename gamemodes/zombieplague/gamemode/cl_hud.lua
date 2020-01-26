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
			local StringHUD = ""
			if ply:IsZombie() then	
				StringHUD = Dictionary:GetPhrase("ClassClass") .. " " .. ply:GetZPClass() .. " - " .. Dictionary:GetPhrase("ClassHealth") .. " " .. ply:Health() .. " - " .. Dictionary:GetPhrase("AP") .. " " .. ply:GetAmmoPacks()
			else
				StringHUD = Dictionary:GetPhrase("ClassClass") .. " " .. ply:GetZPClass() .. " - " .. Dictionary:GetPhrase("ClassHealth") .. " " .. ply:Health() .. " - " .. Dictionary:GetPhrase("ClassArmor") .. " " .. ply:Armor() .. " - " .. Dictionary:GetPhrase("AP") .. " " .. ply:GetAmmoPacks() .. " - " .. Dictionary:GetPhrase("ClassBattery") .. " " .. string.format("%.2f", (ply:GetBattery() / ply:GetMaxBatteryCharge()) * 100) .. "%"
			end
			local HUDProperties = {
				Text = StringHUD,
				TextFont = "Trebuchet18",
				TextColor = HudManager:GetColor("Status", "Text"),
				TextMargin = 6
			}
			HudManager:CreateTextDisplayBox(HUDProperties, 1, 10, HudManager:GetColor("Status", "Border"), HudManager:GetColor("Status", "Body"), 20, ScrH() - 40)
		end
	end

	local TimerProperties = {
		Text = string.FormattedTime(RoundManager:GetTimer(), "%02i:%02i" ),
		TextFont = "Trebuchet24",
		TextColor = HudManager:GetColor("Timer", "Text"),
		TextMargin = 6
	}

	HudManager:CreateTextDisplayBox(TimerProperties, 1, 10, HudManager:GetColor("Timer", "Border"), HudManager:GetColor("Timer", "Body"), nil, ScrH() - 40)
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

HudManager = {Colors = {}, SaveFileName = "zombieplague/hudcolors.json"}

function HudManager:CreateHudCustomizerMenu()
		local FrameWidth = 400
		local FrameHeight = 415
		local Border = 20
		local FullScreenWidth = FrameWidth - (Border * 2)
		local SelectedComponent = "Menu"

		local HudCustomizerMenu = vgui.Create("DFrame")
		HudCustomizerMenu:SetDraggable(true)
		HudCustomizerMenu:SetSize(FrameWidth, FrameHeight)
		HudCustomizerMenu:SetTitle("Zombie Plague - " .. Dictionary:GetPhrase("HUDCustomizerTitle"))
		HudCustomizerMenu:Center()

		local Y = 30

		local DSheet = vgui.Create("DPropertySheet", HudCustomizerMenu)

		local ColorPickerBorder = HudManager:CreateColorMixer(false)
		local ColorPickerComponent = HudManager:CreateColorMixer(true)
		local ColorPickerText = HudManager:CreateColorMixer(false)

		ColorPickerBorder:SetColor(HudManager:GetColor(SelectedComponent, "Border"))
		ColorPickerComponent:SetColor(HudManager:GetColor(SelectedComponent, "Body"))
		ColorPickerText:SetColor(HudManager:GetColor(SelectedComponent, "Text"))

		local DComboBox = vgui.Create("DComboBox", HudCustomizerMenu)
		DComboBox:SetPos(Border, Y)
		DComboBox:SetSize(FullScreenWidth, 20)
		DComboBox:AddChoice(Dictionary:GetPhrase("HUDCustomizerComboMenu"), "Menu")
		DComboBox:AddChoice(Dictionary:GetPhrase("HUDCustomizerComboStatusBar"), "Status")
		DComboBox:AddChoice(Dictionary:GetPhrase("HUDCustomizerComboRoundTimer"), "Timer")
		DComboBox:ChooseOptionID(1)
		function DComboBox:OnSelect(Self, Index, Value)
			SelectedComponent = Value

			ColorPickerBorder:SetColor(HudManager:GetColor(SelectedComponent, "Border"))
			ColorPickerComponent:SetColor(HudManager:GetColor(SelectedComponent, "Body"))
			ColorPickerText:SetColor(HudManager:GetColor(SelectedComponent, "Text"))

			DSheet:SetActiveTab(DSheet:GetItems()[1].Tab)
		end

		Y = Y + 30

		DSheet:SetPos(Border, Y)
		DSheet:SetSize(FullScreenWidth, 300)
		
		DSheet:AddSheet(Dictionary:GetPhrase("HUDCustomizerTabTitleBody"), ColorPickerComponent, "icon16/color_wheel.png")
		DSheet:AddSheet(Dictionary:GetPhrase("HUDCustomizerTabTitleBorder"), ColorPickerBorder, "icon16/color_wheel.png")
		DSheet:AddSheet(Dictionary:GetPhrase("HUDCustomizerTabTitleText"), ColorPickerText, "icon16/color_wheel.png")

		Y = Y + 310

		local DermaButton = vgui.Create("DButton", HudCustomizerMenu)
		DermaButton:SetText(Dictionary:GetPhrase("HUDCustomizerApplyButton"))
		DermaButton:SetPos(Border, Y)
		DermaButton:SetSize(FullScreenWidth, 25)
		function DermaButton:DoClick()
			local Component = HudManager:GetComponentColors(SelectedComponent)
			Component.Body = ColorPickerComponent:GetColor()
			Component.Border = ColorPickerBorder:GetColor()
			Component.Text = ColorPickerText:GetColor()

			Component.Border.a = Component.Body.a

			HudManager:SaveColor()
		end

		HudCustomizerMenu:MakePopup()
end

function HudManager:CreateColorMixer(AlphaBarEnabled)
	local ColorMixer = vgui.Create("DColorMixer")

	ColorMixer:Dock(FILL)
	ColorMixer:DockMargin(10, 10, 10, 10)
	ColorMixer:SetPalette(true)
	ColorMixer:SetAlphaBar(AlphaBarEnabled)
	ColorMixer:SetWangs(true)

	return ColorMixer
end

function HudManager:CreateTextDisplayBox(TextProperties, BorderSize, CornerRadius, BorderColor, BodyColor, XPosition, YPosition)
	local Text = TextProperties.Text
	local TextFont = TextProperties.TextFont
	local TextColor = TextProperties.TextColor
	local TextMargin = TextProperties.TextMargin or 0
	surface.SetFont(TextFont)

	local Width, Height = surface.GetTextSize(Text)
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

function HudManager:GetColor(Component, Name)
	return self.Colors[Component][Name]
end
function HudManager:GetComponentColors(Component)
	return self.Colors[Component]
end

function HudManager:LoadHudInformation()
	if file.Exists(self.SaveFileName, "DATA") then
		self.Colors = util.JSONToTable(file.Read(self.SaveFileName, "DATA"))
	else
		self.Colors.Menu = self:CreateHudComponentInfo()
		self.Colors.Status = self:CreateHudComponentInfo()
		self.Colors.Timer = self:CreateHudComponentInfo()

		self:SaveColor()
	end
end

function HudManager:SaveColor()
	file.Write(self.SaveFileName, util.TableToJSON(self.Colors, true))
end

function HudManager:CreateHudComponentInfo()
	return {
		Border = Color(255, 255, 255, 0),
		Body = Color(255, 255, 255, 0),
		Text = Color(255, 255, 255, 255)
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