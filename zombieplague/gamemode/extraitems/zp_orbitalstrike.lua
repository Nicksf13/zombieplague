ExtraItem.Name = "Orbital Strike Marker"
ExtraItem.Price = 100
function ExtraItem:OnBuy(ply)
	local Weap = ply:GetWeapon("m9k_orbital_strike")
	if IsValid(Weap) then
		ply:GiveAmmo(1, Weap:GetPrimaryAmmoType(), true) 
	else
		ply:Give("m9k_orbital_strike")
	end
end