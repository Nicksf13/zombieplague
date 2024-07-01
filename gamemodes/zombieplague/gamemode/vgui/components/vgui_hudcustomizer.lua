HUDCustomizer = {
    Fonts = {
        "DebugFixed",
        "Default",
        "Trebuchet18",
        "Trebuchet24",
        "HudSelectionText",
        "CloseCaption_Normal",
        "ChatFont",
        "TargetID"
    }
}
function HUDCustomizer:CreateHUDCustomizerPanel(Parent, SelectedComponent, Border)
    local Width, Height = Parent:GetSize()
	local HudCustomizerMenu = vgui.Create("DPanel")
	HudCustomizerMenu:SetSize(Width, Height)

	local Width, Heigth = Parent:GetSize()
	
	local FullScreenWidth = Width - (Border * 2)

	local DSheet = vgui.Create("DPropertySheet", HudCustomizerMenu)

	local ColorPickerBorder = HUDCustomizer:CreateColorMixer(false)
	local ColorPickerComponent = HUDCustomizer:CreateColorMixer(true)
	local ColorPickerText = HUDCustomizer:CreateColorMixer(false)

	ColorPickerBorder:SetColor(HudManager:GetConfig(SelectedComponent, "Border"))
	ColorPickerComponent:SetColor(HudManager:GetConfig(SelectedComponent, "Body"))
	ColorPickerText:SetColor(HudManager:GetConfig(SelectedComponent, "Text"))

	local Y = 20

	DSheet:SetPos(Border, Y)
	DSheet:SetSize(FullScreenWidth, 300)
	
	DSheet:AddSheet(Dictionary:GetPhrase("HUDCustomizerTabTitleBody"), ColorPickerComponent, "icon16/color_wheel.png")
	DSheet:AddSheet(Dictionary:GetPhrase("HUDCustomizerTabTitleBorder"), ColorPickerBorder, "icon16/color_wheel.png")
    DSheet:AddSheet(Dictionary:GetPhrase("HUDCustomizerTabTitleText"), ColorPickerText, "icon16/color_wheel.png")

    local OtherOptions = self:CreateOtherOptionsTab(FullScreenWidth, Height, 20, SelectedComponent)
    DSheet:AddSheet(Dictionary:GetPhrase("HUDCustomizerTabTitleOther"), OtherOptions, "icon16/color_wheel.png")

	Y = Y + 310

	local DermaButton = vgui.Create("DButton", HudCustomizerMenu)
	DermaButton:SetText(Dictionary:GetPhrase("HUDCustomizerApplyButton"))
	DermaButton:SetPos(Border, Y)
	DermaButton:SetSize(FullScreenWidth, 25)
    function DermaButton:DoClick()
        local Combos = OtherOptions.Combos

		local Component = HudManager:GetComponentConfig(SelectedComponent)
		Component.Body = ColorPickerComponent:GetColor()
		Component.Border = ColorPickerBorder:GetColor()
		Component.Text = ColorPickerText:GetColor()

        Component.Border.a = Component.Body.a
        Component.XPos = Combos.XPos
        Component.YPos = Combos.YPos
        Component.Font = Combos.Font

		HudManager:Save()
    end
    
    return HudCustomizerMenu
end
function HUDCustomizer:CreateColorMixer(AlphaBarEnabled)
	local ColorMixer = vgui.Create("DColorMixer")

	ColorMixer:Dock(FILL)
	ColorMixer:DockMargin(10, 10, 10, 10)
	ColorMixer:SetPalette(true)
	ColorMixer:SetAlphaBar(AlphaBarEnabled)
	ColorMixer:SetWangs(true)

	return ColorMixer
end

function HUDCustomizer:CreateOtherOptionsTab(Width, Height, Border, SelectedComponent)
    local RealWidth = Width - (Border * 2)
    local RealHeight = Height - (Border * 2)
    local XOptions = {
        HUDCustomizerLeft = HUD_LEFT,
        HUDCustomizerCenter = HUD_CENTER,
        HUDCustomizerRight = HUD_RIGHT
    }

    local YOptions = {
        HUDCustomizerTop = HUD_TOP,
        HUDCustomizerCenter = HUD_CENTER,
        HUDCustomizerBottom = HUD_BOTTOM
    }
    
    local Options = HudManager:GetComponentConfig(SelectedComponent)

    local DOtherOptions = vgui.Create("DPanel")
    DOtherOptions.Combos = {}
    DOtherOptions:Dock(FILL)
    DOtherOptions:DockMargin(Border, Border, Border, Border)

    local Y = 30
    local DLabelXPos = vgui.Create("DLabel", DOtherOptions)
    DLabelXPos:SetSize(RealWidth, 23)
    DLabelXPos:SetPos(0, Y)
    DLabelXPos:SetText(Dictionary:GetPhrase("HUDCustomizerLabelX"))
    DLabelXPos:SetTextColor(Color(0, 0, 0))

    Y = Y + 25
    local DComboBoxXPos = vgui.Create("DComboBox", DOtherOptions)
    DComboBoxXPos:SetSize(RealWidth, 23)
    DComboBoxXPos:SetPos(0, Y)
    
    for Text, Value in pairs(XOptions) do
        local TranslatedText = Dictionary:GetPhrase(Text)
        DComboBoxXPos:AddChoice(TranslatedText, Value)

        if Value == Options.XPos then
            DComboBoxXPos:SetValue(TranslatedText)

            DOtherOptions.Combos.XPos = Options.XPos
        end
    end

    function DComboBoxXPos:OnSelect(Index, Text, XPos)
        DOtherOptions.Combos.XPos = XPos
    end

    Y = Y + 25
    local DLabelYPos = vgui.Create("DLabel", DOtherOptions)
    DLabelYPos:SetSize(RealWidth, 23)
    DLabelYPos:SetPos(0, Y)
    DLabelYPos:SetText(Dictionary:GetPhrase("HUDCustomizerLabelY"))
    DLabelYPos:SetTextColor(Color(0, 0, 0))

    Y = Y + 25
    local DComboBoxYPos = vgui.Create("DComboBox", DOtherOptions)
    DComboBoxYPos:SetSize(RealWidth, 23)
    DComboBoxYPos:SetPos(0, Y)
    for Text, Value in pairs(YOptions) do
        local TranslatedText = Dictionary:GetPhrase(Text)
        DComboBoxYPos:AddChoice(TranslatedText, Value)

        if Value == Options.YPos then
            DComboBoxYPos:SetValue(TranslatedText)

            DOtherOptions.Combos.YPos = Options.YPos
        end
    end

    function DComboBoxYPos:OnSelect(Index, Text, YPos)
        DOtherOptions.Combos.YPos = YPos
    end

    Y = Y + 25
    local DLabelFont = vgui.Create("DLabel", DOtherOptions)
    DLabelFont:SetSize(RealWidth, 23)
    DLabelFont:SetPos(0, Y)
    DLabelFont:SetText(Dictionary:GetPhrase("HUDCustomizerLabelFont"))
    DLabelFont:SetTextColor(Color(0, 0, 0))

    Y = Y + 25
    local DComboBoxFont = vgui.Create("DComboBox", DOtherOptions)
    DComboBoxFont:SetSize(RealWidth, 23)
    DComboBoxFont:SetPos(0, Y)
    DComboBoxFont:SetValue(self.Fonts[1])

    for k, Font in pairs(self.Fonts) do
        DComboBoxFont:AddChoice(Font, Font)
        
        if Font == Options.Font then
            DComboBoxFont:SetValue(Font)

            DOtherOptions.Combos.Font = Options.Font
        end
    end

    function DComboBoxFont:OnSelect(Index, Text, Font)
        DOtherOptions.Combos.Font = Font
    end

    return DOtherOptions
end

OptionMenu:AddItem("ZPHUDCustomizer", "HUDCustomizerMenu", function(Parent)
    return HUDCustomizer:CreateHUDCustomizerPanel(Parent, "Menu", 20)
end)
OptionMenu:AddItem("ZPHUDCustomizer", "HUDCustomizerStatus", function(Parent)
    return HUDCustomizer:CreateHUDCustomizerPanel(Parent, "Status", 20)
end)
OptionMenu:AddItem("ZPHUDCustomizer", "HUDCustomizerTimer", function(Parent)
    return HUDCustomizer:CreateHUDCustomizerPanel(Parent, "Timer", 20)
end)