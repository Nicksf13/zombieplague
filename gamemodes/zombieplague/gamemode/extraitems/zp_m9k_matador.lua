ExtraItem.ID = "ZPMatador"
ExtraItem.Name = "ExtraItemMatadorName"
ExtraItem.Price = 20
function ExtraItem:OnBuy(ply)
	local Weap = ply:GetWeapon("m9k_matador")
	if IsValid(Weap) then
		ply:GiveAmmo(3, Weap:GetPrimaryAmmoType(), true) 
	else
		ply:Give("m9k_matador")
	end
end
function ExtraItem:ShouldBeEnabled()
	return WeaponManager:ServerHasWeapon("m9k_matador")
end

WeaponManager:AddWeaponMultiplier("m9k_gdcwa_matador_90mm", 5)

Dictionary:RegisterPhrase("en-us", "ExtraItemMatadorName", "Matador", false)
Dictionary:RegisterPhrase("pt-br", "ExtraItemMatadorName", "Matador", false)
Dictionary:RegisterPhrase("es-ar", "ExtraItemMatadorName", "Matador", false)
Dictionary:RegisterPhrase("ru", "ExtraItemMatadorName", "Matador", false)
Dictionary:RegisterPhrase("uk", "ExtraItemMatadorName", "Matador", false)
Dictionary:RegisterPhrase("tchinese", "ExtraItemMatadorName", "Matador", false)
Dictionary:RegisterPhrase("ja", "ExtraItemMatadorName", "Matador", false)
Dictionary:RegisterPhrase("ko", "ExtraItemMatadorName", "Matador", false)