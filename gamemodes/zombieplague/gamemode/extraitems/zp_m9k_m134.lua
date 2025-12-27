ExtraItem.ID = "ZPM134"
ExtraItem.Name = "ExtraItemM134Name"
ExtraItem.Price = 100
function ExtraItem:OnBuy(ply)
	local Weap = ply:GetWeapon("m9k_minigun")
	if IsValid(Weap) then
		ply:GiveAmmo(300, Weap:GetPrimaryAmmoType(), true) 
	else
		ply:Give("m9k_minigun")
	end
end
function ExtraItem:ShouldBeEnabled()
	return WeaponManager:ServerHasWeapon("m9k_minigun")
end

WeaponManager:AddWeaponMultiplier("m9k_minigun", 0.5)