ExtraItem.ID = "ZPZombieMadness"
ExtraItem.Name = "ExtraItemZombieMadnessName"
ExtraItem.Price = 15
ExtraItem.Type = ITEM_ZOMBIE
function ExtraItem:OnBuy(ply)
	ply:ZombieMadness(5)
end
function ExtraItem:CanBuy(ply)
	return !RoundManager:IsSpecialRound() && ply:Alive()
end