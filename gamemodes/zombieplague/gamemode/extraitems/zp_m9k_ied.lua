ExtraItem.ID = "ZPIED"
ExtraItem.Name = "ExtraItemIEDName"
ExtraItem.Category = EXTRA_ITEM_CATEGORY_WEAPON
ExtraItem.Price = 20
ExtraItem.WorldModele = "models/weapons/w_sb.mdl"
function ExtraItem:OnBuy(ply)
	local Weap = ply:GetWeapon("m9k_ied_detonator")
	if IsValid(Weap) then
		ply:GiveAmmo(3, Weap:GetPrimaryAmmoType(), true) 
	else
		ply:Give("m9k_ied_detonator")
	end
end
function ExtraItem:ShouldBeEnabled()
	return WeaponManager:ServerHasWeapon("m9k_ied_detonator")
end

WeaponManager:AddWeaponMultiplier("m9k_improvised_explosive", 8)

Dictionary:RegisterPhrase("en-us", "ExtraItemIEDName", "IED", false)
Dictionary:RegisterPhrase("pt-br", "ExtraItemIEDName", "IED", false)
Dictionary:RegisterPhrase("es-ar", "ExtraItemIEDName", "IED", false)
Dictionary:RegisterPhrase("ru", "ExtraItemIEDName", "IED", false)
Dictionary:RegisterPhrase("uk", "ExtraItemIEDName", "IED", false)
Dictionary:RegisterPhrase("tchinese", "ExtraItemIEDName", "IED", false)
Dictionary:RegisterPhrase("ja", "ExtraItemIEDName", "IED", false)
Dictionary:RegisterPhrase("ko", "ExtraItemIEDName", "IED", false)