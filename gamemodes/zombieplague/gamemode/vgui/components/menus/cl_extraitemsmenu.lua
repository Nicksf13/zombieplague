ExtraItemsMenu = {}

function ExtraItemsMenu:Init()
    local Self = self

    Self.ExtraItemsList = {}
    function self:SetExtraItemsList(ExtraItemsList)
        local PrettyTable = {}

        for ExtraItemID, ExtraItem in pairs(ExtraItemsList) do
            local CreateExtraItemFunction = function()
                local DTitledModelPanel = vgui.Create("DTitledModelPanel")
                local DTitledModelPanelBody = DTitledModelPanel:GetBody()
                DTitledModelPanel:SetTitle(ExtraItem.Name)
                DTitledModelPanel:SetModel(ExtraItem.WorldModel)
                DTitledModelPanel:SetRotationType(ALWAYS_ROTATE)
                if ExtraItem.Description then
                    local Description = vgui.Create("DCenteredLabel", DTitledModelPanelBody)
                    Description:SetText(ExtraItem.Description)
                    Description:SetTextColor(Color( 255, 255, 255))
                    Description:SetFont("Trebuchet18")
                    Description:SetBackgroundColor(Color(0, 0, 0, 90))

                    function DTitledModelPanelBody:PerformLayout(Width, Height)
                        local DescriptionHeight = 30
                        Description:SetSize(Width, DescriptionHeight)
                        Description:SetPos(0, Height - DescriptionHeight)
                    end
                end

                DTitledModelPanel:SetDoClickFunction(function()
                    net.Start(self:GetNetworkString())
                        net.WriteString(ExtraItemID)
                        net.WriteBool(false)
                    net.SendToServer()
                end)

                return DTitledModelPanel
            end

            local Option = {
                Object = ExtraItem,
                PanelCreateFunction = CreateExtraItemFunction
            }

            table.insert(PrettyTable, Option)
        end

        local ExtraItemsPanel = Self.ExtraItemsPanel
        ExtraItemsPanel:SetOptions(PrettyTable)
    end

    function self:CreateExtraItemsComponents()
        local ExtraItemsPanel = vgui.Create("DFilterScrollPanel", Self)
        ExtraItemsPanel:SetCategoryFilter(true)
	    ExtraItemsPanel:SetSortCombobox(true)
        ExtraItemsPanel:SetDesiredItemFrameSize(240, 240)
        ExtraItemsPanel:AddSortOption(Dictionary:GetPhrase("VGUIExtraItemsMenuOrderByNameAsc"), "Name", true)
	    ExtraItemsPanel:AddSortOption(Dictionary:GetPhrase("VGUIExtraItemsMenuOrderByNameDesc"), "Name", false)
        ExtraItemsPanel:AddSortOption(Dictionary:GetPhrase("VGUIExtraItemsMenuOrderByPriceAsc"), "Price", true)
	    ExtraItemsPanel:AddSortOption(Dictionary:GetPhrase("VGUIExtraItemsMenuOrderByPriceDesc"), "Price", false)
        ExtraItemsPanel:AddSortOption(Dictionary:GetPhrase("VGUIExtraItemsMenuOrderByCategoryAsc"), "Category", true)
        ExtraItemsPanel:AddSortOption(Dictionary:GetPhrase("VGUIExtraItemsMenuOrderByCategoryDesc"), "Category", false)
        ExtraItemsPanel:SetFilterPlaceholder(Dictionary:GetPhrase("VGUIMenuFilter"))
        ExtraItemsPanel:SetOrderByText(Dictionary:GetPhrase("VGUIMenuOrderBy"))
        ExtraItemsPanel:SetAllCategoriesDescription(Dictionary:GetPhrase("VGUIMenuAllCategories"))
        ExtraItemsPanel:SetCategoryFilterProperty("Category")
	    ExtraItemsPanel:SetNameProperty("Name")

        Self.ExtraItemsPanel = ExtraItemsPanel
    end
    function self:CalculateExtraItemsList()
        local Width = math.floor(Self:GetWide())
        local Height = Self:GetTall()

        local ExtraItemsPanel = Self.ExtraItemsPanel
        ExtraItemsPanel:SetSize(Width, Height)
        ExtraItemsPanel:CalculateScrollComponents()
    end
    function self:SetNetworkString(NetworkString)
        Self.NetworkString = NetworkString
    end
    function self:GetNetworkString()
        return Self.NetworkString
    end
    function self:SetOnClickFunction(OnClickFunction)
        Self.OnClickFunction = OnClickFunction
    end
    function self:GetOnClickFunction()
        return Self.OnClickFunction
    end
    function self:PerformLayout()
        Self:CalculateExtraItemsList()
    end

    Self:CreateExtraItemsComponents()
end
function ExtraItemsMenu:CreateDFrameMenu(TitleText, ExtraItemsList, NetworkString)
    local TitleMenu = vgui.Create("DTitleMenu")
	TitleMenu:MakePopup()
	TitleMenu:SetTitleText(TitleText)

    local ExtraItemsMenuPanel = vgui.Create("ExtraItemsMenu")
    ExtraItemsMenuPanel:SetExtraItemsList(ExtraItemsList)
    ExtraItemsMenuPanel:SetNetworkString(NetworkString)
    ExtraItemsMenuPanel:SetOnClickFunction(function()
        TitleMenu:Close()
    end)

    TitleMenu:SetContent(ExtraItemsMenuPanel)
    ExtraItemsMenuPanel:Dock(FILL)
end
function ExtraItemsMenu:Paint(Width, Height)end

vgui.Register("ExtraItemsMenu", ExtraItemsMenu, "DPanel")