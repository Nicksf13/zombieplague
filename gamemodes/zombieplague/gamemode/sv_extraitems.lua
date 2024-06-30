ExtraItemsManager = {ZombiesExtraItems = {}, HumansExtraItems = {}, PostRoundEvents = {}}
ITEM_HUMAN = 0
ITEM_ZOMBIE = 1

EXTRA_ITEM_CATEGORY_BUFF = "ExtraItemCategoryBuff"
EXTRA_ITEM_CATEGORY_WEAPON = "ExtraItemCategoryWeapon"
EXTRA_ITEM_CATEGORY_UTILITY = "ExtraItemCategoryUtility"
function ExtraItemsManager:Search()
	local Files = Utils:RecursiveFileSearch("zombieplague/gamemode/extraitems", ".lua")
	if Files then
		for k, File in pairs(Files) do
			ExtraItem = {}
			ExtraItem.Order = 100
			ExtraItem.WorldModel = "models/weapons/w_medkit.mdl"
			function ExtraItem:CanBuy(ply)
				return ply:Alive()
			end
			function ExtraItem:ShouldBeEnabled()
				return true
			end
			include(File)
			
			if ExtraItemsManager:ValidateExtraItem(ExtraItem, File) && ExtraItem:ShouldBeEnabled() then
				self:AddExtraItem(ExtraItem, ExtraItem.Type)
			end
		end
	end
end
function ExtraItemsManager:ValidateExtraItem(ExtraItem, File)
	if !ExtraItem.ID then
		Utils:Print(WARNING_MESSAGE, "No 'ID' was found for file: '" .. File .. "'")

		return false
	end
	if !ExtraItem.Name then
		Utils:Print(WARNING_MESSAGE, "No 'Name' was found for file: '" .. File .. "'")

		return false
	end
	if !ExtraItem.Category then
		Utils:Print(WARNING_MESSAGE, "No 'Category' was found for file: '" .. File .. "'")

		return false
	end
	if !ExtraItem.Price then
		Utils:Print(WARNING_MESSAGE, "No 'Price' was found for file: '" .. File .. "'")

		return false
	end
	if !ExtraItem.OnBuy then
		Utils:Print(WARNING_MESSAGE, "No 'OnBuy' was found for file: '" .. File .. "'")

		return false
	end

	return true
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
				Name = Dictionary:GetPhrase(ExtraItem.Name, ply) .. " - " .. ExtraItem.Price,
				Description = ExtraItem.Description and Dictionary:GetPhrase(ExtraItem.Description, ply) or nil,
				Category = Dictionary:GetPhrase(ExtraItem.Category, ply),
				WorldModel = ExtraItem.WorldModel,
				Price = ExtraItem.Price,
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
					SendSound(ply, SafeTableRandom(ExtraItem.BuySounds))
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