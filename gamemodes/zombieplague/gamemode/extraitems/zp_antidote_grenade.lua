ExtraItem.ID = "ZPAntidoteGrenade"
ExtraItem.Name = "ExtraItemAntidoteGrenade"
ExtraItem.Price = 20
ExtraItem.BuySounds = { "items/medshot4.wav" }
function ExtraItem:OnBuy(ply)
    local Weap = ply:GetWeapon(ANTIDOTE_GRENADE)
	if IsValid(Weap) then
		ply:GiveAmmo(1, Weap:GetPrimaryAmmoType(), true) 
	else
		ply:GiveZombieAllowedWeapon(ANTIDOTE_GRENADE)
	end
end
function ExtraItem:CanBuy(ply)
    return !RoundManager:IsSpecialRound() && !RoundManager:LastZombie() && ply:Alive()
end