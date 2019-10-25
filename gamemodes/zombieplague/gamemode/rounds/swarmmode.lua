RoundManager:AddRoundType({Name = "Swarm Mode",
		Chance = 10,
		MinPlayers = 4,
		SpecialRound = true,
		StartSound = {"zombieplague/swarmmode.mp3"},
		StartFunction = function()
			for k, ply in pairs(RoundManager:GetPlayersToPlay(true)) do
				if k % 2 == 0 then
					ply:Infect()
				end
				SendNotifyMessage(ply, Dictionary:GetPhrase("RoundSwarm", ply), 5, Color(0, 255, 0))
			end
		end}
)