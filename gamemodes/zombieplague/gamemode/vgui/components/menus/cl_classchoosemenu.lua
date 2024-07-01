ClassChooseMenu = {}

function ClassChooseMenu:CreateDFrameMenu(Title, ClassTable, NetworkString)
    local Menu = TitleMenu:CreateTitleMenu(Title, ClassChooseMenu.CloseMenu)

    self.ClassMenu = Menu

    Menu:SetContent(ClassChooseMenu:CreateMenu(ClassTable, NetworkString))
end

function ClassChooseMenu:Init()
    local Self = self

    function self:SetClassList(ClassList)
        local PrettyTable = {}

        for ClassKey, Class in pairs(ClassList) do
            local Name = Dictionary:GetPhrase(Class.Name)
            local PrettierClass = {
                Name = Name,
                MaxHealth = Class.MaxHealth,
                Armor = Class.Armor,
                Speed = Class.Speed,
                RunSpeed = Class.RunSpeed,
                CrouchSpeed = Class.CrouchSpeed,
                Gravity = Class.Gravity,
                Breath = Class.Breath,
                Footstep = Class.Footstep,
                JumpPower = Class.JumpPower,
                DamageAmplifier = Class.DamageAmplifier,
                Ability = Class.Ability and 1 or 0,
                FallDamage = Class.FallDamage and 1 or 0,
            }

            local CreateClassFunction = function()
                local DTitledModelPanel = vgui.Create("DTitledModelPanel")
                local DTitledModelPanelBody = DTitledModelPanel:GetBody()
                local Description = vgui.Create("DCenteredLabel", DTitledModelPanelBody)
                DTitledModelPanel:SetTitle(Name)
                DTitledModelPanel:SetModel(Class.PModel)
                DTitledModelPanel:SetAnimationTrigger(ANIMATION_HOVER_ONLY)
                DTitledModelPanel:SetIdleSequenceName(Class.IdleAnimationId)
                Description:SetText(Dictionary:GetPhrase(Class.Description))
                Description:SetTextColor(Color( 255, 255, 255))
                Description:SetFont("Trebuchet18")
                Description:SetBackgroundColor(Color(0, 0, 0, 120))
                Description:SetZPos(1)
                if Class.IsPlayerClass then
                    DTitledModelPanel:SetTitleHoveredBackgroundColor(Color(88, 196, 84, 250))
                    DTitledModelPanel:SetTitleBackgroundColor(Color(88, 196, 84, 250))
                end

                DTitledModelPanel:SetDoClickFunction(function()
                    net.Start(self:GetNetworkString())
                        net.WriteString(ClassKey)
                        net.WriteBool(false)
                    net.SendToServer()

                    Self:GetOnClickFunction()()
                end)

                DTitledModelPanel:SetOnCursorEnteredFunction(function()
                    DTitledModelPanel:PlayAnimation(Class.AnimationId)
                end)

                function DTitledModelPanelBody:PerformLayout(Width, Height)
                    local DescriptionHeight = 30
                    Description:SetSize(Width, DescriptionHeight)
                    Description:SetPos(0, Height - DescriptionHeight)
                end

                return DTitledModelPanel
            end

            local Option = {
                Object = PrettierClass,
                PanelCreateFunction = CreateClassFunction
            }

            table.insert(PrettyTable, Option)
        end

        local ClassListPanel = Self.ClassListPanel
        ClassListPanel:SetOptions(PrettyTable)
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
    function self:CreateClassList()
        local ClassListPanel = vgui.Create("DFilterScrollPanel", self)
        ClassListPanel:SetCategoryFilter(false)
	    ClassListPanel:SetSortCombobox(true)
        ClassListPanel:SetDesiredItemFrameSize(300, 300)
        ClassListPanel:AddSortOption(Dictionary:GetPhrase("VGUIClassChooseMenuOrderByNameAsc"), "Name", true)
	    ClassListPanel:AddSortOption(Dictionary:GetPhrase("VGUIClassChooseMenuOrderByNameDesc"), "Name", false)
        ClassListPanel:AddSortOption(Dictionary:GetPhrase("VGUIClassChooseMenuOrderByHealthAsc"), "MaxHealth", true)
	    ClassListPanel:AddSortOption(Dictionary:GetPhrase("VGUIClassChooseMenuOrderByHealthDesc"), "MaxHealth", false)
        ClassListPanel:AddSortOption(Dictionary:GetPhrase("VGUIClassChooseMenuOrderBySpeedAsc"), "Speed", true)
	    ClassListPanel:AddSortOption(Dictionary:GetPhrase("VGUIClassChooseMenuOrderBySpeedDesc"), "Speed", false)
        ClassListPanel:AddSortOption(Dictionary:GetPhrase("VGUIClassChooseMenuOrderByGravityAsc"), "Gravity", true)
	    ClassListPanel:AddSortOption(Dictionary:GetPhrase("VGUIClassChooseMenuOrderByGravityDesc"), "Gravity", false)
        ClassListPanel:AddSortOption(Dictionary:GetPhrase("VGUIClassChooseMenuOrderByHasAbilityAsc"), "Ability", true)
	    ClassListPanel:AddSortOption(Dictionary:GetPhrase("VGUIClassChooseMenuOrderByHasAbilityDesc"), "Ability", false)
        if LocalPlayer():IsHuman() then
            ClassListPanel:AddSortOption(Dictionary:GetPhrase("VGUIClassChooseMenuOrderByArmorAsc"), "Armor", true)
            ClassListPanel:AddSortOption(Dictionary:GetPhrase("VGUIClassChooseMenuOrderByArmorDesc"), "Armor", false)
        end
        ClassListPanel:SetFilterPlaceholder(Dictionary:GetPhrase("VGUIMenuFilter"))
        ClassListPanel:SetOrderByText(Dictionary:GetPhrase("VGUIMenuOrderBy"))
	    ClassListPanel:SetNameProperty("Name")

        Self.ClassListPanel = ClassListPanel
    end
    function self:CalculateClassList()
        local Width = Self:GetWide()
        local Height = Self:GetTall()

        local ClassListPanel = Self.ClassListPanel
        ClassListPanel:SetSize(Width, Height)
        ClassListPanel:CalculateScrollComponents()
    end

    function self:PerformLayout()
        Self:CalculateClassList()
    end

    Self:CreateClassList()
end
function ClassChooseMenu:Paint(Width, Height)end
function ClassChooseMenu:CreateDFrameMenu(TitleText, ClassList, NetworkString)
    local TitleMenu = vgui.Create("DTitleMenu")
	TitleMenu:MakePopup()
	TitleMenu:SetTitleText(TitleText)

    local ClassMenu = vgui.Create("ClassChooseMenu")
    ClassMenu:SetClassList(ClassList)
    ClassMenu:SetNetworkString(NetworkString)
    ClassMenu:SetOnClickFunction(function()
        TitleMenu:Close()
    end)

    TitleMenu:SetContent(ClassMenu)
    ClassMenu:Dock(FILL)
end

vgui.Register("ClassChooseMenu", ClassChooseMenu, "DPanel")

net.Receive("SendZombieClasses", function()
    local ClassTable = net.ReadTable()

    ClassChooseMenu:CreateDFrameMenu("Choose Zombie Class", ClassTable, "SendZombieClass")
end)

net.Receive("SendHumanClasses", function()
    local ClassTable = net.ReadTable()

    ClassChooseMenu:CreateDFrameMenu("Choose Human Class", ClassTable, "SendHumanClass")
end)