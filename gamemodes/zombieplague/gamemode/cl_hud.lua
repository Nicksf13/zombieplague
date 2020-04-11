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
		local ply = LocalPlayer():Alive() and LocalPlayer() or LocalPlayer():GetObserverTarget()

		if IsValid(ply) then
			local StringHUD = ""
			for k, HudComponent in pairs(HudManager.HudComponents) do
				if HudComponent:ShouldRenderFunction(ply) then
					StringHUD = StringHUD .. HudComponent:TextFunction(ply) .. ": " .. HudComponent:InfoFunction(ply) .. " - "
				end
			end
			StringHUD = string.sub(StringHUD, 1, string.len(StringHUD) - 3)

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

HudManager = {HUDConfig = {}, SaveFileName = "zombieplague/hudconfig.json", HudComponents = {}}

function HudManager:CreateHudInfo(HudComponentID, TextFunction, InfoFunction, ShouldRenderFunction)
	local HudComponent = {HudComponentID = HudComponentID}
	function HudComponent:TextFunction(ply)
		return TextFunction(ply)
	end
	function HudComponent:InfoFunction(ply)
		return InfoFunction(ply)
	end
	function HudComponent:ShouldRenderFunction(ply)
		return ShouldRenderFunction(ply)
	end
	table.insert(self.HudComponents, HudComponent)
end
function HudManager:CreateTextDisplayBox(TextProperties, BorderSize, CornerRadius, BorderColor, BodyColor, XPosEnum, YPosEnum)
	local Text = TextProperties.Text
	local TextFont = TextProperties.TextFont
	local TextColor = TextProperties.TextColor
	local TextMargin = TextProperties.TextMargin or 0

	local Width, Height = HudManager:CalculateTextSize(Text, TextFont)
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

function HudManager:CalculateTextSize(Text, TextFont)
	surface.SetFont(TextFont)

	return surface.GetTextSize(Text)
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
		Border = Color(0, 0, 0, 144),
		Body = Color(72, 72, 72, 144),
		Text = Color(255, 255, 255, 255),
		Font = "Trebuchet18",
		XPos = XPos,
		YPos = YPos
	}
end

HudManager:LoadHudInformation()
HudManager:CreateHudInfo("HUDZPClass", function()
	return Dictionary:GetPhrase("ClassClass")
end, function(ply)
	return ply:GetZPClass()
end, function()
	return true
end)
HudManager:CreateHudInfo("HUDHealth", function()
	return Dictionary:GetPhrase("ClassHealth")
end, function(ply)
	return ply:Health()
end, function()
	return true
end)
HudManager:CreateHudInfo("HUDArmor", function()
	return Dictionary:GetPhrase("ClassArmor")
end, function(ply)
	return ply:Armor()
end, function(ply)
	return ply:Armor() > 0
end)
HudManager:CreateHudInfo("HUDOxygenLevel", function()
	return Dictionary:GetPhrase("ClassOxygenLevel")
end, function(ply)
	return string.format("%.2f", (ply:GetBreath() / ply:GetMaxBreath()) * 100) .. "%"
end, function(ply)
	return ply:GetBreath() < ply:GetMaxBreath()
end)
HudManager:CreateHudInfo("HUDBattery", function()
	return Dictionary:GetPhrase("ClassBattery")
end, function(ply)
	return string.format("%.2f", (ply:GetBattery() / ply:GetMaxBatteryCharge()) * 100) .. "%"
end, function(ply)
	return ply:GetBattery() < ply:GetMaxBatteryCharge()
end)
HudManager:CreateHudInfo("HUDAbilityPower", function()
	return Dictionary:GetPhrase("ClassAbilityPower")
end, function(ply)
	return string.format("%.2f", (ply:GetAbilityPower() / ply:GetMaxAbilityPower()) * 100) .. "%"
end, function(ply)
	return ply:GetAbilityPower() < ply:GetMaxAbilityPower()
end)

HudManager:CreateHudInfo("HUDAP", function()
	return Dictionary:GetPhrase("AP")
end, function(ply)
	return ply:GetAmmoPacks()
end, function()
	return true
end)