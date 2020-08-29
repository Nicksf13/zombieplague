ExtraItem.ID = "ZPArmor"
ExtraItem.Name = "ExtraItemArmorName"
ExtraItem.Price = 12
function ExtraItem:OnBuy(ply)
	ply:SetArmor(ply:Armor() + 100)
end