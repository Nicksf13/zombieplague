ExtraItem.ID = "ZPExtraAmmo"
ExtraItem.Name = "ExtraItemExtraAmmoName"
ExtraItem.Price = 3
ExtraItem.BuySounds = { 'items/ammo_pickup.wav' }
function ExtraItem:OnBuy(ply)
	for k, Weap in pairs(ply:GetWeapons()) do
		if WeaponManager:IsChoosableWeapon(Weap:GetClass()) then
			if Weap:GetMaxClip1() then
				ply:GiveAmmo(Weap:GetMaxClip1() * 15, Weap:GetPrimaryAmmoType(), true) 
			else
				ply:GiveAmmo(Weap:GetMaxClip2() * 15, Weap:GetSecondaryAmmoType(), true) 
			end
		end
	end
end
function ExtraItem:CanBuy(ply)
	return ply:Alive() && cvars.Number("zp_clip_mode", 0) == WMODE_NONE
end