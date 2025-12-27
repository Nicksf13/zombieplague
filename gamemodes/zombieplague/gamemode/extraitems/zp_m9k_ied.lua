ExtraItem.ID = "ZPIED"
ExtraItem.Name = "ExtraItemIEDName"
ExtraItem.Price = 20
function ExtraItem:OnBuy(ply)
	local Weap = ply:GetWeapon("m9k_ied_detonator")
	if IsValid(Weap) then
		ply:GiveAmmo(3, Weap:GetPrimaryAmmoType(), true) 
	else
		ply:Give("m9k_ied_detonator")
	end
end
function ExtraItem:ShouldBeEnabled()
	return WeaponManager:ServerHasWeapon("m9k_ied_detonator")
end

WeaponManager:AddWeaponMultiplier("m9k_improvised_explosive", 8)