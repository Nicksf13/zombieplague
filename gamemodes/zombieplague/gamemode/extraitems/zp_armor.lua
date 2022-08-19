ExtraItem.ID = "ZPArmor"
ExtraItem.Name = "ExtraItemArmorName"
ExtraItem.Price = 10
ExtraItem.Type = ITEM_HUMAN 
ExtraItem.BuySounds = { "npc/combine_soldier/gear6.wav" }
function ExtraItem:OnBuy(ply)
	ply:SetNWInt("ZPBuyedArmor", ply:GetNWInt("ZPBuyedArmor") + 1)
	local addArmor = ply:Armor() + 100
	ply:SetArmor(math.Clamp(addArmor, 0, ply:GetMaxHealth()))
end

function ExtraItem:CanBuy(ply)
	if !ply:IsHuman() then return false end
	if !ply:Alive() then return false end
	if ply:GetNWInt("ZPBuyedArmor") <= 1 then
		return ply:Armor() < ply:GetMaxHealth()
	end
	return false
end

hook.Add("ZPPreNewRound", "ZPARMORHOOK", function() 
	for k,ply in ipairs(player.GetAll()) do
		ply:SetNWInt("ZPBuyedArmor", 0)
	end
end)