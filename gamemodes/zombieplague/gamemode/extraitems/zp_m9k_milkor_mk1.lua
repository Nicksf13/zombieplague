ExtraItem.ID = "ZPMilkorMK1"
ExtraItem.Name = "ExtraItemMilkorMK1Name"
ExtraItem.Price = 35
function ExtraItem:OnBuy(ply)
	local Weap = ply:GetWeapon("m9k_milkormgl")
	if IsValid(Weap) then
		ply:GiveAmmo(6, Weap:GetPrimaryAmmoType(), true) 
	else
		ply:Give("m9k_milkormgl")
	end
end
function ExtraItem:ShouldBeEnabled()
	return WeaponManager:ServerHasWeapon("m9k_milkormgl")
end

WeaponManager:AddWeaponMultiplier("m9k_m202_rocket", 4)

Dictionary:RegisterPhrase("en-us", "ExtraItemMilkorMK1Name", "Milkor MK1", false)
Dictionary:RegisterPhrase("pt-br", "ExtraItemMilkorMK1Name", "Milkor MK1", false)
Dictionary:RegisterPhrase("es-ar", "ExtraItemMilkorMK1Name", "Milkor MK1", false)
Dictionary:RegisterPhrase("russian", "ExtraItemMilkorMK1Name", "Milkor MK1", false)
Dictionary:RegisterPhrase("ukrainian", "ExtraItemMilkorMK1Name", "Milkor MK1", false)
Dictionary:RegisterPhrase("tchinese", "ExtraItemMilkorMK1Name", "Milkor MK1", false)