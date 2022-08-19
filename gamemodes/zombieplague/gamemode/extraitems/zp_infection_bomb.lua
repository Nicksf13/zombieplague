ExtraItem.ID = "ZPInfectionBomb"
ExtraItem.Name = "ExtraItemInfectionBombName"
ExtraItem.Price = 7
ExtraItem.Type = ITEM_ZOMBIE
ExtraItem.BuySounds = { "weapons/bugbait/bugbait_squeeze1.wav" }
function ExtraItem:OnBuy(ply)
	local Weap = ply:GetWeapon(INFECTION_BOMB)
	if IsValid(Weap) then
		ply:GiveAmmo(1, Weap:GetPrimaryAmmoType(), true) 
	else
		ply:GiveZombieAllowedWeapon(INFECTION_BOMB)
	end
end
function ExtraItem:CanBuy(ply)
	return ply:Alive()
end