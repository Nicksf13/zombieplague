ExtraItem.ID = "ZPRPG"
ExtraItem.Name = "ExtraItemRPGName"
ExtraItem.Price = 30
function ExtraItem:OnBuy(ply)
	local Weap = ply:GetWeapon("weapon_rpg")
	if IsValid(Weap) then
		ply:GiveAmmo(1, Weap:GetPrimaryAmmoType(), true) 
	else
		ply:Give("weapon_rpg")
	end
end

WeaponManager:AddWeaponMultiplier("weapon_rpg", 2)