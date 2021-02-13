ExtraItem.ID = "ZPZombieMadness"
ExtraItem.Name = "ExtraItemZombieMadnessName"
ExtraItem.Price = 10
ExtraItem.Type = ITEM_ZOMBIE
function ExtraItem:OnBuy(ply)
	ply:ZombieMadness(5)
end
function ExtraItem:CanBuy(ply)
	return ply:Alive()
end