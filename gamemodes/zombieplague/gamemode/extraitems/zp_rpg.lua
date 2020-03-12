ExtraItem.ID = "ZPRPG"
ExtraItem.Name = "ExtraItemRPGName"
ExtraItem.Price = 15
function ExtraItem:OnBuy(ply)
	local Weap = ply:GetWeapon("weapon_rpg")
	if IsValid(Weap) then
		ply:GiveAmmo(1, Weap:GetPrimaryAmmoType(), true) 
	else
		ply:Give("weapon_rpg")
	end
	ply:EmitSound( "weapon.StepRight" )
end

WeaponManager:AddWeaponMultiplier("rpg_missile", 4)
