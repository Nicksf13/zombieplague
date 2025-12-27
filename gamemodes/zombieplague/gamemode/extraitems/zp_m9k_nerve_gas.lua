ExtraItem.ID = "ZPNerveGas"
ExtraItem.Name = "ExtraItemNerveGasName"
ExtraItem.Price = 20
ExtraItem.Type = ITEM_ZOMBIE
function ExtraItem:OnBuy(ply)
	local Weap = ply:GetWeapon("m9k_nerve_gas")
	if IsValid(Weap) then
		ply:GiveAmmo(1, Weap:GetPrimaryAmmoType(), true) 
	else
		ply:GiveZombieAllowedWeapon("m9k_nerve_gas")
	end
end
function ExtraItem:ShouldBeEnabled()
	return WeaponManager:ServerHasWeapon("m9k_nerve_gas")
end