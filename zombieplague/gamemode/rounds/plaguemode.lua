RoundManager:AddRoundType({Name = "Plague Mode",
		Chance = 10,
		MinPlayers = 4,
		SpecialRound = true,
		StartSound = {"zombieplague/plaguemode.mp3"},
		StartFunction = function()
			for k, ply in pairs(RoundManager:GetPlayersToPlay(true)) do
				if k % 2 == 0 then
					ply:Infect()
				end
				SendNotifyMessage(ply, Dictionary:GetPhrase("RoundPlague", ply), 5, team.GetColor(ply:Team()))
			end
			SafeTableRandom(RoundManager:GetAliveZombies()):MakeNemesis()
			SafeTableRandom(RoundManager:GetAliveHumans()):MakeSurvivor()
		end}
)