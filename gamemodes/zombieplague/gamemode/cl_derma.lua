OptionMenu = {ContentPanelBorder = 20, Categories = {}, WarningPopups = {}}
function OptionMenu:CreateOptionsMenu()
	local FrameWidth = 600
	local FrameHeight = 415
	local BorderTop = 30
	local BorderBottom = 20
	local BorderLeft = 20
	local BorderRight = 20

	local DOptionMenu = vgui.Create("DFrame")
	DOptionMenu:SetDraggable(false)
	DOptionMenu:SetDeleteOnClose(true)
	DOptionMenu:SetSize(FrameWidth, FrameHeight)
	DOptionMenu:SetTitle(Dictionary:GetPhrase("ZombiePlagueOptions"))
	DOptionMenu:Center()
	function DOptionMenu:Paint(Width, Height)
		HudManager:CreateBox(2, 4, Color(36, 36, 36), Color(145, 145, 145), 0, 0, Width, Height)
	end
	function DOptionMenu:OnClose()
		for k, Popups in pairs(OptionMenu.WarningPopups) do
			if Popups.Close then
				Popups:Close()
			end
		end
		
		OptionMenu.WarningPopups = {}
	end

	local ContentPanel = vgui.Create("DPanel", DOptionMenu)
	local CatListWidth = 200
	local OptionCatList = vgui.Create("DCategoryList", DOptionMenu)
	OptionCatList:SetPos(BorderLeft, BorderTop)
	OptionCatList:SetSize(CatListWidth, FrameHeight - BorderTop - BorderBottom)

	for CategoryID, Category in pairs(self.Categories) do
		local CategoryComponent = OptionCatList:Add(Dictionary:GetPhrase(CategoryID))
		for ItemID, CreateFunction in pairs(Category) do
			local ItemComponent = CategoryComponent:Add(Dictionary:GetPhrase(ItemID))
			function ItemComponent:DoClick()
				ContentPanel:Clear()

				ContentPanel:Add(CreateFunction(ContentPanel))
			end
		end
	end
	
	local ContentPanelX = CatListWidth + 30
	ContentPanel:SetPos(ContentPanelX, BorderTop)
	ContentPanel:SetSize(FrameWidth - BorderRight - ContentPanelX, FrameHeight - BorderTop - BorderBottom)
	ContentPanel:SetBackgroundColor(Color(200, 200, 200))

	DOptionMenu:MakePopup()
end
function OptionMenu:AddItem(Category, ItemID, CreateFunction)
	if !self.Categories[Category] then
		self.Categories[Category] = {}
	end

	self.Categories[Category][ItemID] = CreateFunction
end
function OptionMenu:CreateWarningPopup(TitleText, Text, YesText, YesFunction, NoText, NoFunction)
	local Width = 400
	local Height = 100
	local HalfWidth = Width / 2
	local ButtonWidth = 100
	local ButtonHeight = 30

	local WarningPopup = vgui.Create("DFrame")
	WarningPopup:SetDeleteOnClose(true)
	WarningPopup:SetSize(Width, Height)
	WarningPopup:ShowCloseButton(false)
	WarningPopup:SetTitle(TitleText)
	WarningPopup:Center()
	WarningPopup:SetDraggable(false)

	local LblText = vgui.Create("DLabel", WarningPopup)
	LblText:SetText(Text)

	local TextWidth = LblText:GetTextSize()
	LblText:SetSize(TextWidth, 30)
	LblText:SetPos(HalfWidth - (TextWidth / 2), 30)

	local BtnYes = vgui.Create("DButton", WarningPopup)
	BtnYes:SetSize(ButtonWidth, ButtonHeight)
	BtnYes:SetPos(HalfWidth - ButtonWidth - 10, 60)
	BtnYes:SetText(YesText)

	local BtnNo = vgui.Create("DButton", WarningPopup)
	BtnNo:SetSize(ButtonWidth, ButtonHeight)
	BtnNo:SetPos(HalfWidth + 10, 60)
	BtnNo:SetText(NoText)

	BtnYes.DoClick = function()
		YesFunction()

		WarningPopup:Close()
	end
	BtnNo.DoClick = function()
		if NoFunction then
			NoFunction()
		end

		WarningPopup:Close()
	end

	WarningPopup:MakePopup()
	
	table.insert(self.WarningPopups, WarningPopup)
end

include("zombieplague/gamemode/vgui/vgui_hudcustomizer.lua")
include("zombieplague/gamemode/vgui/vgui_keybinding.lua")