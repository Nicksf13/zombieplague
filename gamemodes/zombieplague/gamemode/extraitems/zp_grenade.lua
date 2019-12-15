ExtraItem.ID = "ZPGrenade"
ExtraItem.Name = "ExtraItemGrenadeName"
ExtraItem.Price = 5
function ExtraItem:OnBuy(ply)
	local Weap = ply:GetWeapon("weapon_frag")
	if IsValid(Weap) then
		ply:GiveAmmo(1, Weap:GetPrimaryAmmoType(), true) 
	else
		ply:Give("weapon_frag")
	end
end

WeaponManager:AddWeaponMultiplier("weapon_frag", 5)