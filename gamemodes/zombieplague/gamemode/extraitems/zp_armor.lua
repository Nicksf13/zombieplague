ExtraItem.ID = "ZPArmor"
ExtraItem.Name = "ExtraItemArmorName"
ExtraItem.Price = 15
function ExtraItem:OnBuy(ply)
	ply:SetArmor(ply:Armor() + 100)
end