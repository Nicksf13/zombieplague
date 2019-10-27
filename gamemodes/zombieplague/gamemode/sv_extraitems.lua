ExtraItemsManager = {ZombiesExtraItems = {}, HumansExtraItems = {}, PostRoundEvents = {}}
ITEM_HUMAN = 0
ITEM_ZOMBIE = 1
function ExtraItemsManager:Search()
	local Files = file.Find("zombieplague/gamemode/extraitems/*.lua", "LUA")
	if Files != nil then
		for k, File in pairs(Files) do
			ExtraItem = {}
			function ExtraItem:CanBuy(ply)
				return ply:Alive()
			end
			function ExtraItem:ShouldBeEnabled()
				return true
			end
			include("zombieplague/gamemode/extraitems/" .. File)
			
			if ExtraItem:ShouldBeEnabled() then
				if !ExtraItem.Name || !ExtraItem.Price || !ExtraItem.OnBuy then
					print("Invalid Extra Item: '" .. File .. "'")
				elseif ExtraItem.Type == ITEM_ZOMBIE then
					self:AddZombieExtraItem(ExtraItem)
				else
					self:AddHumanExtraItem(ExtraItem)
				end
			end
		end
	end
end
function ExtraItemsManager:AddZombieExtraItem(ExtraItem)
	table.insert(ExtraItemsManager.ZombiesExtraItems, ExtraItem)
end
function ExtraItemsManager:AddHumanExtraItem(ExtraItem)
	table.insert(ExtraItemsManager.HumansExtraItems, ExtraItem)
end
function ExtraItemsManager:GetZombiesExtraItems()
	return ExtraItemsManager.ZombiesExtraItems
end
function ExtraItemsManager:GetHumansExtraItems()
	return ExtraItemsManager.HumansExtraItems
end
function ExtraItemsManager:GetPrettyZombiesExtraItems(ply)
	local PrettyItems = {}
	for k, ExtraItem in pairs(ExtraItemsManager.ZombiesExtraItems) do
		table.insert(PrettyItems, Dictionary:GetPhrase(ExtraItem.Name, ply) .. " - " .. ExtraItem.Price)
	end
	return PrettyItems
end
function ExtraItemsManager:GetPrettyHumansExtraItems(ply)
	local PrettyItems = {}
	for k, ExtraItem in pairs(ExtraItemsManager.HumansExtraItems) do
		table.insert(PrettyItems, Dictionary:GetPhrase(ExtraItem.Name, ply) .. " - " .. ExtraItem.Price)
	end
	return PrettyItems
end
function ExtraItemsManager:OpenExtraItemMenu(ply)
	net.Start("OpenBackMenu")
		net.WriteString("BuyExtraItem")
		net.WriteTable(ply:Team() == TEAM_ZOMBIES and ExtraItemsManager:GetPrettyZombiesExtraItems(ply) or ExtraItemsManager:GetPrettyHumansExtraItems(ply))
	net.Send(ply)
end
function ExtraItemsManager:AddRemoveFunction(RemoveFunction)
	table.insert(ExtraItemsManager.PostRoundEvents, RemoveFunction)
end
function ExtraItemsManager:BuyItem(ply, ExtraItem)
	if ExtraItem then
		if ply:GetAmmoPacks() >= ExtraItem.Price then
			if ExtraItem:CanBuy(ply) then
				ExtraItem:OnBuy(ply)
				if ExtraItem.RemoveFunction then
					table.insert(ExtraItemsManager.PostRoundEvents, ExtraItem.RemoveFunction)
				end
				ply:TakeAmmoPacks(ExtraItem.Price)
				SendPopupMessage(ply, string.format(Dictionary:GetPhrase("ExtraItemBought", ply), ExtraItem.Name))
			else
				SendPopupMessage(ply, Dictionary:GetPhrase("ExtraItemCantBuy", ply))
			end
		else
			SendPopupMessage(ply, Dictionary:GetPhrase("ExtraItemEnought", ply))
		end
	else
		SendPopupMessage(ply, Dictionary:GetPhrase("ExtraItemChoose", ply))
	end
end
net.Receive("BuyExtraItem", function(len, ply)
	if !(ply:IsNemesis() || ply:IsSurvivor()) then
		ExtraItemsManager:BuyItem(ply, (ply:Team() == TEAM_ZOMBIES and ExtraItemsManager:GetZombiesExtraItems() or ExtraItemsManager:GetHumansExtraItems())[net.ReadInt(16)])
	end
end)
hook.Add("ZPRoundEnd", "ZPExtraItemsRemove", function()
	while(table.Count(ExtraItemsManager.PostRoundEvents) > 0) do
		table.Remove(ExtraItemsManager.PostRoundEvents)()
	end
end)
Commands:AddCommand("extraitem", "Open extra item menu.", function(ply, args)
	if !(ply:IsNemesis() || ply:IsSurvivor()) then
		ExtraItemsManager:OpenExtraItemMenu(ply)
	else
		SendPopupMessage(ply, Dictionary:GetPhrase("ExtraItemCantOpen", ply))
	end
end)
net.Receive("RequestExtraItemMenu", function(len, ply)
	if !(ply:IsNemesis() || ply:IsSurvivor()) then
		ExtraItemsManager:OpenExtraItemMenu(ply)
	else
		SendPopupMessage(ply, Dictionary:GetPhrase("ExtraItemCantOpen", ply))
	end
end)

util.AddNetworkString("BuyExtraItem")
util.AddNetworkString("OpenExtraItemMenu")
util.AddNetworkString("RequestExtraItemMenu")