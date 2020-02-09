KeyManager = {Keys = {}, EventGroups = {}, TemporaryKeys = {}, SaveFileName = "zombieplague/keybinding.json", LastPress = 0, PressingKeyList = {}}

function KeyManager:SetKeyGroup(GroupID, KeyGroup)
    self.Keys[GroupID] = KeyGroup
end
--function KeyManager:SaveBindKey()
--    for GroupID, Group in pairs(self.TemporaryKeys) do
--        for Key, Event in pairs(Group) do
--            self.Keys[GroupID][Key]
--        end
--    end
--end
function KeyManager:GetEvent(EventID)
    for GroupID, EventGroup in pairs(self.EventGroups) do
        if EventGroup[EventID] then
            return EventGroup[EventID]
        end
    end

    return nil
end
function KeyManager:AddEvent(EventGroup, EventID, EventName, EventAction, DefaultKey)
    local Event = self:GetEvent(EventID)

    if !Event then
        if !self.EventGroups[EventGroup] then
            self.EventGroups[EventGroup] = {}
        end
        self.EventGroups[EventGroup][EventID] = {
            Name = EventName,
            Action = EventAction,
            DefaultKey = DefaultKey
        }
    else
        print("Could not add event: '" .. EventID .. "', duplicated ID!")
    end
end
function KeyManager:GetEventGroup(GroupID)
    return self.EventGroups[GroupID]
end
function KeyManager:GetEventGroups()
    return self.EventGroups
end
function KeyManager:GetKeys()
    return self.Keys
end
function KeyManager:GetKeysByGroupID(GroupID)
    return self.Keys[GroupID]
end
function KeyManager:Save()
    file.Write(self.SaveFileName, util.TableToJSON(self.Keys, true))
end
function KeyManager:Load()
    if file.Exists(self.SaveFileName, "DATA") then
		self.Keys = util.JSONToTable(file.Read(self.SaveFileName, "DATA"))
	else
		self.Keys = self:LoadDefault()
		self:Save()
	end
end
function KeyManager:ResetGroup(GroupID)
    self.Keys[GroupID] = {}
    for EventID, Event in pairs(self.EventGroups[GroupID]) do
        self.Keys[GroupID][EventID] = Event.DefaultKey
    end
    
    self:Save()
end
function KeyManager:LoadDefault()
    local Keys = {}
    for GroupID, Group in pairs(self.EventGroups) do
        Keys[GroupID] = {}
        for EventID, Event in pairs(Group) do
            Keys[GroupID][EventID] = Event.DefaultKey
        end
    end

    return Keys
end

hook.Add("Think", "KeyManagerHook", function()
    if !LocalPlayer():IsTyping() then
        if CurTime() >= KeyManager.LastPress then
            for GroupID, Group in pairs(KeyManager.Keys) do
                for EventID, Key in pairs(Group) do
                    if input.IsKeyDown(Key) then
                        if !KeyManager.PressingKeyList[Key] then
                            KeyManager.LastPress = CurTime() + 0.2
                            KeyManager.PressingKeyList[Key] = true

                            KeyManager:GetEvent(EventID):Action()
                        end
                    else
                        KeyManager.PressingKeyList[Key] = nil
                    end
                end
            end
        end
    end
end)

KeyManager:AddEvent("ZombiePlagueActions", "NightVisionToggle", "KeyBindingNightVisionToggle", function()
    net.Start("RequestNightvision")
    net.SendToServer()
end, KEY_F3)
KeyManager:AddEvent("ZombiePlagueActions", "RequestAbility", "KeyBindingRequestAbility", function()
    net.Start("RequestAbility")
    net.SendToServer()
end, KEY_T)
KeyManager:AddEvent("ZombiePlagueMenu", "ZPMenu", "KeyBindingOpenZPMenu", function()
    OpenZPMenu()
end, KEY_F4)
KeyManager:AddEvent("ZombiePlagueMenu", "OpenHumanClass", "KeyBindingOpenHumanMenu", function()
    net.Start("RequestHumanMenu")
    net.SendToServer()
end, KEY_NONE)
KeyManager:AddEvent("ZombiePlagueMenu", "OpenZombieClass", "KeyBindingOpenZombieMenu", function()
    net.Start("RequestZombieMenu")
    net.SendToServer()
end, KEY_NONE)
KeyManager:AddEvent("ZombiePlagueMenu", "OpenWeaponsMenu", "KeyBindingOpenWeaponsMenu", function()
    net.Start("RequestWeaponMenu")
    net.SendToServer()
end, KEY_NONE)
KeyManager:AddEvent("ZombiePlagueMenu", "OpenExtraItemsMenu", "KeyBindingOpenExtreItemsMenu", function()
    net.Start("RequestExtraItemMenu")
    net.SendToServer()
end, KEY_NONE)

KeyManager:Load()