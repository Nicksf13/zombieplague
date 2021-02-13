ExtraItem.ID = "ZPHarpoon"
ExtraItem.Name = "ExtraItemHarpoonName"
ExtraItem.Price = 15
function ExtraItem:OnBuy(ply)
	local Weap = ply:GetWeapon("m9k_harpoon")
	if IsValid(Weap) then
		ply:GiveAmmo(3, Weap:GetPrimaryAmmoType(), true) 
	else
		ply:Give("m9k_harpoon")
	end
end
function ExtraItem:ShouldBeEnabled()
	return WeaponManager:ServerHasWeapon("m9k_harpoon")
end

WeaponManager:AddWeaponMultiplier("m9k_thrown_harpoon", 3.4)

Dictionary:RegisterPhrase("en-us", "ExtraItemHarpoonName", "Harpoon", false)
Dictionary:RegisterPhrase("pt-br", "ExtraItemHarpoonName", "Arpão", false)
Dictionary:RegisterPhrase("es-ar", "ExtraItemHarpoonName", "Arpón", false)
Dictionary:RegisterPhrase("russian", "ExtraItemHarpoonName", "Гарпун", false)
Dictionary:RegisterPhrase("ukrainian", "ExtraItemHarpoonName", "Гарпун", false)
Dictionary:RegisterPhrase("tchinese", "ExtraItemHarpoonName", "魚叉", false)
Dictionary:RegisterPhrase("ja", "ExtraItemHarpoonName", "もり", false)