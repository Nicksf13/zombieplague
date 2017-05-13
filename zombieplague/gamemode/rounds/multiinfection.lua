RoundManager:AddRoundType({Name = "Multi Infection Mode",
		Chance = 30,
		MinPlayers = 4,
		SpecialRound = false,
		StartFunction = function()
			local ValidPlayers = RoundManager:GetPlayersToPlay(true)
			table.remove(ValidPlayers, math.random(1, table.Count(ValidPlayers))):Infect()
			table.remove(ValidPlayers, math.random(1, table.Count(ValidPlayers))):Infect()
		end}
)