ExtraItem.ID = "ZPInfectionBomb"
ExtraItem.Name = "ExtraItemInfectionBombName"
ExtraItem.Price = 7
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
	local InfectionBomb = ply:GetWeapon(INFECTION_BOMB)
	
	return RoundManager:IsPlayingRound() && !RoundManager:IsSpecialRound() && ply:Alive() && (!IsValid(InfectionBomb) || (IsValid(InfectionBomb) && InfectionBomb:Clip1() < 1))
end