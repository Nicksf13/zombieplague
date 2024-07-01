ExtraItem.ID = "ZPArmor"
ExtraItem.Name = "ExtraItemArmorName"
ExtraItem.Category = EXTRA_ITEM_CATEGORY_UTILITY
ExtraItem.Price = 12
ExtraItem.WorldModel = "models/Items/battery.mdl"
function ExtraItem:OnBuy(ply)
	ply:SetArmor(ply:Armor() + 100)
end