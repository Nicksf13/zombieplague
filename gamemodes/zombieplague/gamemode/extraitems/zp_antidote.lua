ExtraItem.ID = "ZPAntidote"
ExtraItem.Name = "ExtraItemAntidoteName"
ExtraItem.Category = EXTRA_ITEM_CATEGORY_UTILITY
ExtraItem.Price = 20
ExtraItem.Type = ITEM_ZOMBIE
function ExtraItem:OnBuy(ply)
	InfectionManager:Cure(ply, ply)
end
function ExtraItem:CanBuy(ply)
	return !RoundManager:IsSpecialRound() && !RoundManager:LastZombie() && ply:Alive()
end