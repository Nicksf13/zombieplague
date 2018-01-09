ExtraItem.Name = "Milkor Mk1"
ExtraItem.Price = 50
function ExtraItem:OnBuy(ply)
	local Weap = ply:GetWeapon("m9k_milkormgl")
	if IsValid(Weap) then
		ply:GiveAmmo(12, Weap:GetPrimaryAmmoType(), true) 
	else
		ply:Give("m9k_milkormgl")
	end
end