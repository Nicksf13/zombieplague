ExtraItem.Name = "ExtraItemArmorName"
ExtraItem.Price = 10
function ExtraItem:OnBuy(ply)
	ply:SetArmor(ply:Armor() + 100)
end