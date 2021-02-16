ExtraItem.ID = "ZPEX41"
ExtraItem.Name = "ExtraItemEX41Name"
ExtraItem.Price = 30
function ExtraItem:OnBuy(ply)
	local Weap = ply:GetWeapon("m9k_ex41")
	if IsValid(Weap) then
		ply:GiveAmmo(3, Weap:GetPrimaryAmmoType(), true) 
	else
		ply:Give("m9k_ex41")
	end
end
function ExtraItem:ShouldBeEnabled()
	return WeaponManager:ServerHasWeapon("m9k_ex41")
end

WeaponManager:AddWeaponMultiplier("m9k_launched_ex41", 2)

Dictionary:RegisterPhrase("en-us", "ExtraItemEX41Name", "EX-41", false)
Dictionary:RegisterPhrase("pt-br", "ExtraItemEX41Name", "EX-41", false)
Dictionary:RegisterPhrase("es-ar", "ExtraItemEX41Name", "EX-41", false)
Dictionary:RegisterPhrase("russian", "ExtraItemEX41Name", "EX-41", false)
Dictionary:RegisterPhrase("ukrainian", "ExtraItemEX41Name", "EX-41", false)
Dictionary:RegisterPhrase("tchinese", "ExtraItemEX41Name", "EX-41", false)
Dictionary:RegisterPhrase("ja", "ExtraItemEX41Name", "EX-41", false)