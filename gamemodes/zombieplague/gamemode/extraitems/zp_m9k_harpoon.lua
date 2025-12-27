ExtraItem.ID = "ZPHarpoon"
ExtraItem.Name = "ExtraItemHarpoonName"
ExtraItem.Price = 15
function ExtraItem:OnBuy(ply)
	local Weap = ply:GetWeapon("m9k_harpoon")
	if IsValid(Weap) then
		ply:GiveAmmo(3, Weap:GetPrimaryAmmoType(), true) 
	else
		ply:Give("m9k_harpoon")
	end
end
function ExtraItem:ShouldBeEnabled()
	return WeaponManager:ServerHasWeapon("m9k_harpoon")
end

WeaponManager:AddWeaponMultiplier("m9k_thrown_harpoon", 3.4)