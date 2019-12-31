ExtraItem.ID = "ZPTVirus"
ExtraItem.Name = "ExtraItemTVirusName"
ExtraItem.Price = 50
function ExtraItem:OnBuy(ply)
	if RoundManager:GetRoundState() == ROUND_PLAYING then
		InfectionManager:Infect(ply, ply)
	elseif RoundManager:GetRoundState() == ROUND_STARTING_NEW_ROUND then
		RoundManager:StartRound(RoundManager:GetRounds()[1], ply) -- Simple Infection Round
	end
end
function ExtraItem:CanBuy(ply)
	return (RoundManager:GetRoundState() == ROUND_PLAYING || RoundManager:GetRoundState() == ROUND_STARTING_NEW_ROUND) && !RoundManager:IsSpecialRound() && !RoundManager:LastHuman() && ply:Alive()
end