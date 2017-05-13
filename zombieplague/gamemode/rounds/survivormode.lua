RoundManager:AddRoundType({Name = "Survivor mode",
		Chance = 5,
		MinPlayers = 3,
		SpecialRound = true,
		StartSound = {"zombieplague/survivor1.mp3", "zombieplague/survivor2.mp3"},
		StartFunction = function()
			local Survivor = table.Random(RoundManager:GetPlayersToPlay(true))
			Survivor:MakeSurvivor()
			for k, ply in pairs(player.GetAll()) do
				if !ply:IsSurvivor() then
					ply:Infect()
				end
				SendNotifyMessage(ply, string.format(Dictionary:GetPhrase("NoticeSurvivor", ply), Survivor:Name()), 5, SURVIVOR_COLOR)
			end
			
		end}
)