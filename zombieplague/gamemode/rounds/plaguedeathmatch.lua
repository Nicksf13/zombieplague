RoundManager:AddRoundType({Name = "Plague Death Match",
		Chance = 5,
		MinPlayers = 4,
		SpecialRound = true,
		Deathmatch = true,
		StartSound = {"zombieplague/plaguemode.mp3"},
		StartFunction = function()
			for k, ply in pairs(RoundManager:GetPlayersToPlay(true)) do
				if k % 2 == 0 then
					ply:MakeNemesis()
				else
					ply:MakeSurvivor()
				end
				SendNotifyMessage(ply, Dictionary:GetPhrase("RoundPlague", ply), 5, team.GetColor(ply:Team()))
			end
		end}
)