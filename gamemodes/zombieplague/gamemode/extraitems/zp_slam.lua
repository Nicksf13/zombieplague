ExtraItem.ID = "ZPSlam"
ExtraItem.Name = "ExtraItemSlamName"
ExtraItem.Price = 6
ExtraItem.BuySounds = { 'weapons/slam/mine_mode.wav' }
function ExtraItem:OnBuy(ply)
	local Weap = ply:GetWeapon("weapon_slam")
	if IsValid(Weap) then
		ply:GiveAmmo(3, "slam", true) 
	else
		ply:Give("weapon_slam")
	end
end

WeaponManager:AddWeaponMultiplier("npc_tripmine", 4)
WeaponManager:AddWeaponMultiplier("npc_satchel", 4)

hook.Add( "EntityTakeDamage", "EntityDamageExample", function( target, dmginfo )
	if target:GetClass() == "npc_satchel" then
		if dmginfo:GetAttacker():IsPlayer() then
			if dmginfo:GetAttacker():IsHuman() and dmginfo:GetAttacker() != target:GetInternalVariable("m_hThrower") then
				dmginfo:SetDamage(0)
			end
		end
	end
	if target:GetClass() == "npc_tripmine" then
		if dmginfo:GetAttacker():IsPlayer() then
			if dmginfo:GetAttacker():IsHuman() and dmginfo:GetAttacker() != target:GetInternalVariable("m_hOwner") then
				dmginfo:SetDamage(0)
			end
		end
	end
end )