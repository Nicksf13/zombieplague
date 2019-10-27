ExtraItem.Name = "ExtraItemAntidoteName"
ExtraItem.Price = 40
ExtraItem.Type = ITEM_ZOMBIE
function ExtraItem:OnBuy(ply)
	InfectionManager:Cure(ply, ply)
end
function ExtraItem:CanBuy(ply)
	return !RoundManager:IsSpecialRound() && !RoundManager:LastZombie() && ply:Alive()
end