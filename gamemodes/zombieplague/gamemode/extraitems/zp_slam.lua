ExtraItem.Name = "ExtraItemSlamName"
ExtraItem.Price = 10
function ExtraItem:OnBuy(ply)
	local Weap = ply:GetWeapon("weapon_slam")
	if IsValid(Weap) then
		ply:GiveAmmo(1, Weap:GetPrimaryAmmoType(), true) 
	else
		ply:Give("weapon_slam")
	end
end

WeaponManager:AddWeaponMultiplier("weapon_slam", 4)