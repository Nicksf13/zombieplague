ExtraItem.ID = "ZPInfectionBomb"
ExtraItem.Name = "ExtraItemInfectionBombName"
ExtraItem.Price = 10
ExtraItem.Type = ITEM_ZOMBIE
function ExtraItem:OnBuy(ply)
	local Weap = ply:GetWeapon(INFECTION_BOMB)
	if IsValid(Weap) then
		ply:GiveAmmo(1, Weap:GetPrimaryAmmoType(), true) 
	else
		ply:GiveZombieAllowedWeapon(INFECTION_BOMB)
	end
end
function ExtraItem:CanBuy(ply)
	return !RoundManager:IsSpecialRound() && ply:Alive()
end