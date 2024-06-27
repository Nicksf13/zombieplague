ExtraItem.ID = "ZPGrenade"
ExtraItem.Name = "ExtraItemGrenadeName"
ExtraItem.Description = "Some description"
ExtraItem.Category = EXTRA_ITEM_CATEGORY_WEAPON
ExtraItem.Price = 1
ExtraItem.WorldModel = "models/weapons/w_grenade.mdl"
function ExtraItem:OnBuy(ply)
	local Weap = ply:GetWeapon("weapon_frag")
	if IsValid(Weap) then
		ply:GiveAmmo(1, Weap:GetPrimaryAmmoType(), true) 
	else
		ply:Give("weapon_frag")
	end
end

WeaponManager:AddWeaponMultiplier("npc_grenade_frag", 5)