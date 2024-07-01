WeaponChooseMenu = {
    CheckedColor = Color(88, 196, 84, 250),
    UncheckedColor = Color(255, 255, 255, 250),
    SaveSelectionTextFont = "Trebuchet24",
    CheckButtonSize = 30
}

function WeaponChooseMenu:Init()
    local Self = self

    function self:SetSaveSelectionText(SaveSelectionText)
        Self.SaveSelectionLabel:SetText(SaveSelectionText)

        self:CalculateHeaderComponents()
    end
    function self:SetSaveSelection(SaveSelection)
        Self.SaveSelectionCheck:SetValue(SaveSelection)
    end
    function self:SetWeaponList(WeaponList)
        local PrettyTable = {}
        for Class, WeaponInfo in pairs(WeaponList) do
            local Weapon = WeaponChooseMenu:GetWeapon(Class)
            local WeaponObject = {
                Name = WeaponInfo.Description,
                Category = Weapon.Category
            }

            local CreateWeaponOptionPanel = function()
                local DTitledModelPanel = vgui.Create("DTitledModelPanel")
                DTitledModelPanel:SetTitle(WeaponInfo.Description)
                DTitledModelPanel:SetModel(Weapon.WorldModel)
                if WeaponInfo.IsSelected then
                    DTitledModelPanel:SetTitleHoveredBackgroundColor(Color(88, 196, 84, 250))
                    DTitledModelPanel:SetTitleBackgroundColor(Color(88, 196, 84, 250))
                end
                DTitledModelPanel:SetDoClickFunction(function()
                    net.Start(self:GetNetworkString())
                        net.WriteString(Class)
                        net.WriteBool(true)
                        net.WriteTable({
                            ShouldSaveWeapon = {
                                Value = Self.SaveSelectionCheck:GetChecked()
                            }
                        })
                    net.SendToServer()

                    Self:GetOnClickFunction()()
                end)

                return DTitledModelPanel
            end

            local Option = {
                Object = WeaponObject,
                PanelCreateFunction = CreateWeaponOptionPanel
            }

            table.insert(PrettyTable, Option)
        end
        
        local WeaponListPanel = Self.WeaponListPanel
        WeaponListPanel:SetOptions(PrettyTable)
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
        return self.OnClickFunction
    end

    function self:CreateHeader()
        local CheckedColor = WeaponChooseMenu.CheckedColor
        local UncheckedColor = WeaponChooseMenu.UncheckedColor
        local SaveSelectionTextFont = WeaponChooseMenu.SaveSelectionTextFont
        local CheckButtonSize = WeaponChooseMenu.CheckButtonSize
    
        local SaveSelectionLabel = vgui.Create("DLabel", Self)
        SaveSelectionLabel:SetFont(SaveSelectionTextFont)
    
        local SaveSelectionCheck = vgui.Create("DCheckBox", Self)
        SaveSelectionCheck:SetSize(CheckButtonSize, CheckButtonSize)
        SaveSelectionCheck:SetText("")
        SaveSelectionCheck:SetValue(false)
        function SaveSelectionCheck:Paint(Width, Height)
            if SaveSelectionCheck:GetChecked() then
                HudManager:CreateBox(0, 0, Color(0, 0, 0, 0), CheckedColor, 0, 0, Width, Height)
            else
                HudManager:CreateBox(0, 0, Color(0, 0, 0, 0), UncheckedColor, 0, 0, Width, Height)
            end
        end
    
        Self.SaveSelectionLabel = SaveSelectionLabel
        Self.SaveSelectionCheck = SaveSelectionCheck
    end
    function self:CalculateHeaderComponents()
        local Width, Height = Self:GetSize()
        local SaveSelectionTextFont = WeaponChooseMenu.SaveSelectionTextFont
        local SaveSelectionLabel = Self.SaveSelectionLabel
        local SaveSelectionCheck = Self.SaveSelectionCheck
        local TextWidth, TextHeight = HudManager:CalculateTextSize(SaveSelectionLabel:GetText(), SaveSelectionTextFont)
        local CheckButtonSize = WeaponChooseMenu.CheckButtonSize

        SaveSelectionLabel:SetSize(TextWidth, TextHeight)
        SaveSelectionLabel:SetPos(Width - TextWidth - CheckButtonSize - 10, 3)

        SaveSelectionCheck:SetPos(Width - CheckButtonSize, 0)
    end
    function self:CreateBody()
        local WeaponListPanel = vgui.Create("DFilterScrollPanel", self)
		WeaponListPanel:SetCategoryFilter(true)
		WeaponListPanel:SetSortCombobox(true)
		WeaponListPanel:AddSortOption(Dictionary:GetPhrase("VGUIWeaponChooseMenuOrderByNameAsc"), "Name", true)
		WeaponListPanel:AddSortOption(Dictionary:GetPhrase("VGUIWeaponChooseMenuOrderByNameDesc"), "Name", false)
        WeaponListPanel:AddSortOption(Dictionary:GetPhrase("VGUIWeaponChooseMenuOrderByCategoryAsc"), "Category", true)
		WeaponListPanel:AddSortOption(Dictionary:GetPhrase("VGUIWeaponChooseMenuOrderByCategoryDesc"), "Category", false)
		WeaponListPanel:SetCategoryFilterProperty("Category")
		WeaponListPanel:SetAllCategoriesDescription(Dictionary:GetPhrase("VGUIMenuAllCategories"))
        WeaponListPanel:SetFilterPlaceholder(Dictionary:GetPhrase("VGUIMenuFilter"))
        WeaponListPanel:SetOrderByText(Dictionary:GetPhrase("VGUIMenuOrderBy"))
		WeaponListPanel:SetNameProperty("Name")
        WeaponListPanel:SetDesiredItemFrameSize(180, 180)

        Self.WeaponListPanel = WeaponListPanel
    end
    function self:CalculateBody()
        local WeaponListPanel = Self.WeaponListPanel

        WeaponListPanel:Dock(FILL)
        WeaponListPanel:CalculateScrollComponents()
    end
    function self:PerformLayout()
        Self:CalculateHeaderComponents()
        Self:CalculateBody()
    end

    Self:CreateBody()
    Self:CreateHeader()
end


function WeaponChooseMenu:CreateDFrameMenu(TitleText, WeaponList, ShouldSaveWeapon, NetworkString)
    local TitleMenu = vgui.Create("DTitleMenu")
	TitleMenu:MakePopup()
	TitleMenu:SetTitleText(TitleText)

    local WeaponMenu = vgui.Create("WeaponChooseMenu")
    WeaponMenu:SetSaveSelectionText(Dictionary:GetPhrase("VGUIWeaponChooseMenuSaveSelection"))
    WeaponMenu:SetSaveSelection(ShouldSaveWeapon)
    WeaponMenu:SetWeaponList(WeaponList)
    WeaponMenu:SetNetworkString(NetworkString)
    WeaponMenu:SetOnClickFunction(function()
        TitleMenu:Close()
    end)

    TitleMenu:SetContent(WeaponMenu)
    WeaponMenu:Dock(FILL)
end

function WeaponChooseMenu:GetWeapon(WeaponClass)
    local WeaponEntity = weapons.Get(WeaponClass)

    if WeaponEntity then
        return WeaponEntity
    end

    return WeaponChooseMenu:GetHalfLifeWeapons()[WeaponClass]
end
function WeaponChooseMenu:Paint(Width, Height)end

function WeaponChooseMenu:GetHalfLifeWeapons()
    local HL2Weapons = {}
    HL2Weapons["weapon_357"] = {
        WorldModel = "models/weapons/w_357.mdl",
        Category = "Half-Life 2"
    }
    HL2Weapons["weapon_ar2"] = {
        WorldModel = "models/weapons/w_irifle.mdl",
        Category = "Half-Life 2"
    }
    HL2Weapons["weapon_crossbow"] = {
        WorldModel = "models/weapons/w_crossbow.mdl",
        Category = "Half-Life 2"
    }
    HL2Weapons["weapon_crowbar"] = {
        WorldModel = "models/weapons/w_crowbar.mdl",
        Category = "Half-Life 2"
    }
    HL2Weapons["weapon_pistol"] = {
        WorldModel = "models/weapons/w_pistol.mdl",
        Category = "Half-Life 2"
    }
    HL2Weapons["weapon_shotgun"] = {
        WorldModel = "models/weapons/w_shotgun.mdl",
        Category = "Half-Life 2"
    }
    HL2Weapons["weapon_smg1"] = {
        WorldModel = "models/weapons/w_smg1.mdl",
        Category = "Half-Life 2"
    }
    HL2Weapons["weapon_stunstick"] = {
        WorldModel = "models/weapons/w_stunbaton.mdl",
        Category = "Half-Life 2"
    }

    return HL2Weapons
end

vgui.Register("WeaponChooseMenu", WeaponChooseMenu, "DPanel")