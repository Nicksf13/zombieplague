local DBindingPanel = {}
function DBindingPanel:CreateBindingPanel(Parent, GroupID)
    local Width, Height = Parent:GetSize()
    local HalfWidth = Width / 2

    local KeyBindingPanel = vgui.Create("DPanel")
    KeyBindingPanel:SetSize(Width, Height)
    KeyBindingPanel:SetPos(0, 0)

    local ButtonsPosition = Height - 60
    local DScrollPanel = vgui.Create("DScrollPanel", KeyBindingPanel)
    DScrollPanel:SetSize(Width, ButtonsPosition)

    local DListLayout = vgui.Create("DListLayout", DScrollPanel)
    DListLayout:SetSize(Width, ButtonsPosition)
    DListLayout.GroupID = GroupID
    
    DBindingPanel:InitList(DListLayout)

    local DButtonsBox = vgui.Create("DPanel", KeyBindingPanel)
    DButtonsBox:SetSize(Width, Height - ButtonsPosition)
    DButtonsBox:SetPos(0, ButtonsPosition)

    local DSaveButton = vgui.Create("DButton", DButtonsBox)
    DSaveButton:SetText(Dictionary:GetPhrase("KeyBindingApply"))
    DSaveButton:SetPos(15, 15)
    DSaveButton:SetSize(100, 30)

    local DCancelButton = vgui.Create("DButton", DButtonsBox)
    DCancelButton:SetText(Dictionary:GetPhrase("KeyBindingCancel"))
    DCancelButton:SetPos(125, 15)
    DCancelButton:SetSize(100, 30)

    local DDefaultButton = vgui.Create("DButton", DButtonsBox)
    DDefaultButton:SetText(Dictionary:GetPhrase("KeyBindingDefault"))
    DDefaultButton:SetPos(235, 15)
    DDefaultButton:SetSize(100, 30)

    DSaveButton.DoClick = function()
        KeyManager:SetKeyGroup(DListLayout.GroupID, DListLayout.CategoryKeyBindingList)
        KeyManager:Save()
    end
    DCancelButton.DoClick = function()
        DListLayout:Clear()

        DBindingPanel:InitList(DListLayout)
    end
    DDefaultButton.DoClick = function()
        DDefaultButton:SetDisabled(true)
        OptionMenu:CreateWarningPopup(
            Dictionary:GetPhrase("KeyBindingPopupTitle"),
            Dictionary:GetPhrase("KeyBindingPopupReset"),
            Dictionary:GetPhrase("PopupYes"),
            function()
                KeyManager:ResetGroup(GroupID)

                DListLayout:Clear()

                DBindingPanel:InitList(DListLayout)

                DDefaultButton:SetDisabled(false)
            end,
            Dictionary:GetPhrase("PopupNo"),
            function()
                DDefaultButton:SetDisabled(false)
            end
        )
        
    end

    return KeyBindingPanel
end
function DBindingPanel:InitList(DListLayout)
    local Width, Height = DListLayout:GetSize()
    DListLayout.CategoryKeyBindingList = table.Copy(KeyManager:GetKeysByGroupID(DListLayout.GroupID))
    for EventID, Event in pairs(KeyManager:GetEventGroup(DListLayout.GroupID)) do
        local CreatedLabelBindingButton = DBindingPanel:CreateKeyBindingLabeled(Width, EventID, Event.Name, DListLayout.CategoryKeyBindingList)

        DListLayout:Add(CreatedLabelBindingButton)
    end
end
function DBindingPanel:CreateKeyBindingLabeled(Width, EventID, EventName, CategoryKeyBindingList)
    local HalfWidth = Width / 2
    local DKeyLabeledPanel = vgui.Create("DPanel")
    DKeyLabeledPanel:SetSize(Width, 70)

    local DKeyBindingLabel = vgui.Create("DLabel", DKeyLabeledPanel)
    DKeyBindingLabel:SetText(Dictionary:GetPhrase(EventName))
    local TextWidth, TextHeight = DKeyBindingLabel:GetTextSize()
    DKeyBindingLabel:SetPos(HalfWidth - (TextWidth / 2), 0)
    DKeyBindingLabel:SetSize(TextWidth, 30)
    DKeyBindingLabel:SetTextColor(Color(0, 0, 0))

    local DKeyBindingButton = vgui.Create("DBinder", DKeyLabeledPanel)
    DKeyBindingButton:SetPos(HalfWidth / 2, 30)
    DKeyBindingButton:SetSize(HalfWidth, 30)
    function DKeyBindingButton:OnChange(Num)
        local HasBindedKey = false
        if Num != KEY_NONE then
            for EID, Key in pairs(CategoryKeyBindingList) do
                if Num == Key && EventID != EID then
                    HasBindedKey = true
                    break
                end
            end
        end
        
        if !HasBindedKey then
            CategoryKeyBindingList[EventID] = Num
        else
            DKeyBindingButton:SetValue(CategoryKeyBindingList[EventID] or KEY_NONE)
                
            notification.AddLegacy(Dictionary:GetPhrase("KeyBindingKeyAlreadyInUse"), NOTIFY_ERROR, 5)
        end
    end

    for EventKey, EventBind in pairs(CategoryKeyBindingList) do
        if EventKey == EventID then
            DKeyBindingButton:SetValue(EventBind)
            break
        end
    end

    return DKeyLabeledPanel
end

OptionMenu:AddItem("ZPKeyBinding", "ZombiePlagueActions", function(Parent)
    return DBindingPanel:CreateBindingPanel(Parent, "ZombiePlagueActions")
end)
OptionMenu:AddItem("ZPKeyBinding", "ZombiePlagueMenu", function(Parent)
    return DBindingPanel:CreateBindingPanel(Parent, "ZombiePlagueMenu")
end)