ExtraItem.ID = "ZPRPG7"
ExtraItem.Name = "ExtraItemRPG7Name"
ExtraItem.Price = 20
function ExtraItem:OnBuy(ply)
	local Weap = ply:GetWeapon("m9k_rpg7")
	if IsValid(Weap) then
		ply:GiveAmmo(3, Weap:GetPrimaryAmmoType(), true) 
	else
		ply:Give("m9k_rpg7")
	end
end
function ExtraItem:ShouldBeEnabled()
	return WeaponManager:ServerHasWeapon("m9k_rpg7")
end

WeaponManager:AddWeaponMultiplier("m9k_gdcwa_rpg_heat", 5)