ExtraItemsManager = {ZombieExtraItems = {}, HumansExtraItems = {}, PostRoundEvents = {}}

function ExtraItemsManager:Search()
	local Files = file.Find("zombieplague/gamemode/extraitems/*.lua", "LUA")
	if Files != nil then
		for k, File in pairs(Files) do
			include("zombieplague/gamemode/extraitems/" .. File)
		end
	end
	
end
function ExtraItemsManager:AddZombieExtraItem(ExtraItem)
	if ExtraItemsManager:ValidateItem(ExtraItem) then
		if ExtraItem.CanBuy == nil then
			function ExtraItem:CanBuy(ply)
				return ply:Alive()
			end
		end
		table.insert(ExtraItemsManager.ZombieExtraItems, ExtraItem)
	end
end
function ExtraItemsManager:AddHumanExtraItem(ExtraItem)
	if ExtraItemsManager:ValidateItem(ExtraItem) then
		if ExtraItem.CanBuy == nil then
			function ExtraItem:CanBuy(ply)
				return ply:Alive()
			end
		end
		table.insert(ExtraItemsManager.HumansExtraItems, ExtraItem)
	end
end
function ExtraItemsManager:ValidateItem(ExtraItem)
	return ExtraItem.Name != nil && ExtraItem.Price != nil && ExtraItem.OnBuy != nil
end
function ExtraItemsManager:GetZombiesExtraItems()
	return ExtraItemsManager.ZombieExtraItems
end
function ExtraItemsManager:GetHumansExtraItems()
	return ExtraItemsManager.HumansExtraItems
end
function ExtraItemsManager:GetPrettyZombiesExtraItems()
	local PrettyItems = {}
	for k, Weap in pairs(ExtraItemsManager.ZombieExtraItems) do
		table.insert(PrettyItems, Weap.Name .. " - " .. Weap.Price)
	end
	return PrettyItems
end
function ExtraItemsManager:GetPrettyHumansExtraItems()
	local PrettyItems = {}
	for k, Weap in pairs(ExtraItemsManager.HumansExtraItems) do
		table.insert(PrettyItems, Weap.Name  .. " - " .. Weap.Price)
	end
	return PrettyItems
end
function ExtraItemsManager:OpenExtraItemMenu(ply)
	net.Start("OpenBackMenu")
		net.WriteString("BuyExtraItem")
		if ply:Team() == TEAM_ZOMBIES then
			net.WriteTable(ExtraItemsManager:GetPrettyZombiesExtraItems())
		else
			net.WriteTable(ExtraItemsManager:GetPrettyHumansExtraItems())
		end
	net.Send(ply)
end
function ExtraItemsManager:AddRemoveFunction(RemoveFunction)
	table.insert(ExtraItemsManager.PostRoundEvents, RemoveFunction)
end
function ExtraItemsManager:BuyItem(ply, ExtraItem)
	if ExtraItem != nil then
		if ply:GetAmmoPacks() >= ExtraItem.Price then
			if ExtraItem:CanBuy(ply) then
				ExtraItem:OnBuy(ply)
				if ExtraItem.RemoveFunction != nil then
					table.insert(ExtraItemsManager.PostRoundEvents, ExtraItem.RemoveFunction)
				end
				ply:TakeAmmoPacks(ExtraItem.Price)
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
	if ply:Team() == TEAM_ZOMBIES then
		ExtraItemsManager:BuyItem(ply, ExtraItemsManager:GetZombiesExtraItems()[net.ReadInt(16)])
	elseif ply:Team() == TEAM_HUMANS then
		ExtraItemsManager:BuyItem(ply, ExtraItemsManager:GetHumansExtraItems()[net.ReadInt(16)])
	end
end)
hook.Add("ZPRoundEnd", "ZPExtraItemsRemove", function()
	while(table.Count(ExtraItemsManager.PostRoundEvents) > 0) do
		table.Remove(ExtraItemsManager.PostRoundEvents)()
	end
end)
hook.Add("PlayerSay", "ZPOpenExtraMenu", function(ply, txt)
	if txt == "/extraitem" then
		ExtraItemsManager:OpenExtraItemMenu(ply)
	end
end)
net.Receive("RequestExtraItemMenu", function(len, ply)
	ExtraItemsManager:OpenExtraItemMenu(ply)
end)

util.AddNetworkString("BuyExtraItem")
util.AddNetworkString("OpenExtraItemMenu")
util.AddNetworkString("RequestExtraItemMenu")