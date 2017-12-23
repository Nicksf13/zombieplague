ExtraItem.Name = "Zombie Madness"
ExtraItem.Price = 15
ExtraItem.Type = ITEM_ZOMBIE
function ExtraItem:OnBuy(ply)
	ply:SetLight(Color(255, 0, 0))
	ply:GodEnable()
	ply:ZPEmitSound(SafeTableRandom(ZombieMadnessSounds), 5, true)
	timer.Create("ZPGod" .. ply:SteamID64(), 5, 1, function()
		if IsValid(ply) then
			ply:SetLight(nil)
			ply:GodDisable()
		end
	end)
end
function ExtraItem:CanBuy(ply)
	return !RoundManager:IsSpecialRound() && ply:Alive()
end