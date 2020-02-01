ExtraItem.ID = "ZPSlam"
ExtraItem.Name = "ExtraItemSlamName"
ExtraItem.Price = 6
function ExtraItem:OnBuy(ply)
	local Weap = ply:GetWeapon("weapon_slam")
	if IsValid(Weap) then
		ply:GiveAmmo(1, "slam", true) 
	else
		ply:Give("weapon_slam")
	end
end

WeaponManager:AddWeaponMultiplier("npc_tripmine", 4)
WeaponManager:AddWeaponMultiplier("npc_satchel", 4)