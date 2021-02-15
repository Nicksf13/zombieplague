ExtraItem.ID = "ZPM79GL"
ExtraItem.Name = "ExtraItemM79GLName"
ExtraItem.Price = 22
function ExtraItem:OnBuy(ply)
	local Weap = ply:GetWeapon("m9k_m79gl")
	if IsValid(Weap) then
		ply:GiveAmmo(3, Weap:GetPrimaryAmmoType(), true) 
	else
		ply:Give("m9k_m79gl")
	end
end
function ExtraItem:ShouldBeEnabled()
	return WeaponManager:ServerHasWeapon("m9k_m79gl")
end

WeaponManager:AddWeaponMultiplier("m9k_launched_m79", 2)

Dictionary:RegisterPhrase("en-us", "ExtraItemM79GLName", "M79 GL", false)
Dictionary:RegisterPhrase("pt-br", "ExtraItemM79GLName", "M79 GL", false)
Dictionary:RegisterPhrase("es-ar", "ExtraItemM79GLName", "M79 GL", false)
Dictionary:RegisterPhrase("russian", "ExtraItemM79GLName", "M79 GL", false)
Dictionary:RegisterPhrase("ukrainian", "ExtraItemM79GLName", "M79 GL", false)
Dictionary:RegisterPhrase("tchinese", "ExtraItemM79GLName", "M79 GL", false)
Dictionary:RegisterPhrase("ja", "ExtraItemM79GLName", "M79 GL", false)