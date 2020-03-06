ExtraItem.ID = "ZPM202"
ExtraItem.Name = "ExtraItemM202Name"
ExtraItem.Price = 40
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
Dictionary:RegisterPhrase("russian", "ExtraItemM202Name", "M202", false)
Dictionary:RegisterPhrase("ukrainian", "ExtraItemM202Name", "M202", false)
Dictionary:RegisterPhrase("tchinese", "ExtraItemM202Name", "M202", false)