CATEGORY_FILTER_ALL = "ALL"

DFilterScrollPanel = {
    HeaderComponentWidth = 160,
    HeaderComponentHeight = 30,
    HeaderComponentSpaceBetween = 10,
    DefaultScrollComponentWidth = 160,
    DefaultScrollComponentHeight = 160
}

function DFilterScrollPanel:Init()
    local Self = self
    local Filter = vgui.Create("DTextEntry", self)
    Filter:SetPos(0, 0)
    Filter:SetPlaceholderText("Filter")
    Filter:SetUpdateOnType(true)
    function Filter:OnValueChange(Value)
        Self:CalculateScrollComponents()
    end

    local CategoryCombo = vgui.Create("DComboBox", self)
    CategoryCombo.OnSelect = function(self, index, value, data)
        Self:CalculateScrollComponents()
    end
    local SortCombo = vgui.Create("DComboBox", self)
    SortCombo.OnSelect = function(self, index, value, data)
        Self:CalculateScrollComponents()
    end
    local Scroll = vgui.Create("DScrollPanel", self)
    local List = vgui.Create("DIconLayout", Scroll)

    self.Filter = Filter
    self.CategoryCombo = CategoryCombo
    self.SortCombo = SortCombo
    self.Scroll = Scroll
    self.List = List
    self.SpaceBetween = 2
    self.DesiredItemFrameWidth = 128
    self.DesiredItemFrameHeight = 128
    self.FilterText = ""
    self.AllCategoriesDescription = ""
    self.Options = {}

    function self:AddOption(Object, PanelCreateFunction)
        local Option = {
            Object = Object,
            PanelCreateFunction = PanelCreateFunction
        }
    
        table.insert(Self.Options, Option)
        
        Self:CalculateComponents()
    end
    function self:SetOptions(Options)
        Self.Options = Options

        Self:CalculateComponents()
    end

    function self:GetOptions()
        return Self.Options
    end

    function self:SetNameProperty(NameProperty)
        Self.NameProperty = NameProperty
    end
    function self:GetNameProperty()
        return Self.NameProperty
    end
    
    function self:AddSortOption(Description, PropertyToSort, Asc)
        local SortCombo = Self.SortCombo
        local SortOptions = {
            PropertyToSort = PropertyToSort,
            Asc = Asc
        }
    
        local Icon = Asc and "materials/icon16/ARROW_UP.png" or "materials/icon16/ARROW_DOWN.png"
        SortCombo:AddChoice(Description, SortOptions, false, Icon)
    end
    function self:SetCategoryFilterProperty(CategoryFilterProperty)
        Self.CategoryFilterProperty = CategoryFilterProperty
    
        self:CreateCategories()
    end
    function self:GetCategoryFilterProperty()
        return Self.CategoryFilterProperty
    end
    function self:SetAllCategoriesDescription(AllCategoriesDescription)
        Self.AllCategoriesDescription = AllCategoriesDescription
    end
    function self:GetAllCategoriesDescription()
        return Self.AllCategoriesDescription
    end
    function self:SetSortByDescription(SortByDescription)
        SortCombo:SetValue(SortByDescription)
    end
    function self:CreateCategories()
        local Property = Self.GetCategoryFilterProperty()
    
        if !Property then
            return
        end
        local CategoryCombo = Self.CategoryCombo

        CategoryCombo:Clear()
        CategoryCombo:AddChoice(Self:GetAllCategoriesDescription(), CATEGORY_FILTER_ALL, true)
    
        local Categories = {}
        for Key, Option in pairs(self:GetOptions()) do
            local OptionObject = Option.Object
    
            Categories[OptionObject[Property]] = Categories[OptionObject[Property]] and Categories[OptionObject[Property]] + 1 or 1
        end
    
        for Category, Value in pairs(Categories) do
            CategoryCombo:AddChoice(Category, Category)
        end
    end
    
    function self:SetCategoryFilter(CategoryFilter)
        Self.CategoryFilter = CategoryFilter
        
        Self:CalculateHeaderComponents()
    end
    function self:HasCategoryFilter()
        return Self.CategoryFilter
    end
    function self:SetSortCombobox(SortCombobox)
        Self.SortCombobox = SortCombobox
    
        self:CalculateHeaderComponents()
    end
    function self:HasSortCombobox()
        return Self.SortCombobox
    end
    function self:SetFilterPlaceholder(Placeholder)
        Self.Filter:SetPlaceholderText(Placeholder)
    end
    function self:SetOrderByText(OrderByText)
        Self.SortCombo:SetValue(OrderByText)
    end
    function self:SetDesiredItemFrameSize(Width, Size)
        Self:SetDesiredItemFrameWidth(Width)
        Self:SetDesiredItemFrameHeight(Size)
    end
    function self:SetDesiredItemFrameWidth(DesiredItemFrameWidth)
        Self.DesiredItemFrameWidth = DesiredItemFrameWidth
    end
    function self:GetDesiredItemFrameWidth()
        return Self.DesiredItemFrameWidth
    end
    function self:SetDesiredItemFrameHeight(DesiredItemFrameHeight)
        Self.DesiredItemFrameHeight = DesiredItemFrameHeight
    end
    function self:GetDesiredItemFrameHeight()
        return Self.DesiredItemFrameHeight
    end
    function self:SetSpaceBetween(SpaceBetween)
        Self.SpaceBetween = SpaceBetween
    end
    function self:GetSpaceBetween()
        return Self.SpaceBetween
    end
    
    function self:CalculateHeaderComponents()
        local Filter = Self.Filter
        local CategoryCombo = Self.CategoryCombo
        local SortCombo = Self.SortCombo
        local Width = DFilterScrollPanel.HeaderComponentWidth
        local Height = DFilterScrollPanel.HeaderComponentHeight
        local SpaceBetween = DFilterScrollPanel.HeaderComponentSpaceBetween
    
        Filter:SetSize(Width, Height)
    
        local PosX = Width + SpaceBetween
        if self:HasCategoryFilter() then
            CategoryCombo:SetSize(Width, Height)
            CategoryCombo:SetPos(PosX, 0)
    
            PosX = PosX + Width + SpaceBetween
        else
            CategoryCombo:SetSize(0, 0)
        end
    
        if self:HasSortCombobox() then
            SortCombo:SetSize(Width, Height)
            SortCombo:SetPos(PosX, 0)
        else
            SortCombo:SetSize(0, 0)
        end
    end
    function self:CalculateScrollComponents()
        local Width = self:GetWide()
        local Height = self:GetTall() - DFilterScrollPanel.HeaderComponentHeight - 10
        local PosX = 0
        local PosY = self:GetTall() - Height
        local SpaceBetween = self:GetSpaceBetween()
        local ScrollWidth = 10
        local WidthWithoutScroll = Width - ScrollWidth
        local DesiredItemFrameWidth = self:GetDesiredItemFrameWidth()
        local DesiredItemFrameHeight = self:GetDesiredItemFrameHeight()
        local Scroll = Self.Scroll
        local List = Self.List
        local Filter = Self.Filter
        local CategoryCombo = Self.CategoryCombo
        local SortCombo = Self.SortCombo

        Scroll:SetSize(Width, Height)
        Scroll:SetPos(PosX, PosY)

        List:Clear()
        List:SetSize(Width, Height)
        List:SetPos(0, 0)
        List:SetSpaceX(SpaceBetween)
        List:SetSpaceY(SpaceBetween)

        local WidthRest = WidthWithoutScroll % (DesiredItemFrameWidth + SpaceBetween)
        local TotalItemsPerLine = math.floor(WidthWithoutScroll / (DesiredItemFrameWidth + SpaceBetween))
        local AmountToDivide = math.floor(WidthRest / TotalItemsPerLine)
        local ItemFrameWidth = DesiredItemFrameWidth + AmountToDivide
        local SelectedCategory = CategoryCombo:GetOptionData(CategoryCombo:GetSelectedID())
        local NameProperty = Self.GetNameProperty()
        local FilterProperty = Self.GetCategoryFilterProperty()

        local CopyOfOptions = {}
        
        for Key, Option in pairs(self:GetOptions()) do
            local ObjectCategory = Option.Object[FilterProperty]
            local ObjectName = Option.Object[NameProperty] and Option.Object[NameProperty] or ""

            if SelectedCategory == CATEGORY_FILTER_ALL || ObjectCategory == SelectedCategory then
                local LowerObjectName = string.lower(ObjectName)
                local LowerFilterText = string.lower(Filter:GetValue())

                if LowerFilterText == "" || string.find(LowerObjectName, LowerFilterText) then
                    table.insert(CopyOfOptions, Option)
                end
            end
        end

        local SortOptions = SortCombo:GetSelected()
        if SortOptions then
            table.sort(CopyOfOptions, function(a1, a2)
                local _, SortOptions = SortCombo:GetSelected()

                local Object1 = a1.Object
                local Object2 = a2.Object

                local ComparissonValue1 = Object1[SortOptions.PropertyToSort]
                local ComparissonValue2 = Object2[SortOptions.PropertyToSort]

                local IsAsc = SortOptions.Asc

                if IsAsc then
                    return ComparissonValue1 < ComparissonValue2
                end

                return ComparissonValue1 > ComparissonValue2
            end)
        end

        for Key, Option in pairs(CopyOfOptions) do
            local Panel = Option.PanelCreateFunction()
            Panel:SetSize(ItemFrameWidth, DesiredItemFrameHeight)
            local W, H = Panel:GetSize()

            List:Add(Panel)
        end
    end
    function self:CalculateComponents()
        Self:CalculateHeaderComponents()
        Self:CreateCategories()
        Self:CalculateScrollComponents()
    end
end
function DFilterScrollPanel:Paint(Width, Height)end

vgui.Register("DFilterScrollPanel", DFilterScrollPanel, "DPanel")