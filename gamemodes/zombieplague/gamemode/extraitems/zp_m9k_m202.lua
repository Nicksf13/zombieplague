ExtraItem.ID = "ZPM202"
ExtraItem.Name = "ExtraItemM202Name"
ExtraItem.Category = EXTRA_ITEM_CATEGORY_WEAPON
ExtraItem.Price = 40
ExtraItem.WorldModel = "models/weapons/w_rocket_launcher.mdl"
function ExtraItem:OnBuy(ply)
	local Weap = ply:GetWeapon("m9k_m202")
	if IsValid(Weap) then
		ply:GiveAmmo(4, Weap:GetPrimaryAmmoType(), true) 
	else
		ply:Give("m9k_m202")
	end
end
function ExtraItem:ShouldBeEnabled()
	return WeaponManager:ServerHasWeapon("m9k_m202")
end

WeaponManager:AddWeaponMultiplier("m9k_m202_rocket", 2)

Dictionary:RegisterPhrase("en-us", "ExtraItemM202Name", "M202", false)
Dictionary:RegisterPhrase("pt-br", "ExtraItemM202Name", "M202", false)
Dictionary:RegisterPhrase("es-ar", "ExtraItemM202Name", "M202", false)
Dictionary:RegisterPhrase("ru", "ExtraItemM202Name", "M202", false)
Dictionary:RegisterPhrase("uk", "ExtraItemM202Name", "M202", false)
Dictionary:RegisterPhrase("tchinese", "ExtraItemM202Name", "M202", false)
Dictionary:RegisterPhrase("ja", "ExtraItemM202Name", "M202", false)
Dictionary:RegisterPhrase("ko", "ExtraItemM202Name", "M202", false)