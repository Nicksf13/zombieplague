ExtraItemsManager = {ZombiesExtraItems = {}, HumansExtraItems = {}, PostRoundEvents = {}}
ITEM_HUMAN = 0
ITEM_ZOMBIE = 1
function ExtraItemsManager:Search()
	local Files = Utils:RecursiveFileSearch("zombieplague/gamemode/extraitems", ".lua")
	if Files then
		for k, File in pairs(Files) do
			ExtraItem = {}
			ExtraItem.Order = 100
			function ExtraItem:CanBuy(ply)
				return ply:Alive()
			end
			function ExtraItem:ShouldBeEnabled()
				return true
			end
			include(File)
			
			if ExtraItem:ShouldBeEnabled() then
				if !ExtraItem.ID || !ExtraItem.Name || !ExtraItem.Price || !ExtraItem.OnBuy then
					Utils:Print(WARNING_MESSAGE, "Invalid Extra Item: '" .. File .. "'")
				else
					self:AddExtraItem(ExtraItem, ExtraItem.Type)
				end
			end
		end
	end
end
function ExtraItemsManager:AddExtraItem(ExtraItem, Type)
	if Type == ITEM_ZOMBIE then
		table.insert(ExtraItemsManager.ZombiesExtraItems, ExtraItem)
	else
		table.insert(ExtraItemsManager.HumansExtraItems, ExtraItem)
	end

	if ExtraItem.BuySounds then
		for k, BuySound in pairs(ExtraItem.BuySounds) do
			resource.AddFile("sound/" .. BuySound)
		end
	end
end
function ExtraItemsManager:GetZombiesExtraItems()
	return ExtraItemsManager.ZombiesExtraItems
end
function ExtraItemsManager:GetHumansExtraItems()
	return ExtraItemsManager.HumansExtraItems
end
function ExtraItemsManager:GetAvailableExtraItems(ply)
	local ExtraItems = (ply:Team() == TEAM_HUMANS) and ExtraItemsManager.HumansExtraItems or ExtraItemsManager.ZombiesExtraItems
	local PrettyItems = {}
	for k, ExtraItem in pairs(ExtraItems) do
		if ExtraItem:CanBuy(ply) then
			PrettyItems[ExtraItem.ID] = {
				Description = Dictionary:GetPhrase(ExtraItem.Name, ply) .. " - " .. ExtraItem.Price,
				Order = ExtraItem.Order
			}
		end
	end
	return PrettyItems
end
function ExtraItemsManager:OpenExtraItemMenu(ply)
	net.Start("OpenBackMenu")
		net.WriteString("BuyExtraItem")
		net.WriteTable(ExtraItemsManager:GetAvailableExtraItems(ply))
		net.WriteBool(false)
	net.Send(ply)
end
function ExtraItemsManager:AddRemoveFunction(RemoveFunction)
	table.insert(ExtraItemsManager.PostRoundEvents, RemoveFunction)
end
function ExtraItemsManager:GetItemById(Team, ID)
	local ExtraItems = (Team == TEAM_HUMANS) and ExtraItemsManager.HumansExtraItems or ExtraItemsManager.ZombiesExtraItems
	for k, ExtraItem in pairs(ExtraItems) do
		if ExtraItem.ID == ID then
			return ExtraItem
		end
	end

	return nil
end
function ExtraItemsManager:BuyItem(ply, ExtraItem)
	if ExtraItem then
		if ExtraItem:CanBuy(ply) then
			if ply:GetAmmoPacks() >= ExtraItem.Price then
				ExtraItem:OnBuy(ply)
				if ExtraItem.RemoveFunction then
					table.insert(ExtraItemsManager.PostRoundEvents, ExtraItem.RemoveFunction)
				end
				if ExtraItem.BuySounds then
					SendSound(ply, ExtraItem.BuySounds[ math.random( #ExtraItem.BuySounds ) ])
				end
				ply:TakeAmmoPacks(ExtraItem.Price)
				SendPopupMessage(ply, string.format(Dictionary:GetPhrase("ExtraItemBought", ply), Dictionary:GetPhrase(ExtraItem.Name, ply)))
			else
				SendPopupMessage(ply, Dictionary:GetPhrase("ExtraItemEnought", ply))
			end
		else
			SendPopupMessage(ply, Dictionary:GetPhrase("ExtraItemCantBuy", ply))
		end
	else
		SendPopupMessage(ply, Dictionary:GetPhrase("ExtraItemChoose", ply))
	end
end
net.Receive("BuyExtraItem", function(len, ply)
	if !(ply:IsNemesis() || ply:IsSurvivor()) then
		ExtraItemsManager:BuyItem(ply, ExtraItemsManager:GetItemById(ply:Team(), net.ReadString()))
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