RoundManager:AddRoundType({Name = "Nemesis Mode",
		Chance = 5,
		MinPlayers = 3,
		SpecialRound = true,
		StartSound = {"zombieplague/nemesis1.mp3", "zombieplague/nemesis2.mp3"},
		StartFunction = function()
			local Nemesis = table.Random(RoundManager:GetPlayersToPlay(true))
			Nemesis:MakeNemesis()
			
			for k, ply in pairs(player.GetAll()) do
				SendPopupMessage(ply, Dictionary:GetPhrase("NoticeNemesis", ply))
			end
		end}
)