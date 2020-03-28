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

Dictionary:RegisterPhrase("en-us", "ExtraItemNerveGasName", "Nerve Gas", false)
Dictionary:RegisterPhrase("pt-br", "ExtraItemNerveGasName", "Nerve Gas", false)
Dictionary:RegisterPhrase("es-ar", "ExtraItemNerveGasName", "Nerve Gas", false)
Dictionary:RegisterPhrase("russian", "ExtraItemNerveGasName", "Nerve Gas", false)
Dictionary:RegisterPhrase("ukrainian", "ExtraItemNerveGasName", "Nerve Gas", false)
Dictionary:RegisterPhrase("tchinese", "ExtraItemNerveGasName", "Nerve Gas", false)