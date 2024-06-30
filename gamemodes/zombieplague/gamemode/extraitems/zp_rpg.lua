ExtraItem.ID = "ZPRPG"
ExtraItem.Name = "ExtraItemRPGName"
ExtraItem.Category = EXTRA_ITEM_CATEGORY_WEAPON
ExtraItem.WorldModel = "models/weapons/w_rocket_launcher.mdl"
ExtraItem.Price = 15
function ExtraItem:OnBuy(ply)
	local Weap = ply:GetWeapon("weapon_rpg")
	if IsValid(Weap) then
		ply:GiveAmmo(3, Weap:GetPrimaryAmmoType(), true) 
	else
		ply:Give("weapon_rpg")
	end
end
WeaponManager:AddWeaponMultiplier("rpg_missile", 4)